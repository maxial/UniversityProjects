//
//  main.c
//  PhylogeneticTreeBuilder
//
//  Created by Maxim Aliev on 05/05/2018.
//  Copyright © 2018 maxial. All rights reserved.
//

#include <time.h>
#include <math.h>
#include "print.h"
#include "fmanager.h"
#include "dmatrix.h"
#include "tree_builder.h"
#include "alloc.h"
#include "dealloc.h"


const char * const fname = "/Users/maxial/Projects/[C]/PhylogeneticTreeBuilder/PhylogeneticTreeBuilder/data/sequences.txt";


int compare (const void * a, const void * b) {
    float fa = *(const float *)a;
    float fb = *(const float *)b;
    return (fa > fb) - (fa < fb);
}


int main(int argc, const char ** argv) {
    
    // MARK: Чтение таксонов
    
    int nseq = 0, lseq = 0;
    char ** seqs = read_seqs(fname, &nseq, &lseq);
    
    // MARK: Вычисление матрицы расстояний
    
    float ** dmatrix = calc_dmatrix((const char * const * const)seqs, nseq, lseq);
//    print_matrix_float((const float * const * const)dmatrix, nseq, nseq);
    
    // MARK: Вычисление оценок
    
    int size = (nseq - 1) * nseq / 2;
    float ** lambdas = alloc_matrix_float(nseq, size);
    int i, j, k, l = 0;
    for (k = 0; k < nseq; ++k) {
        l = 0;
        for (j = 0; j < nseq; ++j) {
            for (i = 0; i < j; ++i) {
                if (k != i && k != j) {
                    *(*(lambdas + k) + l++) = 0.5 * (*(*(dmatrix + i) + k) + *(*(dmatrix + j) + k) - *(*(dmatrix + i) + j));
                }
            }
        }
    }
    
    for (k = 0; k < nseq; ++k) {
        qsort(*(lambdas + k), l, sizeof(float), compare);
    }
    
    float ** thetas = alloc_matrix_float(nseq, nseq);
    for (i = 0; i < nseq; ++i) {
        for (j = 2; j <= nseq; ++j) {
            float temp = 0.0;
            for (k = 1; k < j - 1; ++k) {
                temp += 1.0 / pow(2.0, (double)k) * *(*(lambdas + i) + k - 1);
            }
            temp += 1.0 / pow(2.0, (double)j - 2.0) * *(*(lambdas + i) + j - 2);
            *(*(thetas + i) + j - 1) = temp;
        }
    }
    
    // MARK: Построение филогенетического дерева
    
    struct timespec start, finish;
    double elapsed;
    
    clock_gettime(CLOCK_MONOTONIC, &start);
    
    phylogenetic_tree * tree = build_tree((const float * const * const)dmatrix, (const float * const * const)thetas, nseq, 0.95, 1, 1);
    
    clock_gettime(CLOCK_MONOTONIC, &finish);
    elapsed = finish.tv_sec - start.tv_sec;
    elapsed += (finish.tv_nsec - start.tv_nsec) / 1000000000.0;
    printf("time: %f\n", elapsed);
    
    // MARK: Освобождение памяти
    
    dealloc_arr_str(seqs, nseq);
    dealloc_matrix((void **)dmatrix, nseq);
//    dealloc_tree(tree);
    
    return 0;
}


