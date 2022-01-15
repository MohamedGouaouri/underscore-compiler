#include "symtable.h"

SymTable *allocateSymTable()
{
    SymTable *symtable = (SymTable *)malloc(sizeof(SymTable));
    symtable->root = NULL;
    symtable->tail = NULL;
    symtable->currentSize = 0;
    return symtable;
}

SymTableNode *insertNewEntry(SymTable *symtable, int symType, char *symName)
{

    // The symbol does not exist
    if (symtable->currentSize == 0)
    {
        // empty table
        SymTableNode *root = (SymTableNode *)malloc(sizeof(SymTableNode));
        SymTableNode *tail = root;
        root->symType = symType;
        strcpy(root->symName, symName);
        root->next = NULL;
        root->numOfAttrs = 0;
        root->rootAttr = NULL;
        root->tailAttr = NULL;
        symtable->root = root;
        symtable->tail = tail;
        symtable->currentSize++;
        return root;
    }
    else
    {
        // non empty table
        // check if the symName exists

        SymTableNode *foundNode = lookup(symtable, symName);
        if (foundNode != NULL)
        {
            return foundNode;
        }
        // get last node
        SymTableNode *tail = symtable->tail;
        // create new Entry
        SymTableNode *newEntry = (SymTableNode *)malloc(sizeof(SymTableNode));
        newEntry->symType = symType;
        strcpy(newEntry->symName, symName);
        newEntry->next = NULL;
        newEntry->numOfAttrs = 0;
        newEntry->rootAttr = NULL;
        newEntry->tailAttr = NULL;
        // create connection
        tail->next = newEntry;
        // change tail
        symtable->tail = newEntry;
        symtable->currentSize++;
        return newEntry;
    }
}

SymTableNode *lookup(SymTable *symtable, char *symName)
{
    SymTableNode *root = symtable->root;
    SymTableNode *p = root;
    while (p != NULL)
    {
        if (strcmp(p->symName, symName) == 0)
        {
            return p;
        }
        p = p->next;
    }
    return p;
}

void deleteEntry(SymTable *symtable, char *symName)
{
    SymTableNode *node_todelete = lookup(symtable, symName);

    if (node_todelete == NULL)
        return;

    SymTableNode *p = symtable->root, *previous, *next;
    next = node_todelete->next;
    while (p != NULL)
    {
        if (p->next == node_todelete)
        {
            previous = p;
            break;
        }
        p = p->next;
    }

    previous->next = next;
    if (symtable->tail == node_todelete)
        symtable->tail = previous;
    freeUpEntryAttr(node_todelete);
    free(node_todelete);
}

void set_attr(SymTableNode *entry, char *name, char *val)
{
    if (entry != NULL)
    {
        if (entry->numOfAttrs == 0)
        {
            AttrNode *rootAttr = (AttrNode *)malloc(sizeof(AttrNode));
            strcpy(rootAttr->name, name);
            strcpy(rootAttr->val, val);
            rootAttr->next = NULL;
            entry->rootAttr = rootAttr;
            entry->tailAttr = rootAttr;
            entry->numOfAttrs++;
        }
        else
        {
            AttrNode *tailAttr = entry->tailAttr;
            // create a new attr entry
            AttrNode *newAttr = (AttrNode *)malloc(sizeof(AttrNode));
            strcpy(newAttr->name, name);
            strcpy(newAttr->val, val);
            newAttr->next = NULL;

            // setup chaining
            tailAttr->next = newAttr;
            entry->tailAttr = newAttr;
        }
    }
}

char *get_attr(SymTableNode *entry, char *name)
{
    if (entry != NULL)
    {
        if (entry->numOfAttrs > 0)
        {
            // search for an attr of name `name`
            AttrNode *root = entry->rootAttr;
            AttrNode *p = root;
            while (p != NULL)
            {
                if (strcmp(p->name, name) == 0)
                {
                    return p->val;
                }
                p = p->next;
            }
            return p->val;
        }
    }
}

// void setAttrByIndex(SymTable *symTable, int index, char *name, char *val)
// {
//     SymTableNode *entry = getEntryByIndex(symTable, index);
//     if (entry != NULL)
//     {
//         if (entry->numOfAttrs == 0)
//         {
//             AttrNode *rootAttr = (AttrNode *)malloc(sizeof(AttrNode));
//             strncpy(rootAttr->name, name, 254);
//             strncpy(rootAttr->val, val, 254);
//             rootAttr->next = NULL;
//             entry->rootAttr = rootAttr;
//             entry->tailAttr = rootAttr;
//             entry->numOfAttrs++;
//         }
//         else
//         {
//             AttrNode *tailAttr = entry->tailAttr;
//             // create a new attr entry
//             AttrNode *newAttr = (AttrNode *)malloc(sizeof(AttrNode));
//             strncpy(newAttr->name, name, 254);
//             strncpy(newAttr->val, val, 254);
//             newAttr->next = NULL;

//             // setup chaining
//             tailAttr->next = newAttr;
//         }
//     }
// }

// char *getAttrByIndex(SymTable *symtable, int index, char *name)
// {
//     SymTableNode *entry = getEntryByIndex(symtable, index);
//     if (entry != NULL)
//     {
//         if (entry->numOfAttrs > 0)
//         {
//             // search for an attr of name `name`
//             AttrNode *root = entry->rootAttr;
//             AttrNode *p = root;
//             while (p != NULL)
//             {
//                 if (strcmp(p->name, name) == 0)
//                 {
//                     return p->val;
//                 }
//                 p = p->next;
//             }
//             return p->val;
//         }
//     }
// }

// SymTableNode *getEntryByIndex(SymTable *symtable, int index)
// {
//     SymTableNode *target = symtable->root;
//     int cpt = 0;
//     while (cpt != index)
//     {
//         // we didnt reach the tail yet
//         if (target != symtable->tail)
//         {
//             target = target->next;
//         }
//         else
//         {
//             target = NULL;
//             break;
//         }
//         cpt++;
//     }

//     return target;
// }

// SymTableNode *insertEntryByIndex(SymTable *symtable, int index, int symType)
// {
//     SymTableNode *root = symtable->root;
//     SymTableNode *tail = symtable->tail;
//     SymTableNode *beforeInsert = NULL;
//     SymTableNode *newEntry;

//     // negatove index
//     if (index < 0)
//     {
//         printf("\nERROR : NEGATIVE INDEX !\n");
//         return NULL;
//     }
//     // overflow
//     if (index >= symtable->currentSize)
//     {
//         printf("\nERROR !CANNOT INSERT AFTER THE TAIL !\n");
//         return NULL;
//     }
//     // the new root
//     else if (index == 0)
//     {
//         newEntry = (SymTableNode *)malloc(sizeof(SymTableNode));
//         newEntry->symType = symType;
//         newEntry->next = root;
//         symtable->root = newEntry;
//         symtable->currentSize++;
//         return newEntry;
//     }
//     // in the bottom ( last line )
//     else if (index == symtable->currentSize - 1)
//     {
//         newEntry = insertNewEntry(symtable, index);
//         return newEntry;
//     }
//     // in the middle
//     else
//     {
//         newEntry = (SymTableNode *)malloc(sizeof(SymTableNode));
//         newEntry->symType = symType;
//         SymTableNode *previousNewEntry = getEntryByIndex(symtable, index - 1);
//         SymTableNode *nextNewEntry = getEntryByIndex(symtable, index);
//         previousNewEntry->next = newEntry;
//         newEntry->next = nextNewEntry;
//         symtable->currentSize++;
//         return newEntry;
//     }
// }

void printSymTable(SymTable *symtable)
{
    SymTableNode *current = symtable->root;
    AttrNode *p;
    printf("\n");
    while (current != NULL)
    {
        p = current->rootAttr;
        printf("(%d | %s) → ", current->symType, current->symName);
        // printf("(%s | %s)\n", p->name, p->val);
        while (p != NULL)
        {
            printf("(%s : %s) → ", p->name, p->val);
            p = p->next;
        }
        printf("NULL\n");
        printf("↓\n");
        current = current->next;
    }
    printf("NULL\n");
}

void freeUpEntryAttr(SymTableNode *entry)
{
    AttrNode *root = entry->rootAttr;
    AttrNode *p = root;
    AttrNode *prev = root;
    AttrNode *tail = entry->tailAttr;

    while (p != tail)
    {
        p = p->next;
        free(prev);
        entry->numOfAttrs--;
        prev = p;
    }
    free(p);
    entry->numOfAttrs--;
}
void freeUpSymTable(SymTable *symtable)
{
    SymTableNode *root = symtable->root;
    SymTableNode *p = root;
    SymTableNode *prev = root;
    SymTableNode *tail = symtable->tail;
    while (p != tail)
    {
        p = p->next;
        // free attr
        freeUpEntryAttr(prev);
        // free node
        free(prev);
        symtable->currentSize--;
        prev = p;
    }
    free(p);
    symtable->currentSize--;
}

typedef int bool;
#define true 1
#define false 0
bool symbol_exists(SymTable *symtable, char *symName)
{
    return lookup(symtable, symName) == NULL ? false : true;
}
bool globalsymbol_exists(GlobalSymTable *gSymTable, char *symName)
{
    return lookup(gSymTable, symName) == NULL ? false : true;
}

/** Global SymTable **/

GlobalSymTable *allocateGlobalSymTable()
{
    GlobalSymTable *gSymTable = (GlobalSymTable *)malloc(sizeof(GlobalSymTable));
    gSymTable->head = NULL;
    gSymTable->tail = NULL;
    gSymTable->currentSize = 0;
    return gSymTable;
}

GlobalSymTableNode *insertNewGlobalEntry(GlobalSymTable *gSymTable, SymTable *symTable)
{

    if (gSymTable->currentSize == 0)
    {
        // empty table
        GlobalSymTableNode *head = (GlobalSymTableNode *)malloc(sizeof(GlobalSymTableNode));
        GlobalSymTableNode *tail = head;
        head->symTable = symTable;
        head->next = NULL;
        gSymTable->head = head;
        gSymTable->tail = tail;
        gSymTable->currentSize++;
        return head;
    }
    else
    {
        // non empty table
        // check if the symtable exists

        GlobalSymTableNode *foundNode = lookupGlobal(gSymTable, symTable->root->symName);
        if (foundNode != NULL)
        {
            return foundNode;
        }
        // get last node
        GlobalSymTableNode *tail = gSymTable->tail;
        // create new Entry
        GlobalSymTableNode *newEntry = (GlobalSymTableNode *)malloc(sizeof(GlobalSymTableNode));
        newEntry->symTable = symTable;
        newEntry->next = NULL;
        // create connection
        tail->next = newEntry;
        // change tail
        gSymTable->tail = newEntry;
        gSymTable->currentSize++;
        return newEntry;
    }
}

GlobalSymTableNode *lookupGlobal(GlobalSymTable *gSymTable, char *functionName)
{
    GlobalSymTableNode *head = gSymTable->head;
    GlobalSymTableNode *p = head;
    while (p != NULL)
    {
        if (strcmp(p->symTable->root->symName, functionName) == 0)
        {
            return p;
        }
        p = p->next;
    }
    return p;
}

void freeUpGlobalSymTable(GlobalSymTable *gSymTable)
{
    GlobalSymTableNode *head = gSymTable->head;
    GlobalSymTableNode *p = head;
    GlobalSymTableNode *prev = head;
    GlobalSymTableNode *tail = gSymTable->tail;
    while (p != tail)
    {
        p = p->next;
        // free node
        free(prev);
        gSymTable->currentSize--;
        prev = p;
    }
    free(p);
    gSymTable->currentSize--;
}

void printGlobalSymTable(GlobalSymTable *gSymTable)
{
    GlobalSymTableNode *current = gSymTable->head;
    printf("\n\n");
    while (current != NULL)
    {
        printSymTable(current->symTable);
        current = current->next;
    }
    printf("\n\n");
}

int getIndexOfSym(SymTable *symtable, char *name)
{
    SymTableNode *root = symtable->root;
    SymTableNode *p = root;
    int i = -1;
    while (p != NULL)
    {
        i++;
        if (strcmp(p->symName, name) == 0)
        {
            return i;
        }
        p = p->next;
    }
    return i;
}