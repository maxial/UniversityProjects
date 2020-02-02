//
//  fmanager.c
//  PhylogeneticTreeBuilder
//
//  Created by Maxim Aliev on 05/05/2018.
//  Copyright © 2018 maxial. All rights reserved.
//

#include "fmanager.h"


FILE * open_file(const char * const fname, int * const nseq, int * const lseq);
char ** read_seqs_from_file(FILE * fp, const int nseq, const int lseq);


char ** read_seqs(const char * const fname, int * const nseq, int * const lseq) {
    FILE * fp = open_file(fname, nseq, lseq);
    char ** seqs = read_seqs_from_file(fp, *nseq, *lseq);
    
    fclose(fp);
    return seqs;
}


// MARK: - private

FILE * open_file(const char * const fname, int * const nseq, int * const lseq) {
    FILE * fp;
    
    if ((fp = fopen(fname, "r")) == NULL || fscanf(fp, "%d", nseq) != 1 || fscanf(fp, "%d", lseq) != 1) {
        printf("Ошибка при открытии файла.\n");
        exit(-1);
    }
    
    return fp;
}


char ** alloc_seqs(const int nseq, const int lseq) {
    char ** seqs = (char **)malloc(nseq * sizeof(char *));
    
    int i;
    for (i = 0; i < nseq; ++i) {
        *(seqs + i) = (char *)malloc((lseq + 1) * sizeof(char));
    }
    
    return seqs;
}


char ** read_seqs_from_file(FILE * fp, const int nseq, const int lseq) {
    char ** seqs;
    
    if ((seqs = alloc_seqs(nseq, lseq)) == NULL) {
        printf("Не удалось выделить память для последовательностей.\n");
        exit(-1);
    }
    
    int i = 0;
    while (1) {
        char c;
        while ((c = getc(fp)) != '\n');
        
        char * seq = *(seqs + i);
        
        if (fgets(seq, lseq + 1, fp) != NULL) {
            char * dup = (char *)malloc(lseq + 1);
            if (dup != 0) {
                memmove(dup, seq, lseq + 1);
            }
            seq = dup;
            ++i;
        } else {
            if (feof(fp) != 0) {
                printf("Файл полностью прочитан.\n");
                break;
            } else {
                printf("Ошибка при чтении файла.\n");
                exit(-1);
            }
        }
    }
    
    return seqs;
}
