
#include "quadruplets.h"
union operandValue *create_operand_value()
{
    union operandValue *operand_value = (union operandValue *)malloc(sizeof(union operandValue));
    return operand_value;
}

operand *create_operand(enum operandCategory category, union operandValue *value)
{
    operand *new_operand = (operand *)malloc(sizeof(operand));
    new_operand->category = category;
    switch (category)
    {
    case Empty:
        new_operand->value.empty = 1;
        break;
    case Variable:
        strcpy(new_operand->value.variable, value->variable);
        break;
    case Integers:
        new_operand->value.integer = value->integer;
        break;
    case Labels:
        new_operand->value.label = value->label;
        break;
    default:
        break;
    }
    return new_operand;
}

void print_operand(operand *the_operand)
{
    switch (the_operand->category)
    {
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
        printf("%d ,", the_operand->value.label);
        break;
    default:
        break;
    }
}

quadruplets_node *create_quadruplet(int label, char operator[255], operand *op1, operand *op2, operand *result)
{
    quadruplets_node *quadrupletsNode = (quadruplets_node *)malloc(sizeof(quadruplets_node));
    quadrupletsNode->label = label;
    quadrupletsNode->operator= operator;
    quadrupletsNode->op1 = op1;
    quadrupletsNode->op2 = op2;
    // strcpy(quadrupletsNode->Tampon, Tampon);
    quadrupletsNode->result = result;
    quadrupletsNode->next = NULL;
    return quadrupletsNode;
}

quadruplets_table *allocate_quadruplets_table()
{
    quadruplets_table *quadrupletsTable = (quadruplets_table *)malloc(sizeof(quadruplets_table));
    quadrupletsTable->root = NULL;
    quadrupletsTable->tail = NULL;
    quadrupletsTable->currentSize = 0;
    return quadrupletsTable;
}

void *add_quadruplet(quadruplets_table **quadrupletsTable, quadruplets_node *quadrupletsNode)
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
        quadruplets_node *currentTail = (*quadrupletsTable)->tail;
        currentTail->next = quadrupletsNode;
        (*quadrupletsTable)->tail = quadrupletsNode;

        (*quadrupletsTable)->currentSize++;
    }
}

void print_quadruplets_node(quadruplets_node *quadrupletsNode)
{
    printf(" %d - ( %s , ", quadrupletsNode->label, quadrupletsNode->operator);
    print_operand(quadrupletsNode->op1);
    print_operand(quadrupletsNode->op2);

    print_operand(quadrupletsNode->result);
    printf(")\n");
}

void print_quadruplets_table(quadruplets_table *quadrupletsTable)
{
    quadruplets_node *p = quadrupletsTable->root;
    while (p != NULL)
    {
        //        printf("%d", p->label);
        print_quadruplets_node(p);
        p = p->next;
    }
}