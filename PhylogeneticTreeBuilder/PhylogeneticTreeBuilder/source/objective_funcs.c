
//
//  objective_funcs.c
//  PhylogeneticTreeBuilder
//
//  Created by Maxim Aliev on 05/05/2018.
//  Copyright © 2018 maxial. All rights reserved.
//

#include <float.h>
#include <math.h>
#include "objective_funcs.h"
#include "print.h"


float shortest_way(const phylogenetic_tree * const tree, const int i, const int j);
float eval_for_new_taxon(const int t, const float * const * const dmatrix, const int n);
int exist(const int * const arr, const int n, const int elem);


float obj_func_pauplin_for_three_taxa(const int t1, const int t2, const int t3, const float * const * const dmatrix) {
    return 0.5 * (*(*(dmatrix + t1) + t2) + *(*(dmatrix + t1) + t3) + *(*(dmatrix + t2) + t3));
}


float obj_func_pauplin(const phylogenetic_tree * const tree, const float * const * const dmatrix, const int * const * const shortest_ways, const int n) {
    float value = 0;
    
    int i, j;
    for (i = 0; i < n; ++i) {
        for (j = 0; j < i; ++j) {
            int shortest_way = *(*(shortest_ways + i) + j);
            if (shortest_way != 0) {
                value += (1.0 / pow(2, shortest_way - 1)) * *(*(dmatrix + i) + j);
            }
        }
    }
    
    return value;
}


float eval_obj_func_pauplin(const phylogenetic_tree * const tree, const float * const * const dmatrix, const float * const * const thetas, const int * const * const shortest_ways, const int n) {
    float score = obj_func_pauplin(tree, dmatrix, shortest_ways, n);
    
    if (tree->taxa_count < 2 * n - 2) {
        int i, extra_size = 0;
        for (i = 0; i < n; ++i) {
            if (!exist(tree->taxa, tree->taxa_count, i)) {
                score += *(*(thetas + i) + tree->taxa_count / 2 + extra_size++);
//                score += eval_for_new_taxon(i, dmatrix, n);
            }
        }
    }
    
    return score;
}


float max_eval_for_new_taxon(const int t, const float * const * const dmatrix, const float * const * const thetas, const int n) {
    float score = FLT_MIN;
    
    int i, j;
    float theta = 0;
    for (i = 0; i < n; ++i) {
        for (j = 0; j < i; ++j) {
            if (i != t && j != t) {
//                theta = *(*(thetas + i) + tree->taxa_count / 2);
                theta = 0.5 * (*(*(dmatrix + i) + t) + *(*(dmatrix + j) + t) - *(*(dmatrix + i) + j));
                if (theta > score) {
                    score = theta;
                }
            }
        }
    }
    
    return score;
}


// MARK: - private

float eval_for_new_taxon(const int t, const float * const * const dmatrix, const int n) {
    float score = FLT_MAX;
    
    int i, j;
    float lambda = 0;
    for (i = 0; i < n; ++i) {
        for (j = 0; j < i; ++j) {
            if (i != t && j != t) {
                lambda = 0.5 * (*(*(dmatrix + i) + t) + *(*(dmatrix + j) + t) - *(*(dmatrix + i) + j));
                if (lambda < score) {
                    score = lambda;
                }
            }
        }
    }
    
    return score;
}


int exist(const int * const arr, const int n, const int elem) {
    int i;
    for (i = 0; i < n; ++i) {
        if (*(arr + i) == elem) {
            return 1;
        }
    }
    return 0;
}
