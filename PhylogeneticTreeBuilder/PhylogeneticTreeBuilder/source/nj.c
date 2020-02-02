//
//  nj.c
//  PhylogeneticTreeBuilder
//
//  Created by Maxim Aliev on 20/05/2018.
//  Copyright © 2018 maxial. All rights reserved.
//

#include <stdlib.h>
#include <float.h>
#include "nj.h"
#include "alloc.h"
#include "print.h"


int next_internal_node_id = 0;
int next_edge_id = 0;
int * map;
float tree_weight = 0;


float ** dmatrix_for_nj(const float * const * const dmatrix, const int rows, const int cols, const int new_rows, const int new_cols);
void update_qmatrix(const float * const * const dmatrix, const int n, float * const * const qmatrix);
void update_dmatrix(float * const * const dmatrix, const int n, const int t1, const int t2);
void find_neighbors(const float * const * const qmatrix, const int n, int * t1, int * t2);
void update_tree(phylogenetic_tree * const tree, node * const nodes, const int n, const int t1, const int t2);
void update_tree_weight(const float * const * const dmatrix, const int n, const int t1, const int t2);


float nj(const float * const * const dmat, const int n) {
    const int total_num_of_taxa = 2 * n - 2;
    
    map = alloc_arr_int(n);
    int i;
    for (i = 0; i < n; ++i) {
        *(map + i) = i;
    }
    
    node * nodes = alloc_nodes(total_num_of_taxa);
    float ** qmatrix = alloc_matrix_float(total_num_of_taxa, total_num_of_taxa);
    float * const * const dmatrix = dmatrix_for_nj(dmat, n, n, total_num_of_taxa, total_num_of_taxa);
    
    next_internal_node_id = n;
    
    phylogenetic_tree * tree = alloc_tree(n);
    
    int size = n;
    
    while (size > 2) {
        update_qmatrix((const float * const * const)dmatrix, size, qmatrix);
        
        int t1, t2;
        find_neighbors((const float * const * const)qmatrix, size, &t1, &t2);
        
        update_tree(tree, nodes, n, t1, t2);
        update_tree_weight((const float * const * const)dmatrix, size, t1, t2);
        
        update_dmatrix(dmatrix, size, t1, t2);
        
        --size;
    }
    
    int t1 = *(map + 0);
    int t2 = *(map + 1);
    
    node * n1 = (nodes + t1);
    node * n2 = (nodes + t2);
    
    if (n1->b1 == NULL) {
        n1->b1 = n2;
    } else if (n1->b2 == NULL) {
        n1->b2 = n2;
    } else if (n1->b3 == NULL) {
        n1->b3 = n2;
    }
    
    if (n2->b1 == NULL) {
        n2->b1 = n1;
    } else if (n2->b2 == NULL) {
        n2->b2 = n1;
    } else if (n2->b3 == NULL) {
        n2->b3 = n1;
    }
    
    edge * new_edge1 = tree->edges + next_edge_id;
    next_edge_id += 1;
    
    new_edge1->source = n1->identifier;
    new_edge1->dest = n2->identifier;
    
    return tree_weight;
}


// MARK: - private

float ** dmatrix_for_nj(const float * const * const dmatrix, const int rows, const int cols, const int new_rows, const int new_cols) {
    float ** new_matrix = alloc_matrix_float(new_rows, new_cols);
    
    int i, j;
    for (i = 0; i < rows; ++i) {
        for (j = 0; j < cols; ++j) {
            *(*(new_matrix + i) + j) = *(*(dmatrix + i) + j);
        }
    }
    
    return new_matrix;
}


void update_qmatrix(const float * const * const dmatrix, const int n, float * const * const qmatrix) {
    int i, j, k;
    for (i = 0; i < n; ++i) {
        int ii = *(map + i);
        for (j = 0; j < i; ++j) {
            int jj = *(map + j);
            float temp = (n - 2) * *(*(dmatrix + ii) + jj);
            
            for (k = 0; k < n; ++k) {
                temp -= *(*(dmatrix + ii) + *(map + k)) + *(*(dmatrix + jj) + *(map + k));
            }
            
            *(*(qmatrix + ii) + jj) = temp;
            *(*(qmatrix + jj) + ii) = temp;
        }
    }
}


void find_neighbors(const float * const * const qmatrix, const int n, int * t1, int * t2) {
    float min = FLT_MAX;
    
    int i, j;
    for (i = 0; i < n; ++i) {
        int ii = *(map + i);
        for (j = 0; j < i; ++j) {
            int jj = *(map + j);
            if (*(*(qmatrix + ii) + jj) < min) {
                min = *(*(qmatrix + ii) + jj);
                *t1 = ii;
                *t2 = jj;
            }
        }
    }
}


void update_tree(phylogenetic_tree * const tree, node * const nodes, const int n, const int t1, const int t2) {
    node * internal_node = (nodes + next_internal_node_id++);
    node * n1 = (nodes + t1);
    node * n2 = (nodes + t2);
    
    if (tree->start_node == NULL) {
        tree->start_node = internal_node;
    }
    
    internal_node->b1 = n1;
    internal_node->b2 = n2;
    
    if (n1->b1 == NULL) {
        n1->b1 = internal_node;
    } else if (n1->b2 == NULL) {
        n1->b2 = internal_node;
    } else if (n1->b3 == NULL) {
        n1->b3 = internal_node;
    }
    
    if (n2->b1 == NULL) {
        n2->b1 = internal_node;
    } else if (n2->b2 == NULL) {
        n2->b2 = internal_node;
    } else if (n2->b3 == NULL) {
        n2->b3 = internal_node;
    }
    
    edge * new_edge1 = tree->edges + next_edge_id;
    edge * new_edge2 = tree->edges + next_edge_id + 1;
    next_edge_id += 2;
    
    new_edge1->source = internal_node->identifier;
    new_edge1->dest = n1->identifier;
    
    new_edge2->source = internal_node->identifier;
    new_edge2->dest = n2->identifier;
    
    if (n1->identifier < n && n2->identifier < n) {
        *(tree->taxa + tree->taxa_count) = n1->identifier;
        *(tree->taxa + tree->taxa_count + 1) = n2->identifier;
        *(tree->taxa + tree->taxa_count + 2) = internal_node->identifier;
        tree->taxa_count += 3;
    } else if (n1->identifier >= n && n2->identifier >= n) {
        *(tree->taxa + tree->taxa_count) = internal_node->identifier;
        tree->taxa_count += 1;
    } else {
        if (n1->identifier < n) {
            *(tree->taxa + tree->taxa_count) = n1->identifier;
        } else {
            *(tree->taxa + tree->taxa_count) = n2->identifier;
        }
        *(tree->taxa + tree->taxa_count + 1) = internal_node->identifier;
        tree->taxa_count += 2;
    }
}


void update_tree_weight(const float * const * const dmatrix, const int n, const int t1, const int t2) {
    float temp = 0.0;
    int i;
    for (i = 0; i < n; ++i) {
        int ii = *(map + i);
        temp += *(*(dmatrix + t1) + ii) - *(*(dmatrix + t2) + ii);
    }
    float dist = 0.5 * *(*(dmatrix + t1) + t2) + (1.0 / (2 * (n - 2))) * temp;
    tree_weight += dist;
    tree_weight += *(*(dmatrix + t1) + t2) - dist;
    if (n == 3) {
        tree_weight += *(*(dmatrix + t1) + *(map + 2)) - dist;
    }
}


void update_dmatrix(float * const * const dmatrix, const int n, const int t1, const int t2) {
    int i, t1_ind = -1, t2_ind = -1;
    
    for (i = 0; i < n; ++i) {
        if (*(map + i) == t1) {
            t1_ind = i;
            break;
        }
    }
    for (i = 0; i < n; ++i) {
        if (*(map + i) == t2) {
            t2_ind = i;
            break;
        }
    }
    
    if (t1_ind < t2_ind) {
        *(map + t1_ind) = next_internal_node_id - 1;
        for (i = t2_ind; i < n - 1; ++i) {
            *(map + i) = *(map + i + 1);
        }
    } else {
        *(map + t2_ind) = next_internal_node_id - 1;
        for (i = t1_ind; i < n - 1; ++i) {
            *(map + i) = *(map + i + 1);
        }
    }
    
    for (i = 0; i < n; ++i) {
        int i_ind = *(map + i);
        if (i_ind != next_internal_node_id - 1) {
            *(*(dmatrix + next_internal_node_id - 1) + i_ind) = 0.5 * (*(*(dmatrix + t1) + i_ind) + *(*(dmatrix + t2) + i_ind) - *(*(dmatrix + t1) + t2));
            *(*(dmatrix + i_ind) + next_internal_node_id - 1) = *(*(dmatrix + next_internal_node_id - 1) + i_ind);
        }
    }
}
