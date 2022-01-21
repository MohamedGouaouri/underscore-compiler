#ifndef SEMANTIC_H
#define SEMANTIC_H
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <alloca.h>
#include "quadruplets.h"

#define MAXSTRING 255
#define MAXCODE 100
#define true 1;
#define false 0;
typedef int bool;

struct jump_indices
{
    /* data */
    int index;
    struct jump_indices *next;
};

struct statement
{

    /*S: nextlist is a list of all conditional and unconditional jumps
    to the instruction following the code for statement S in execution order*/
    struct jump_indices *nextlist;
    struct jump_indices *breaklist;
    struct jump_indices *continuelist;
};

struct boolean_expression
{
    /* a list of jump or conditional jump instructions into which
    we must insert the label to which control goes if B is true */
    struct jump_indices *truelist;

    /*a list of jump or conditional jump instructions into which
    we must insert the label to which control goes if B is false*/
    struct jump_indices *falselist;
};

// union arithmetic_expression_value
// {
//     /* Arithmetic expression can be either a value like integers or a temporary variable */
// };

struct arithmetic_expression
{
    /* data */
    bool is_litteral; // tells weather the synthesized expression is a litteral value
    int value;        // for simplicity we go for just int values
    char sym[255];
};

struct expression
{
    /* data */
    bool is_string;
    bool is_boolean; // tells weather the current expression is boolean or not
    struct arithmetic_expression arithmetic_expression;
    struct boolean_expression boolean_expression;
};

struct ifstatement
{
    struct jump_indices *breaklist;
    struct jump_indices *continuelist;
    struct boolean_expression boolean_expression;
    struct jump_indices *nextlist;
    int m1;
};

// generate temporary names
char *gentemp();

char *genlabel();

// Call with function whenever you want to get a new address
// address might replace char labels
int nextaddress();

// Function used for backaptching
/*
makelist ( i ) creates a new list containing only i , an index into the block of
instructions; makelist returns a pointer to the newly created list.*/
struct jump_indices *makelist(int i);

/*
merge ( q 1 , q 2 ) concatenates the lists pointed to by q 1 and q 2 , and returns
a pointer to the concatenated list.*/
struct jump_indices *merge(struct jump_indices *q1, struct jump_indices *q2);

/*
backpatch ( q; i ) inserts i as the target label for each of the instructions on
the list pointed to by p .
*/
void backpatch(quadruplets_node quads[], int length, struct jump_indices *q, int to);

// swap instruction positions
void migrate(quadruplets_node quads[], int i1, int i2, int j1, int j2);

void scheduled(struct jump_indices *p);
#endif
