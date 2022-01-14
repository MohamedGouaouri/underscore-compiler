#include "semantic.h"

char *gentemp()
{
    static size_t id;
    (char *)alloca(sizeof(char));
    char *base_name = (char *)alloca((MAXSTRING + 1) * sizeof(char));
    char *num_str = (char *)alloca((MAXSTRING + 1) * sizeof(char));
    base_name[0] = 'T';
    for (size_t i = 1; i <= MAXSTRING; i++)
    {
        base_name[i] = '\0';
        num_str[i] = '\0';
    }
    sprintf(num_str, "%d", id);
    id = id + 1;
    return strncat(base_name, num_str, MAXSTRING);
}

char *genlabel()
{
    static size_t id;
    (char *)alloca(sizeof(char));
    char *base_name = (char *)alloca((MAXSTRING + 1) * sizeof(char));
    char *num_str = (char *)alloca((MAXSTRING + 1) * sizeof(char));
    base_name[0] = 'L';
    for (size_t i = 1; i <= MAXSTRING; i++)
    {
        base_name[i] = '\0';
        num_str[i] = '\0';
    }
    sprintf(num_str, "%d", id);
    id = id + 1;
    return strncat(base_name, num_str, MAXSTRING);
}

int nextaddress()
{
    static int id;
    id++;
    return id;
}