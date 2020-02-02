//
//  alloc.c
//  PhylogeneticTreeBuilder
//
//  Created by Maxim Aliev on 06/05/2018.
//  Copyright © 2018 maxial. All rights reserved.
//

#include <stdlib.h>
#include "alloc.h"


phylogenetic_tree * alloc_tree(const int n) {
    phylogenetic_tree * tree = (phylogenetic_tree *)calloc(1, sizeof(phylogenetic_tree));
    
    tree->start_node = NULL;
    tree->edges = (edge *)calloc(2 * n - 3, sizeof(edge));
    tree->taxa = (int *)calloc(2 * n - 2, sizeof(int));
    tree->taxa_count = 0;
    
    return tree;
}


node * alloc_nodes(const int n) {
    node * arr_of_nodes = (node *)calloc(n, sizeof(node));
    
    int i = 0;
    for (i = 0; i < n; ++i) {
        (arr_of_nodes + i)->identifier = i;
    }
    
    return arr_of_nodes;
}


int * alloc_arr_int(const int n) {
    return (int *)calloc(n, sizeof(int));
}


float * alloc_arr_float(const int n) {
    return (float *)calloc(n, sizeof(float));
}


int ** alloc_matrix_int(const int rows, const int cols) {
    int ** mat = (int **)calloc(rows, sizeof(int *));
    
    int i;
    for (i = 0; i < rows; ++i) {
        *(mat + i) = alloc_arr_int(cols);
    }
    
    return mat;
}


float ** alloc_matrix_float(const int rows, const int cols) {
    float ** mat = (float **)calloc(rows, sizeof(float *));
    
    int i;
    for (i = 0; i < rows; ++i) {
        *(mat + i) = alloc_arr_float(cols);
    }
    
    return mat;
}
