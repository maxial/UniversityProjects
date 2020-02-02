//
//  objective_funcs.h
//  PhylogeneticTreeBuilder
//
//  Created by Maxim Aliev on 05/05/2018.
//  Copyright © 2018 maxial. All rights reserved.
//

#ifndef OBJECTIVE_FUNCS_H
#define OBJECTIVE_FUNCS_H


#include "phylogenetic_tree.h"


float obj_func_pauplin_for_three_taxa(const int, const int, const int, const float * const * const);

float obj_func_pauplin(const phylogenetic_tree * const tree, const float * const * const dmatrix, const int * const * const shortest_ways, const int n);
float eval_obj_func_pauplin(const phylogenetic_tree * const tree, const float * const * const dmatrix, const float * const * const thetas, const int * const * const shortest_ways, const int n);

float max_eval_for_new_taxon(const int t, const float * const * const dmatrix, const float * const * const thetas, const int n);


#endif /* OBJECTIVE_FUNCS_H */
