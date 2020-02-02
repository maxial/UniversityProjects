//
//  alloc.h
//  PhylogeneticTreeBuilder
//
//  Created by Maxim Aliev on 06/05/2018.
//  Copyright © 2018 maxial. All rights reserved.
//

#ifndef ALLOC_H
#define ALLOC_H


#include "phylogenetic_tree.h"


phylogenetic_tree * alloc_tree(const int n);

node * alloc_nodes(const int n);

int * alloc_arr_int(const int n);
float * alloc_arr_float(const int n);

int ** alloc_matrix_int(const int rows, const int cols);
float ** alloc_matrix_float(const int rows, const int cols);

#endif /* ALLOC_H */
