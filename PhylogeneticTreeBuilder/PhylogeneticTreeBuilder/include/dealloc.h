//
//  dealloc.h
//  PhylogeneticTreeBuilder
//
//  Created by Maxim Aliev on 05/05/2018.
//  Copyright © 2018 maxial. All rights reserved.
//

#ifndef DEALLOC_H
#define DEALLOC_H


#include "phylogenetic_tree.h"


void dealloc_arr_str(char ** const arr, const int n);
void dealloc_matrix(void ** matrix, const int rows);

void dealloc_tree(phylogenetic_tree * const tree);

#endif /* DEALLOC_H */
