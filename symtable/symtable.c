#include "symtable.h"

SymTable *allocateSymTable()
{
    SymTable *symtable = (SymTable *)malloc(sizeof(SymTable));
    symtable->root = NULL;
    symtable->tail = NULL;
    symtable->currentSize = 0;
    return symtable;
}

SymTableNode *insertNewEntry(SymTable *symtable, int entryType)
{
    if (symtable->currentSize == 0)
    {
        // empty table
        SymTableNode *root = (SymTableNode *)malloc(sizeof(SymTableNode));
        SymTableNode *tail = root;
        root->entryType = entryType;
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
        // get last node
        SymTableNode *tail = symtable->tail;
        // create new Entry
        SymTableNode *newEntry = (SymTableNode *)malloc(sizeof(SymTableNode));
        newEntry->entryType = entryType;
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

SymTableNode *lookup(SymTable *symtable, int entryType)
{
    SymTableNode *root = symtable->root;
    SymTableNode *p = root;
    while (p != NULL)
    {
        if (p->entryType == entryType)
        {
            return p;
        }
        p = p->next;
    }
    return p;
}

void set_attr(int index, char *name, char *val)
{
    SymTableNode *entry = getEntryByIndex(index);
    if (entry->numOfAttrs == 0)
    {
        AttrNode *rootAttr = (AttrNode *)malloc(sizeof(AttrNode));
        rootAttr->name = name;
        rootAttr->val = val;
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
        newAttr->name = name;
        newAttr->val = val;
        newAttr->next = NULL;

        // setup chaining
        tailAttr->next = newAttr;
    }
}

char *get_attr(int index, char *name)
{
    SymTableNode *entry = getEntryByIndex(index);
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