//
//  stack.h
//  PhylogeneticTreeBuilder
//
//  Created by Maxim Aliev on 05/05/2018.
//  Copyright © 2018 maxial. All rights reserved.
//

#ifndef STACK_H
#define STACK_H


#include "phylogenetic_tree.h"


typedef struct {
    int * eids;
    int top;
    int cap;
} stack;


extern const int STACK_IS_EMPTY;
extern const int LOWER_LEVEL;


stack * stack_init(const int);
void stack_destroy(stack *);

int stack_is_empty(const stack * const);
int stack_is_full(const stack * const);

void stack_push(stack * const, const int);
int stack_pop(stack * const);

void stack_tree_print(const stack * const, const phylogenetic_tree * const);
void stack_tree_add_eids(stack * const, const phylogenetic_tree * const);

#endif /* STACK_H */
