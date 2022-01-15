//
// Created by pc on 12/01/2022.
//

#ifndef QUADRUPLETS_H
#define QUADRUPLETS_H
#include "stdio.h"
#include "stdlib.h"
#include "string.h"
enum  quadruplets_operators {
    PLUS ,
    MINUS ,
    DIVIDE ,
    MULTIPLY,
    BR,
    BE ,
    BNE,
    BL ,
    BLE ,
    BG ,
    BGE ,
    BZ ,
    BNZ ,
    AFFECT ,
    ARRAY_INDEX
};

static const char * const quadruplets_operators_names[] = {
        [PLUS] ="+" ,
        [MINUS]="-" ,
        [DIVIDE]="/" ,
        [MULTIPLY]="*",
        [BR]="BR",
        [BE]="BE" ,
        [BNE] = "BNE",
        [BL] = "BL" ,
        [BLE] = "BLE" ,
        [BG] = "BG" ,
        [BGE] ="BGE" ,
        [BZ] = "BZ" ,
        [BNZ] ="BNZ" ,
        [AFFECT] =":=" ,
        [ARRAY_INDEX] = "[]"
};

enum operandCategory { Empty, Variable, Integers, Labels };
union operandValue {
    int empty;
    char variable[255];
    int integer;
    char label[255];
    void *p;
};
typedef struct operand {
    enum operandCategory category;
    union operandValue value;
} operand;

typedef struct quadruplets_node
{
    int label;
    char* operator ;
    operand* op1;
    operand* op2;
    int* Tampon ; // Address to the tompon in their symtables
    struct quadruplets_node* next;

} quadruplets_node;

typedef struct quadruplets_table{
    quadruplets_node* root ;
    quadruplets_node* tail;
    int currentSize;
}quadruplets_table;

//quadruplets_node* create_quadruplet(    int label, char operator[255] ,char op1[255],char op2[255],int* Tampon);
//void add_quadruplet( quadruplets_table* quadrupletsTable , quadruplets_node* node);
//void modify_quadruplet (quadruplets_table quadrupletsTable);
//quadruplets_table* allocate_quadruplets_table();
//void print_quadruplets_table(quadruplets_table* quadrupletsTable);
union operandValue* create_operand_value(){
    union operandValue* operand_value = (union  operandValue*)malloc(sizeof( union operandValue));
    return operand_value;
}

operand* create_operand(enum operandCategory category , union  operandValue* value){
    operand* new_operand = (operand *)malloc(sizeof(operand));
    new_operand->category = category;
    switch (category) {
        case Empty:
            new_operand->value.empty = 1;
            break;
        case Variable:
            strcpy(new_operand->value.variable , value->variable);
            break;
        case Integers:
            new_operand->value.integer = value->integer;
            break;
        case Labels:
            strcpy(new_operand->value.label, value->label);
            break;
        default:
            break;
    }
    return new_operand;
}

void print_operand( operand* the_operand){
    switch (the_operand->category) {
        case Empty:
            printf(" ,");
            break;
        case Variable:
            printf("%s ,", the_operand->value.variable);
            break;
        case Integers:
            printf("%d ,", the_operand->value.integer);
            break;
        case Labels:
            printf("%s ,", the_operand->value.label);
            break;
        default:
            break;
    }
}

quadruplets_node* create_quadruplet(int label,char operator[255]  ,operand* op1 ,operand*  op2,int* Tampon){
    quadruplets_node* quadrupletsNode = (quadruplets_node *)malloc(sizeof(quadruplets_node));
    quadrupletsNode->label=label;
    quadrupletsNode->operator=operator;
    quadrupletsNode->op1 = op1;
    quadrupletsNode->op2 = op2;
    quadrupletsNode->Tampon = Tampon;
    quadrupletsNode->next = NULL;
    return quadrupletsNode;

}

quadruplets_table* allocate_quadruplets_table()
{
    quadruplets_table * quadrupletsTable = (quadruplets_table *)malloc(sizeof(quadruplets_table));
    quadrupletsTable->root = NULL;
    quadrupletsTable->tail = NULL;
    quadrupletsTable->currentSize = 0;
    return quadrupletsTable;
}

void *add_quadruplet(quadruplets_table** quadrupletsTable , quadruplets_node* quadrupletsNode)
{
    printf("Gonna insert quad with label : %d \n", quadrupletsNode->label);
    quadrupletsNode->next = NULL;
    if ((*quadrupletsTable)->currentSize == 0)
    {
        // empty table

        (*quadrupletsTable)->root = quadrupletsNode;
        (*quadrupletsTable)->tail = quadrupletsNode;
        (*quadrupletsTable)->currentSize = 1;

//        return quadrupletsTable->root;
    }
    else
    {
        quadruplets_node * currentTail = (*quadrupletsTable)->tail;
        currentTail->next = quadrupletsNode;
        (*quadrupletsTable)->tail = quadrupletsNode;

        (*quadrupletsTable)->currentSize++;
    }
}

void print_quadruplets_node(quadruplets_node* quadrupletsNode){
    printf(" %d - ( %s , ", quadrupletsNode->label, quadrupletsNode->operator);
    print_operand(quadrupletsNode->op1);
    print_operand(quadrupletsNode->op2);
    printf(" %d )\n" , *quadrupletsNode->Tampon);
}



void print_quadruplets_table(quadruplets_table* quadrupletsTable){
    quadruplets_node *p = quadrupletsTable->root;
    while (p!= NULL){
//        printf("%d", p->label);
        print_quadruplets_node(p);
        p = p->next;
    }
}
#endif
