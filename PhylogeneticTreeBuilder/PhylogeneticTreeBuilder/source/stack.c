//
//  stack.c
//  PhylogeneticTreeBuilder
//
//  Created by Maxim Aliev on 05/05/2018.
//  Copyright © 2018 maxial. All rights reserved.
//

#include "stack.h"
#include <stdlib.h>
#include <stdio.h>


const int STACK_IS_EMPTY    = -1;
const int LOWER_LEVEL       = -2;


stack * stack_init(const int size) {
    stack * s = (stack *)malloc(sizeof(stack));
    s->cap = size;
    s->top = -1;
    s->eids = (int *)calloc(size, sizeof(int));
    return s;
}


void stack_destroy(stack * s) {
    free(s->eids);
    s->eids = NULL;
    s->top = -1;
    s->cap = 0;
}


int stack_is_empty(const stack * const s) {
    return s->top < 0;
}


int stack_is_full(const stack * const s) {
    return s->top >= s->cap - 1;
}


void stack_push(stack * const s, const int eid) {
    if (stack_is_full(s)) {
        printf("stack is full\n");
        return;
    }
    *(s->eids + ++s->top) = eid;
}


int stack_pop(stack * const s) {
    if (stack_is_empty(s)) {
        printf("stack is empty\n");
        return STACK_IS_EMPTY;
    }
    return *(s->eids + s->top--);
}


void stack_tree_print(const stack * const s, const phylogenetic_tree * const tree) {
    int i;
    for (i = s->top; i >= 0; --i) {
        int eid = *(s->eids + i);
        if (eid == LOWER_LEVEL) {
            printf("LOWER_LEVEL\n");
        } else {
            edge * e = (tree->edges + eid);
            printf("%d - %d\n", e->source, e->dest);
        }
    }
}


void stack_tree_add_eids(stack * const s, const phylogenetic_tree * const tree) {
    stack_push(s, LOWER_LEVEL);
    int i;
    for (i = 0; i < tree->taxa_count - 1; ++i) {
        stack_push(s, i);
    }
}
