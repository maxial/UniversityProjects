//
//  tree_builder.c
//  PhylogeneticTreeBuilder
//
//  Created by Maxim Aliev on 05/05/2018.
//  Copyright © 2018 maxial. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <float.h>
#include <pthread.h>
#include "tree_builder.h"
#include "nj.h"
#include "stack.h"
#include "objective_funcs.h"
#include "alloc.h"
#include "dealloc.h"
#include "print.h"


float MIN_SCORE = FLT_MAX;
int number_of_threads = 15;

pthread_mutex_t mut;


tree_args_struct * get_tree_args_for_start_tree(const float * const * const dmatrix,
                                                const float * const * const thetas,
                                                const int n,
                                                const float accuracy,
                                                const int dynamic_order);
void * find_opt_tree(void * arguments);

int select_new_taxon_to_join(const phylogenetic_tree * const tree,
                             const float * const * const dmatrix,
                             const float * const * const thetas,
                             const int * const * const shortest_ways,
                             const int n);

void add_new_taxon(const int t,
                   phylogenetic_tree * const tree,
                   node * const nodes,
                   int * const edges_ids,
                   int * const * const shortest_ways,
                   const int eid, const int n);

void remove_last_added_taxon(phylogenetic_tree * const tree,
                             node * const nodes,
                             int * const edges_ids,
                             int * const * const shortest_ways,
                             const int n);


phylogenetic_tree * build_tree(const float * const * const dmatrix,
                               const float * const * const thetas,
                               const int n,
                               const float accuracy,
                               const int multithreading,
                               const int dynamic_order) {
    MIN_SCORE = nj(dmatrix, n);
    if (multithreading == 0) {
        tree_args_struct * tree_args = get_tree_args_for_start_tree(dmatrix, thetas, n, accuracy, dynamic_order);
        return find_opt_tree((void *)tree_args);
    } else {
        pthread_t * threads = (pthread_t *)malloc(number_of_threads * sizeof(pthread_t));
        pthread_mutex_init(&mut, NULL);
        
        int i, j, rc;
        for (i = 0; i < 3; ++i) {
            for (j = 0; j < 5; ++j) {
                tree_args_struct * tree_args = get_tree_args_for_start_tree(dmatrix, thetas, n, accuracy, dynamic_order);
                
                int t1 = select_new_taxon_to_join(tree_args->tree, dmatrix, thetas, (const int * const * const)tree_args->shortest_ways, n);
                add_new_taxon(t1, tree_args->tree, tree_args->nodes, tree_args->edges_ids, tree_args->shortest_ways, i, n);
                int t2 = select_new_taxon_to_join(tree_args->tree, dmatrix, thetas, (const int * const * const)tree_args->shortest_ways, n);
                add_new_taxon(t2, tree_args->tree, tree_args->nodes, tree_args->edges_ids, tree_args->shortest_ways, j, n);
                
                rc = pthread_create(&*(threads + i * 5 + j), NULL, find_opt_tree, (void *)tree_args);
                if (rc != 0) {
                    printf("Error creating thread: code %d\n", rc);
                    exit(-1);
                }
            }
        }
        
        for (i = 0; i < number_of_threads; ++i) {
            rc = pthread_join(*(threads + i), NULL);
            if (rc != 0) {
                printf("Error joining thread: code %d\n", rc);
                exit(-1);
            }
        }
        
        free(threads);
        pthread_mutex_destroy(&mut);
        
        return NULL;
    }
}


// MARK: - private

tree_args_struct * get_tree_args_for_start_tree(const float * const * const dmatrix, const float * const * const thetas, const int n, const float accuracy, const int dynamic_order) {
    const int total_num_of_taxa = 2 * n - 2;
    
    node * nodes = alloc_nodes(total_num_of_taxa);
    int * edges_ids = alloc_arr_int(n);
    int ** shortest_ways = alloc_matrix_int(total_num_of_taxa, total_num_of_taxa);
    
    phylogenetic_tree * tree = create_start_tree(nodes, dmatrix, shortest_ways, n, dynamic_order);
    
    tree_args_struct * tree_args = (tree_args_struct *)calloc(1, sizeof(tree_args_struct));
    tree_args->tree = tree;
    tree_args->nodes = nodes;
    tree_args->edges_ids = edges_ids;
    tree_args->shortest_ways = shortest_ways;
    tree_args->dmatrix = (float **)dmatrix;
    tree_args->thetas = (float **)thetas;
    tree_args->n = n;
    tree_args->accuracy = accuracy;
    tree_args->dynamic_order = dynamic_order;
    
    return tree_args;
}


void * find_opt_tree(void * arguments) {
    tree_args_struct * args = (tree_args_struct *)arguments;
    phylogenetic_tree * const tree = args->tree;
    node * const nodes = args->nodes;
    int * const edges_ids = args->edges_ids;
    int * const * const shortest_ways = args->shortest_ways;
    const float * const * const dmatrix = (const float * const * const)args->dmatrix;
    const float * const * const thetas = (const float * const * const)args->thetas;
    const int n = args->n;
    const float accuracy = args->accuracy;
    const int dynamic_order = args->dynamic_order;
    
    stack * stack = stack_init(n * n + n);
    
    stack_tree_add_eids(stack, tree);
    
    int num_of_vertices = 0;
    
    while (!stack_is_empty(stack)) {
        int eid = stack_pop(stack);
        
        if (eid == LOWER_LEVEL) {
            remove_last_added_taxon(tree, nodes, edges_ids, shortest_ways, n);
            continue;
        }
        
        num_of_vertices += 1;
        
        if (tree->taxa_count < 2 * n - 2) {
            int t;
            if (dynamic_order == 0) {
                t = tree->taxa_count / 2 + 1;
            } else {
                t = select_new_taxon_to_join(tree, dmatrix, thetas, (const int * const * const)shortest_ways, n);
            }
            
            add_new_taxon(t, tree, nodes, edges_ids, shortest_ways, eid, n);
        }
        
        float score = eval_obj_func_pauplin(tree, dmatrix, thetas, (const int * const * const)shortest_ways, n);
        
        if (tree->taxa_count == 2 * n - 2) {
            if (score < MIN_SCORE) {
                pthread_mutex_lock(&mut);
                MIN_SCORE = score;
                pthread_mutex_unlock(&mut);
            }
            remove_last_added_taxon(tree, nodes, edges_ids, shortest_ways, n);
        } else if (score > MIN_SCORE * accuracy) {
            remove_last_added_taxon(tree, nodes, edges_ids, shortest_ways, n);
        } else {
            stack_tree_add_eids(stack, tree);
        }
    }
    
    printf("vertices: %d\n", num_of_vertices);

    printf("score: %f\n", MIN_SCORE);
    
    stack_destroy(stack);
    free(nodes);
    free(edges_ids);
    dealloc_matrix((void **)shortest_ways, 2 * n - 2);
    dealloc_tree(tree);
    
    return NULL;
}


int taxon_exist_in_tree(const int taxon, const phylogenetic_tree * const tree) {
    int i;
    for (i = 0; i < tree->taxa_count; ++i) {
        if (*(tree->taxa + i) == taxon) {
            return 1;
        }
    }
    return 0;
}


int select_new_taxon_to_join(const phylogenetic_tree * const tree, const float * const * const dmatrix, const float * const * const thetas, const int * const * const shortest_ways, const int n) {
    float max_score = -1000000;
    int taxon = -1;
    
    int i;
    for (i = 0; i < n; ++i) {
        if (!taxon_exist_in_tree(i, tree)) {
            float score = max_eval_for_new_taxon(i, dmatrix, thetas, n);
//            float score = *(*(thetas + i) + tree->taxa_count / 2);
            if (score > max_score) {
                max_score = score;
                taxon = i;
            }
        }
    }
    
    return taxon;
}


void configure_shortest_ways_after_add_taxon(int * const * const shortest_ways,
                                             const int * const tree_taxa,
                                             const int t,
                                             const int internal_t,
                                             const int e_source,
                                             const int e_dest,
                                             const int taxa_count) {
    int i, j;
    for (i = 0; i < taxa_count; ++i) {
        for (j = 0; j < i; ++j) {
            int ti = *(tree_taxa + i);
            int tj = *(tree_taxa + j);
            int e_source_way = *(*(shortest_ways + tj) + e_source);
            int e_dest_way = *(*(shortest_ways + tj) + e_dest);
            if (ti == t) {
                if (tj == internal_t) {
                    *(*(shortest_ways + ti) + tj) = *(*(shortest_ways + tj) + ti) = 1;
                } else if (e_source_way > e_dest_way) {
                    *(*(shortest_ways + ti) + tj) = *(*(shortest_ways + tj) + ti) = e_dest_way + 2;
                } else {
                    *(*(shortest_ways + ti) + tj) = *(*(shortest_ways + tj) + ti) = e_source_way + 2;
                }
            } else if (ti == internal_t) {
                if (tj == t) {
                    *(*(shortest_ways + ti) + tj) = *(*(shortest_ways + tj) + ti) = 1;
                } else if (e_source_way > e_dest_way) {
                    *(*(shortest_ways + ti) + tj) = *(*(shortest_ways + tj) + ti) = e_dest_way + 1;
                } else {
                    *(*(shortest_ways + ti) + tj) = *(*(shortest_ways + tj) + ti) = e_source_way + 1;
                }
            } else {
                int e_source_way_i = *(*(shortest_ways + ti) + e_source);
                int e_dest_way_i = *(*(shortest_ways + ti) + e_dest);
                if ((e_source_way > e_dest_way && e_source_way_i < e_dest_way_i) ||
                    (e_dest_way > e_source_way && e_dest_way_i < e_source_way_i)) {
                    *(*(shortest_ways + ti) + tj) += 1;
                    *(*(shortest_ways + tj) + ti) += 1;
                }
            }
        }
    }
}


void configure_shortest_ways_after_remove_taxon(int * const * const shortest_ways,
                                                const int * const tree_taxa,
                                                const int rm_t,
                                                const int rm_internal_t,
                                                const int e_source,
                                                const int e_dest,
                                                const int taxa_count,
                                                const int n) {
    int i, j;
    for (i = 0; i < n; ++i) {
        *(*(shortest_ways + rm_t) + i) = *(*(shortest_ways + i) + rm_t) = 0;
        *(*(shortest_ways + rm_internal_t) + i) = *(*(shortest_ways + i) + rm_internal_t) = 0;
    }
    for (i = 0; i < taxa_count; ++i) {
        for (j = 0; j < i; ++j) {
            int ti = *(tree_taxa + i);
            int tj = *(tree_taxa + j);
            int e_source_way = *(*(shortest_ways + tj) + e_source);
            int e_dest_way = *(*(shortest_ways + tj) + e_dest);
            int e_source_way_i = *(*(shortest_ways + ti) + e_source);
            int e_dest_way_i = *(*(shortest_ways + ti) + e_dest);
            if ((e_source_way > e_dest_way && e_source_way_i < e_dest_way_i) ||
                (e_dest_way > e_source_way && e_dest_way_i < e_source_way_i)) {
                *(*(shortest_ways + ti) + tj) -= 1;
                *(*(shortest_ways + tj) + ti) -= 1;
            }
        }
    }
}


void add_new_taxon(const int t, phylogenetic_tree * const tree, node * const nodes, int * const edges_ids, int * const * const shortest_ways, const int eid, const int n) {
    *(edges_ids + t) = eid;
    
    int internal_t = n + tree->taxa_count / 2 - 1;
    
    node * new_external_node = (nodes + t);
    node * new_internal_node = (nodes + internal_t);
    
    edge * e = tree->edges + eid;
    edge * new_edge1 = tree->edges + tree->taxa_count - 1;
    edge * new_edge2 = tree->edges + tree->taxa_count;
    
    new_internal_node->b1 = new_external_node;
    new_internal_node->b2 = (nodes + e->source);
    new_internal_node->b3 = (nodes + e->dest);
    
    new_external_node->b1 = new_internal_node;
    
    node * e_source = (nodes + e->source);
    node * e_dest = (nodes + e->dest);
    
    if (e_source->b1 == e_dest) {
        e_source->b1 = new_internal_node;
        e->dest = internal_t;
    } else if (e_source->b2 == e_dest) {
        e_source->b2 = new_internal_node;
        e->dest = internal_t;
    } else if (e_source->b3 == e_dest) {
        e_source->b3 = new_internal_node;
        e->dest = internal_t;
    }
    
    if (e_dest->b1 == e_source) {
        e_dest->b1 = new_internal_node;
    } else if (e_dest->b2 == e_source) {
        e_dest->b2 = new_internal_node;
    } else if (e_dest->b3 == e_source) {
        e_dest->b3 = new_internal_node;
    }
    
    new_edge1->source = internal_t;
    new_edge1->dest = e_dest->identifier;
    
    new_edge2->source = internal_t;
    new_edge2->dest = t;
    
    *(tree->taxa + tree->taxa_count) = t;
    *(tree->taxa + tree->taxa_count + 1) = internal_t;
    tree->taxa_count += 2;
    
    configure_shortest_ways_after_add_taxon(shortest_ways,
                                            tree->taxa,
                                            t,
                                            internal_t,
                                            e_source->identifier,
                                            e_dest->identifier,
                                            tree->taxa_count);
}


void remove_last_added_taxon(phylogenetic_tree * const tree, node * const nodes, int * const edges_ids, int * const * const shortest_ways, const int n) {
    int t = *(tree->taxa + tree->taxa_count - 2);
    int internal_t = *(tree->taxa + tree->taxa_count - 1);
    
    node * external_node_for_remove = (nodes + t);
    node * internal_node_for_remove = (nodes + internal_t);
    
    int eid = *(edges_ids + t);
    edge * e = tree->edges + eid;
    edge * new_edge1 = tree->edges + tree->taxa_count - 3;
    edge * new_edge2 = tree->edges + tree->taxa_count - 2;
    
    external_node_for_remove->b1 = NULL;
    external_node_for_remove->b2 = NULL;
    external_node_for_remove->b3 = NULL;
    
    new_edge1->source = -1;
    new_edge1->dest = -1;
    new_edge2->source = -1;
    new_edge2->dest = -1;
    
    node * n1 = NULL, * n2 = NULL;
    if (internal_node_for_remove->b1 == external_node_for_remove) {
        n1 = internal_node_for_remove->b2;
        n2 = internal_node_for_remove->b3;
    } else if (internal_node_for_remove->b2 == external_node_for_remove) {
        n1 = internal_node_for_remove->b1;
        n2 = internal_node_for_remove->b3;
    } else if (internal_node_for_remove->b3 == external_node_for_remove) {
        n1 = internal_node_for_remove->b1;
        n2 = internal_node_for_remove->b2;
    }
    
    e->source = n1->identifier;
    e->dest = n2->identifier;
    
    if (n1->b1 == internal_node_for_remove) {
        n1->b1 = n2;
    } else if (n1->b2 == internal_node_for_remove) {
        n1->b2 = n2;
    } else if (n1->b3 == internal_node_for_remove) {
        n1->b3 = n2;
    }
    
    if (n2->b1 == internal_node_for_remove) {
        n2->b1 = n1;
    } else if (n2->b2 == internal_node_for_remove) {
        n2->b2 = n1;
    } else if (n2->b3 == internal_node_for_remove) {
        n2->b3 = n1;
    }
    
    internal_node_for_remove->b1 = NULL;
    internal_node_for_remove->b2 = NULL;
    internal_node_for_remove->b3 = NULL;
    
    *(tree->taxa + tree->taxa_count - 2) = 0;
    *(tree->taxa + tree->taxa_count - 1) = 0;
    tree->taxa_count -= 2;
    
    configure_shortest_ways_after_remove_taxon(shortest_ways,
                                               tree->taxa,
                                               t,
                                               internal_t,
                                               e->source,
                                               e->dest,
                                               tree->taxa_count,
                                               n);
}
