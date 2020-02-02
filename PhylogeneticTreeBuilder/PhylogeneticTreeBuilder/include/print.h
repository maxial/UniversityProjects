//
//  print.h
//  PhylogeneticTreeBuilder
//
//  Created by Maxim Aliev on 05/05/2018.
//  Copyright © 2018 maxial. All rights reserved.
//

#ifndef PRINT_H
#define PRINT_H


#include <stdio.h>


void print_matrix_float(const float * const * const mat, const int rows, const int cols);
void print_matrix_int(const int * const * const mat, const int rows, const int cols);

void print_arr_str(const char * const * const, const int, const int strlen);

void print_arr_int(const int * const, const int);
void print_arr_float(const float * const, const int);


#endif /* PRINT_H */
