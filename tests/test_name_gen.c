#include <stdio.h>
#include "semantic.h"

int main(int argc, char const *argv[])
{
    printf("%s\n", gentemp());
    printf("%s\n", gentemp());
    printf("%s\n", gentemp());
    printf("%s\n", genlabel());
    printf("%s\n", genlabel());

    printf("%s\n", genlabel());
    return 0;
}
