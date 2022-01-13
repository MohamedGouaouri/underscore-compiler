#include <stdio.h>
#include "quadruplets.h"

int main() {
    printf("%s\n", quadruplets_operators_names[BE]);
    quadruplets_table *quadrupletsTable = allocate_quadruplets_table();
    int x;
    int y;
    quadruplets_node* quad = create_quadruplet(quadrupletsTable->currentSize, quadruplets_operators_names[BE], "a", "b", &x);
    add_quadruplet(&quadrupletsTable, quad);
    quad = create_quadruplet(quadrupletsTable->currentSize, quadruplets_operators_names[AFFECT], "d", "e", &y);
    add_quadruplet(&quadrupletsTable, quad);
    quad = create_quadruplet(quadrupletsTable->currentSize, quadruplets_operators_names[MULTIPLY], "b", "y", &x);
    add_quadruplet(&quadrupletsTable, quad);

    print_quadruplets_table(quadrupletsTable);
    return 0;
}
