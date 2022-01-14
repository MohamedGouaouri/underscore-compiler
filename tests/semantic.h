#ifndef SEMANTIC_H
#define SEMANTIC_H
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <alloca.h>
#define MAXSTRING 255
// generate temporary names
char *gentemp();

char *genlabel();

// Call with function whenever you want to get a new address
// address might replace char labels
int nextaddress();
#endif