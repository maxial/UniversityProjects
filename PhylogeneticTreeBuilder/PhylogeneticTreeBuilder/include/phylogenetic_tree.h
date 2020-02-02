//
//  phylogenetic_tree.h
//  PhylogeneticTreeBuilder
//
//  Created by Maxim Aliev on 06/05/2018.
//  Copyright © 2018 maxial. All rights reserved.
//

#ifndef PHYLOGENETIC_TREE_H
#define PHYLOGENETIC_TREE_H


#include "node.h"
#include "edge.h"


typedef struct {
    node * start_node;
    edge * edges;
    int * taxa;
    int taxa_count;
} phylogenetic_tree;


phylogenetic_tree * create_start_tree(node * const nodes,
                                      const float * const * const dmatrix,
                                      int * const * const shortest_ways,
                                      const int n,
                                      const int dynamic_order);


#endif /* PHYLOGENETIC_TREE_H */
