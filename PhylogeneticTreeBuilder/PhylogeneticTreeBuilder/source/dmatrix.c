//
//  dmatrix.c
//  PhylogeneticTreeBuilder
//
//  Created by Maxim Aliev on 05/05/2018.
//  Copyright © 2018 maxial. All rights reserved.
//

#include <stdlib.h>
#include "dmatrix.h"
#include "dmethods.h"


float ** calc_dmatrix(const char * const * const seqs, const int n, const int seqlen) {
    float ** dmatrix = (float **)malloc(n * sizeof(float *));
    
    int i, j;
    for (i = 0; i < n; ++i) {
        *(dmatrix + i) = (float *)calloc(n, sizeof(float));
        for (j = 0; j < n; ++j) {
            if (i != j) {
                *(*(dmatrix + i) + j) = p_distance(*(seqs + i), *(seqs + j), seqlen);
            }
        }
    }
    
    return dmatrix;
}
