#include "symtable.h"

 SymTable *allocateSymTable()
 {
     SymTable *symtable = (SymTable *)malloc(sizeof(SymTable));
     // SymTableNode *root = (SymTableNode *)malloc(sizeof(SymTableNode));
     // SymTableNode *tail = root;
     // root->entryId = 0;
     symtable->root = NULL;
     symtable->tail = NULL;
//     symtable->lastEntryId = -1;
     symtable->currentSize = 0;
     return symtable;
 }

SymTableNode *insertNewEntry(SymTable *symtable, int entryType){
     if (symtable->currentSize == 0)
     {
         // empty table
         SymTableNode *root = (SymTableNode *)malloc(sizeof(SymTableNode));
         SymTableNode *tail = root;
//         root->entryId = 0;
//         root->entryName = name;
         root->next = NULL;
         root->numOfAttrs = 0;
         root->rootAttr = NULL;
         root->tailAttr = NULL;
         root->entryType = entryType;
         symtable->root = root;
         symtable->tail = tail;
//         symtable->lastEntryId = 0;
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
//         newEntry->entryId = symtable->lastEntryId++;
//         newEntry->entryName = name;
         newEntry->next = NULL;
         newEntry->numOfAttrs = 0;
         newEntry->rootAttr = NULL;
         newEntry->tailAttr = NULL;
         newEntry->entryType = entryType;
         // create connection
         tail->next = newEntry;
         // change tail
         symtable->tail = newEntry;
         symtable->currentSize++;
         return newEntry;
     }
 }

// SymTableNode *lookup(SymTable *symtable, char *name)
// {
//     SymTableNode *root = symtable->root;
//     SymTableNode *p = root;
//     int nameFound = FALSE;
//     while (p != NULL && !nameFound)
//     {
//         if (strcmp(p->entryName, name) == 0)
//         {
//             nameFound = TRUE;
//             return p;
//         }
//         p = p->next;
//     }
//     return p;
// }

// void set_attr(SymTableNode *entry, char *name, char *val)
// {

//     if (entry->numOfAttrs == 0)
//     {
//         AttrNode *rootAttr = (AttrNode *)malloc(sizeof(AttrNode));
//         rootAttr->name = name;
//         rootAttr->val = val;
//         rootAttr->next = NULL;
//         entry->rootAttr = rootAttr;
//         entry->tailAttr = rootAttr;
//         entry->numOfAttrs++;
//     }
//     else
//     {
//         AttrNode *tailAttr = entry->tailAttr;
//         // create a new attr entry
//         AttrNode *newAttr = (AttrNode *)malloc(sizeof(AttrNode));
//         newAttr->name = name;
//         newAttr->val = val;
//         newAttr->next = NULL;

//         // setup chaining
//         tailAttr->next = newAttr;
//     }
// }

// char *get_attr(SymTableNode *entry, char *name)
// {
//     if (entry->numOfAttrs > 0)
//     {
//         // search for an attr of name `name`
//         AttrNode *root = entry->rootAttr;
//         AttrNode *p = root;
//         int attrFound = FALSE;
//         while (p != NULL && !attrFound)
//         {
//             if (strcmp(p->name, name) == 0)
//             {
//                 attrFound = TRUE; // would be deleted
//                 return p->val;
//             }
//             p = p->next;
//         }
//         return p->val;
//     }
// }

// void freeUpEntryAttr(SymTableNode *entry)
// {
//     AttrNode *root = entry->rootAttr;
//     AttrNode *p = root;
//     AttrNode *prev = root;
//     AttrNode *tail = entry->tailAttr;

//     while (p != tail)
//     {
//         p = p->next;
//         free(prev);
//         entry->numOfAttrs--;
//         prev = p;
//     }
//     free(p);
//     entry->numOfAttrs--;
// }
// void freeUpSymTable(SymTable *symtable)
// {
//     SymTableNode *root = symtable->root;
//     SymTableNode *p = root;
//     SymTableNode *prev = root;
//     SymTableNode *tail = symtable->tail;
//     while (p != tail)
//     {
//         p = p->next;
//         // free attr
//         freeUpEntryAttr(prev);
//         // free node
//         free(prev);
//         symtable->lastEntryId--;
//         symtable->currentSize--;
//         prev = p;
//     }
//     free(p);
//     symtable->lastEntryId--;
//     symtable->currentSize--;
// }


// Sid Ahmed code

SymTableNode *getEntryByIndex(SymTable* symtable , int index ){
    SymTableNode *target = symtable->root;
    int cpt=0;
    while(cpt!=index){
        // we didnt reach the tail yet
        if(target !=symtable->tail){
            target = target->next;
        }else{
            target=NULL;
            break;
        }
        cpt++;
    }

    return target;
}


SymTableNode* insertEntryByIndex(SymTable *symtable, int index, int entryType){
    SymTableNode* root = symtable->root;
    SymTableNode* tail = symtable->tail;
    SymTableNode* beforeInsert = NULL;
    SymTableNode *newEntry;

    // negatove index
    if(index < 0){
        printf("\nERROR : NEGATIVE INDEX !\n");
        return NULL;
    }
    // overflow
    if(index >= symtable->currentSize){
        printf("\nERROR !CANNOT INSERT AFTER THE TAIL !\n");
        return NULL;
    }
    // the new root
    else if(index==0){
        newEntry= (SymTableNode *)malloc(sizeof(SymTableNode));
        newEntry->entryType = entryType;
        newEntry->next = root;
        symtable->root = newEntry;
        symtable->currentSize++;
        return newEntry;
    }
    // in the bottom ( last line )
    else if (index == symtable->currentSize-1){
        newEntry = insertNewEntry(symtable, index);
        return newEntry;
    }
    // in the middle
    else{
        newEntry= (SymTableNode *)malloc(sizeof(SymTableNode));
        newEntry->entryType = entryType;
        SymTableNode* previousNewEntry = getEntryByIndex(symtable, index - 1);
        SymTableNode* nextNewEntry= getEntryByIndex(symtable,index);
        previousNewEntry->next = newEntry;
        newEntry->next = nextNewEntry;
        symtable->currentSize++;
        return newEntry;
    }
}

void printEntryTypesList(SymTable* symtable){
    SymTableNode* current = symtable->root;
    printf("\n");
    while(current != NULL){
        printf("%d ->", current->entryType);
        current = current->next;
    }
    printf("NULL\n");

}