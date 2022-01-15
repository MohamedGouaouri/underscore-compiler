//
// Created by pc on 12/01/2022.
//

#ifndef QUADRUPLETS_H
#define QUADRUPLETS_H
#include "stdio.h"
#include "stdlib.h"
#include "string.h"
enum quadruplets_operators
{
    PLUS,
    MINUS,
    DIVIDE,
    MULTIPLY,
    BR,
    BE,
    BNE,
    BL,
    BLE,
    BG,
    BGE,
    BZ,
    BNZ,
    AFFECT,
    ARRAY_INDEX
};

static const char *const quadruplets_operators_names[] = {
    [PLUS] = "+",
    [MINUS] = "-",
    [DIVIDE] = "/",
    [MULTIPLY] = "*",
    [BR] = "BR",
    [BE] = "BE",
    [BNE] = "BNE",
    [BL] = "BL",
    [BLE] = "BLE",
    [BG] = "BG",
    [BGE] = "BGE",
    [BZ] = "BZ",
    [BNZ] = "BNZ",
    [AFFECT] = ":=",
    [ARRAY_INDEX] = "[]"};

enum operandCategory
{
    Empty,
    Variable,
    Integers,
    Labels
};
union operandValue
{
    int empty;
    char variable[255];
    int integer;
    // char label[255];
    int label;
    void *p;
};
typedef struct operand
{
    enum operandCategory category;
    union operandValue value;
} operand;

typedef struct quadruplets_node
{
    int label;
    char *operator;
    operand *op1;
    operand *op2;
    // int *Tampon; // Address to the tompon in their symtables
    operand *result;
    struct quadruplets_node *next;

} quadruplets_node;

typedef struct quadruplets_table
{
    quadruplets_node *root;
    quadruplets_node *tail;
    int currentSize;
} quadruplets_table;

// quadruplets_node* create_quadruplet(    int label, char operator[255] ,char op1[255],char op2[255],int* Tampon);
// void add_quadruplet( quadruplets_table* quadrupletsTable , quadruplets_node* node);
// void modify_quadruplet (quadruplets_table quadrupletsTable);
// quadruplets_table* allocate_quadruplets_table();
// void print_quadruplets_table(quadruplets_table* quadrupletsTable);
union operandValue *create_operand_value();

operand *create_operand(enum operandCategory category, union operandValue *value);

void print_operand(operand *the_operand);

quadruplets_node *create_quadruplet(int label, char operator[255], operand *op1, operand *op2, operand *result);

quadruplets_table *allocate_quadruplets_table();

void *add_quadruplet(quadruplets_table **quadrupletsTable, quadruplets_node *quadrupletsNode);

void print_quadruplets_node(quadruplets_node *quadrupletsNode);

void print_quadruplets_table(quadruplets_table *quadrupletsTable);
#endif
