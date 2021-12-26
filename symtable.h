#ifndef SYMTABLE_H
#define SYMTABLE_H
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define _NAME_ATTR "name"
#define _VALUE_ATTR "value"
#define _LENGTH_ATTR "length"
#define _TYPE_ATTR "type" // Might be useful later

// define symtablenode

typedef struct AttrNode
{
    char name[255];
    char val[255];
    struct AttrNode *next;
} AttrNode;

typedef struct SymTableNode
{
    int symType; // concerns macro (token id)
    char symName[255];
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

SymTable *allocateSymTable();                                                 // Allocate new sym table
SymTableNode *insertNewEntry(SymTable *symtable, int symType, char *symName); // insert new row
SymTableNode *lookup(SymTable *symtable, char *symName);                      // row based search

// sets attr by index
void setAttrByIndex(SymTable *symtable, int index, char *name, char *val);

// sets attr by node pointer
void set_attr(SymTableNode *entry, char *name, char *val); // add cell to a defined row

// gets attr by index
// char *getAttrByIndex(SymTable *symtable, int index, char *name);

// gets attr by node pointer
char *get_attr(SymTableNode *entry, char *name); // get info from col

// delete
void freeUpEntryAttr(SymTableNode *entry);
void freeUpSymTable(SymTable *symtable);

// NEW DEFINED FUNCTIONS
// insert a new row in specific place
SymTableNode *insertEntryByIndex(SymTable *symtable, int index, int symType);

SymTableNode *getEntryByIndex(SymTable *symtable, int index);

#endif
