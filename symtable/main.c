//
// Created by pc on 25/11/2021.
//
#include <stdio.h>
#include "symtable.c"

#define AFFECT 17
#define IF 34
#define ELSE 35
#define LOOP_FOR 65
#define LOOP_WHILE 66
//#include "symtableAtomic.h"

int main(){
    SymTable* symtable = allocateSymTable();
    insertNewEntry(symtable,LOOP_FOR);
    insertNewEntry(symtable, IF);
    insertNewEntry(symtable, AFFECT);
    insertNewEntry(symtable, ELSE);
    insertNewEntry(symtable, AFFECT);
    printf("Hello world");
    printEntryTypesList(symtable);
    // TEST get Entry By Index
    // Get the AFFECT
    SymTableNode* node = getEntryByIndex(symtable, 4);
    SymTableNode* nodeNull = getEntryByIndex(symtable, 55);
    if(node!=NULL){
        printf("4th SymtableNode entry type is : %d", node->entryType);
    }
    if(nodeNull!=NULL){
        printf("56th SymtableNode entry type is : %d", nodeNull->entryType);
    }
    printf("Insert Before the root\n");

    return 0;
}
