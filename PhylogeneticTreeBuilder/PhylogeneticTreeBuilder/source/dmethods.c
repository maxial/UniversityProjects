//
//  dmethods.c
//  PhylogeneticTreeBuilder
//
//  Created by Maxim Aliev on 05/05/2018.
//  Copyright © 2018 maxial. All rights reserved.
//

#include "dmethods.h"


float p_distance(const char * const seq1, const char * const seq2, const int lseq) {
    int nd = 0;
    
    int i;
    for (i = 0; i < lseq; ++i) {
        if (*(seq1 + i) != *(seq2 + i)) {
            nd++;
        }
    }
    
    return (float)nd / lseq;
}
