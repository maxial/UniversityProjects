//
//  fmanager.h
//  PhylogeneticTreeBuilder
//
//  Created by Maxim Aliev on 05/05/2018.
//  Copyright © 2018 maxial. All rights reserved.
//

#ifndef FMANAGER_H
#define FMANAGER_H


#include "node.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


char ** read_seqs(const char * const fname, int * const nseq, int * const lseq);


#endif /* FMANAGER_H */
