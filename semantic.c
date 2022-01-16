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

struct jump_indices *makelist(int i)
{
    struct jump_indices *list = (struct jump_indices *)malloc(sizeof(struct jump_indices));
    list->index = i;
    list->next = NULL;
    return list;
}

struct jump_indices *merge(struct jump_indices *q1, struct jump_indices *q2)
{
    if (q1 != NULL)
    {
        struct jump_indices *prev = q1;
        struct jump_indices *ptr = q1;
        while (ptr->next != NULL)
        {
            prev = ptr;
            ptr = ptr->next;
        }
        prev->next = q2;
        return q1;
    }
    else
    {
        return q2;
    }
}

void backpatch(quadruplets_node quads[], int length, struct jump_indices *q, int to)
{
    // update by index

    if (to <= length)
    {

        while (q != NULL)
        {
            int where = q->index;
            quads[where].op1->value.label = to;
            printf("Chaining done to: %d\n", where);
            q = q->next;
        }
    }
}