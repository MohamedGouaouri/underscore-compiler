#include <stdio.h>
#include "quadruplets.h"

int main() {
    printf("%s\n", quadruplets_operators_names[BE]);
    // CREATE THE QUADRUPLETS TABLE
    quadruplets_table *quadrupletsTable = allocate_quadruplets_table();
    int x;
    int y;
    // CREATE OPERAND 1 TYPE EMPTY
    union operandValue* operand1_value= create_operand_value();
    operand1_value->empty = 1;
    // CREATE OPERAND 2 TYPE INTEGER
    union operandValue* operand2_value= create_operand_value();
    operand2_value->integer = 55;
    // CREATED A QUADRUPLET WITH THESE TWO OPERANDS
    quadruplets_node* quad = create_quadruplet(quadrupletsTable->currentSize, quadruplets_operators_names[BE],
                                               create_operand(Empty , operand1_value), create_operand(Integers , operand2_value), &x);
    // ADD IT TO THE TABLE
    add_quadruplet(&quadrupletsTable, quad);
    // CREATE OPERAND 1 TYPE VARIABLE NAME
    operand1_value = create_operand_value();
    strcpy(operand1_value->variable , "X");
    // CREATE OPERAND 2 TYPE LABEL
    operand2_value = create_operand_value();
    strcpy(operand2_value->label, "LABEL");
    // CREATED A QUADRUPLET WITH THESE TWO OPERANDS
    quad = create_quadruplet(quadrupletsTable->currentSize, quadruplets_operators_names[AFFECT], create_operand(Variable , operand1_value),
                             create_operand(Labels , operand2_value), &y);
    // ADD IT TO THE TABLE
    add_quadruplet(&quadrupletsTable, quad);
//    quad = create_quadruplet(quadrupletsTable->currentSize, quadruplets_operators_names[MULTIPLY], "b", "y", &x);
//    add_quadruplet(&quadrupletsTable, quad);

    print_quadruplets_table(quadrupletsTable);
    return 0;
}
