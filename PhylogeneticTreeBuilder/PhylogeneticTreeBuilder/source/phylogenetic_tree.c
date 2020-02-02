//
//  phylogenetic_tree.c
//  PhylogeneticTreeBuilder
//
//  Created by Maxim Aliev on 10/05/2018.
//  Copyright © 2018 maxial. All rights reserved.
//

#include <float.h>
#include "phylogenetic_tree.h"
#include "objective_funcs.h"
#include "alloc.h"


void find_three_taxa_that_maximize_obj_func(const float * const * const dmatrix, const int n,
                                            int * const t1,
                                            int * const t2,
                                            int * const t3);
phylogenetic_tree * create_start_tree_with_taxa(node * const n1,
                                                node * const n2,
                                                node * const n3,
                                                node * const internal_node,
                                                const int n);


phylogenetic_tree * create_start_tree(node * const nodes,
                                      const float * const * const dmatrix,
                                      int * const * const shortest_ways,
                                      const int n,
                                      const int dynamic_order) {
    int t1, t2, t3;
    
    if (dynamic_order == 0) {
        t1 = 0;
        t2 = 1;
        t3 = 2;
    } else {
        find_three_taxa_that_maximize_obj_func(dmatrix, n, &t1, &t2, &t3);
    }
    
    node * n1 = (nodes + t1);
    node * n2 = (nodes + t2);
    node * n3 = (nodes + t3);
    node * internal_node = (nodes + n);
    phylogenetic_tree * tree = create_start_tree_with_taxa(n1, n2, n3, internal_node, n);
    
    *(*(shortest_ways + t1) + t2) = *(*(shortest_ways + t2) + t1) = 2;
    *(*(shortest_ways + t1) + t3) = *(*(shortest_ways + t3) + t1) = 2;
    *(*(shortest_ways + t2) + t3) = *(*(shortest_ways + t3) + t2) = 2;
    *(*(shortest_ways + n) + t1) = *(*(shortest_ways + n) + t2) = *(*(shortest_ways + n) + t3) = 1;
    *(*(shortest_ways + t1) + n) = *(*(shortest_ways + t2) + n) = *(*(shortest_ways + t3) + n) = 1;
    
    return tree;
}


// MARK: - private

void find_three_taxa_that_maximize_obj_func(const float * const * const dmatrix, const int n,
                                            int * const t1,
                                            int * const t2,
                                            int * const t3) {
    float max_score = FLT_MIN, score = 0;
    
    int i, j, k;
    for (k = 0; k < n; ++k) {
        for (j = 0; j < k; ++j) {
            for (i = 0; i < j; ++i) {
                score = obj_func_pauplin_for_three_taxa(i, j, k, dmatrix);
                
                if (score > max_score) {
                    max_score = score;
                    *t1 = i;
                    *t2 = j;
                    *t3 = k;
                }
            }
        }
    }
}


phylogenetic_tree * create_start_tree_with_taxa(node * const n1,
                                                node * const n2,
                                                node * const n3,
                                                node * const internal_node,
                                                const int n) {
    phylogenetic_tree * tree = alloc_tree(n);
    tree->start_node = internal_node;
    *(tree->taxa + 0) = n1->identifier;
    *(tree->taxa + 1) = n2->identifier;
    *(tree->taxa + 2) = n3->identifier;
    *(tree->taxa + 3) = internal_node->identifier;
    tree->taxa_count = 4;
    
    n1->b1 = internal_node;
    n2->b1 = internal_node;
    n3->b1 = internal_node;
    
    internal_node->b1 = n1;
    internal_node->b2 = n2;
    internal_node->b3 = n3;
    
    (tree->edges + 0)->source = internal_node->identifier;
    (tree->edges + 0)->dest = n1->identifier;
    
    (tree->edges + 1)->source = internal_node->identifier;
    (tree->edges + 1)->dest = n2->identifier;
    
    (tree->edges + 2)->source = internal_node->identifier;
    (tree->edges + 2)->dest = n3->identifier;
    
    return tree;
}
