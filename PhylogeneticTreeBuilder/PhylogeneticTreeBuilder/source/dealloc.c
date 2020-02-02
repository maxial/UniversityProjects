//
//  dealloc.c
//  PhylogeneticTreeBuilder
//
//  Created by Maxim Aliev on 05/05/2018.
//  Copyright © 2018 maxial. All rights reserved.
//

#include <stdlib.h>
#include "dealloc.h"


void dealloc_arr_str(char ** arr, const int n) {
    int i = 0;
    for (i = 0; i < n; ++i) {
        free(*(arr + i));
        *(arr + i) = NULL;
    }
    free(arr);
    arr = NULL;
}


void dealloc_matrix(void ** matrix, const int rows) {
    int i = 0;
    for (i = 0; i < rows; ++i) {
        free(*(matrix + i));
        *(matrix + i) = NULL;
    }
    free(matrix);
    matrix = NULL;
}


void dealloc_tree(phylogenetic_tree * tree) {
//    free(tree->start_node);
//    tree->start_node = NULL;
    free(tree->edges);
    tree->edges = NULL;
    free(tree->taxa);
    tree->taxa = NULL;
    free(tree);
    tree = NULL;
}
