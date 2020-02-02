//
//  node.h
//  PhylogeneticTreeBuilder
//
//  Created by Maxim Aliev on 05/05/2018.
//  Copyright © 2018 maxial. All rights reserved.
//

#ifndef NODE_H
#define NODE_H


typedef struct node {
    int identifier;
    struct node * b1, * b2, * b3;
} node;


#endif /* NODE_H */
