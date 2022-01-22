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
    struct jump_indices *merge_result = (struct jump_indices *)malloc(sizeof(struct jump_indices));
    struct jump_indices *p = merge_result;
    struct jump_indices *p1 = q1;
    struct jump_indices *p2 = q2;
    struct jump_indices *next;
    if (q1 == NULL && q2 == NULL)
    {
        return NULL;
    }

    while (p1 != NULL)
    {
        p->index = p1->index;
        p1 = p1->next;
        if (p1 != NULL)
        {

            next = (struct jump_indices *)malloc(sizeof(struct jump_indices));
            p->next = next;
            p = p->next;
        }
    }
    next = (struct jump_indices *)malloc(sizeof(struct jump_indices));
    p->next = next;
    p = p->next;
    while (p2 != NULL)
    {
        p->index = p2->index;
        p2 = p2->next;
        if (p2 != NULL)
        {
            next = (struct jump_indices *)malloc(sizeof(struct jump_indices));
            p->next = next;
            p = p->next;
        }
    }
    // p->next = NULL;
    return merge_result;

    // if (q1 != NULL)
    // {
    //     merge_result = q1;
    //     struct jump_indices *prev = q1;
    //     struct jump_indices *ptr = q1;
    //     while (ptr->next != NULL)
    //     {
    //         prev = ptr;
    //         ptr = ptr->next;
    //     }
    //     prev->next = q2;
    //     return q1;
    // }
    // else
    // {
    //     merge_result = q2;
    //     return q2;
    // }
}

void backpatch(quadruplets_node quads[], int length, struct jump_indices *q, int to)
{
    // update by index
    struct jump_indices *p = q;

    if (to <= length)
    {

        while (p != NULL)
        {
            int where = p->index;
            if (quads[where].op1->value.label == -1)
            {
                quads[where].op1->value.label = to;
            }
            p = p->next;
        }
    }
}

void migrate(quadruplets_node quads[], int i1, int i2, int j1, int j2)
{
    // i2 must be equal to j1
    // quadruplets_node temp = quads[i];
    // quads[i] = quads[j];
    // quads[j] = temp;
    quadruplets_node part1[i2 - i1 + 1];
    quadruplets_node part2[j2 - j1 + 1];
    for (size_t i = 0; i < i2 - i1 + 1; i++)
    {
        part1[i] = quads[i1 + i];
    }

    for (size_t i = 0; i < j2 - j1 + 1; i++)
    {
        /* code */
        part2[i] = quads[j1 + i];
    }
    int j = i1;
    for (size_t i = 0; i < j2 - j1 + 1; i++)
    {
        quads[j] = part2[i];
        j++;
    }
    for (size_t i = 0; i < i2 - i1 + 1; i++)
    {
        /* code */
        quads[j] = part1[i];
        j++;
    }
}

void scheduled(struct jump_indices *p)
{
    while (p != NULL)
    {
        /* code */
        printf("%d -> ", p->index);
        p = p->next;
    }
    printf("NULL \n");
}