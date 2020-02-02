//
//  tree_builder.h
//  PhylogeneticTreeBuilder
//
//  Created by Maxim Aliev on 05/05/2018.
//  Copyright © 2018 maxial. All rights reserved.
//

#ifndef TREE_BUILDER_H
#define TREE_BUILDER_H


#include "phylogenetic_tree.h"


typedef struct {
    phylogenetic_tree * tree;
    node * nodes;
    int * edges_ids;
    int ** shortest_ways;
    float ** dmatrix;
    float ** thetas;
    int n;
    float accuracy;
    int dynamic_order;
} tree_args_struct;


phylogenetic_tree * build_tree(const float * const * const dmatrix, const float * const * const thetas, const int n, const float accuracy, const int multithreading, const int dynamic_order);


#endif /* TREE_BUILDER_H */
