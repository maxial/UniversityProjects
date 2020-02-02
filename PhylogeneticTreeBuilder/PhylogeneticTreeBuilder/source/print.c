//
//  print.c
//  PhylogeneticTreeBuilder
//
//  Created by Maxim Aliev on 05/05/2018.
//  Copyright © 2018 maxial. All rights reserved.
//

#include "print.h"
#include "phylogenetic_tree.h"


void print_matrix_float(const float * const * const mat, const int rows, const int cols) {
    int i;
    for (i = 0; i < rows; ++i) {
        print_arr_float(*(mat + i), cols);
    }
}


void print_matrix_int(const int * const * const mat, const int rows, const int cols) {
    int i;
    for (i = 0; i < rows; ++i) {
        print_arr_int(*(mat + i), cols);
    }
}


void print_arr_str(const char * const * const arr, const int n, const int strlen) {
    int i, j;
    for (i = 0; i < n; ++i) {
        for (j = 0; j < strlen; ++j) {
            printf("%c", *(*(arr + i) + j));
        }
        printf("\n");
    }
}


void print_arr_int(const int * const arr, const int n) {
    int i;
    for (i = 0; i < n; ++i) {
        printf("%d%c", *(arr + i), ' ');
    }
    printf("\n");
}

void print_arr_float(const float * const arr, const int n) {
    int i;
    for (i = 0; i < n; ++i) {
        printf("%f%c", *(arr + i), ' ');
    }
    printf("\n");
}

//void print_tree(const node * const start_node) {
//    if (start_node == NULL) {
//        return;
//    }
//    printf("%d ", start_node->identifier);
//    print_tree(start_node->b1);
//    print_tree(start_node->b2);
//}
