#ifndef SYMTABLE_H
#define SYMTABLE_H
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TRUE 1
#define FALSE 0

// define symtablenode

// the column
typedef struct AttrNode
{
    char *name;
    char *val;
    struct AttrNode *next;
} AttrNode;

// our rows of symtable
typedef struct SymTableNode
{
    int entryType; // concerns macro (token id)
    // char *entryName;
    struct SymTableNode *next; // next row
    AttrNode *rootAttr;        // the beginning of the columns
    AttrNode *tailAttr;        // the last col
    int numOfAttrs;

} SymTableNode;

// Symbtable maintainer
typedef struct SymTable
{
    SymTableNode *root;
    SymTableNode *tail;
    int currentSize;
} SymTable;

SymTable *allocateSymTable();                                    // Allocate new sym table
SymTableNode *insertNewEntry(SymTable *symtable, int entryType); // insert new row
SymTableNode *lookup(SymTable *symtable, int entryType);         // row based search

// TODO: // TODO: reimplement to get attr by index
void set_attr(SymTable* symtable , int index, char *name, char *val);

// Not required for now
// void set_attr(SymTableNode *entry, char *name, char *val); // add cell to a defined row

// TODO: reimplement to get attr by index
char *get_attr(SymTable* symtable , int index, char *name);

// Not required for now
// char *get_attr(SymTableNode *entry, char *name); // get info from col

// delete
void freeUpEntryAttr(SymTableNode *entry);
void freeUpSymTable(SymTable *symtable);

// NEW DEFINED FUNCTIONS
// insert a new row in specific place
SymTableNode* insertEntryByIndex(SymTable *symtable, int index, int entryType);

SymTableNode *getEntryByIndex(SymTable* symtable , int index );
#endif