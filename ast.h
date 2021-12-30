#ifndef AST_H
#define AST_H

#include <stdlib.h>
#include <stdio.h>
#define MAX_CHILDREN 100

#define true 1
#define false 0
typedef int bool;

// token type
typedef enum ast_node_type
{
    AST_BLOC,
    AST_STATEMENT,
    AST_EXPRESSION,

    AST_IF,
    AST_ELSE,
    AST_ELIF,

    AST_FOR_LOOP,
    AST_WHILE_LOOP,
    AST_BREAK,
    AST_CONTINUE,

    AST_TRUE,
    AST_FALSE,
    AST_ID,

    AST_OPENPARENTHESIS,
    AST_CLOSEPARENTHESIS,

    // logical operations
    AST_EQUAL,
    AST_NONEQUAL,
    AST_AND,
    AST_OR,
    AST_NON,
    AST_INFERIOR,
    AST_SUPERIOR,
    AST_INFERIOREQUAL,
    AST_SUPERIOREQUAL,

    // Arithmetic operation
    AST_ADD,
    AST_SUB,
    AST_MULT,
    AST_DIV,
    AST_MOD,
    AST_POWER,

    AST_ASSIGNMENT,
    AST_RETURN,

    // constants
    AST_INTEGER,
    AST_REAL,
    AST_STRING,

    // For functions
    AST_FUNCTION,
    AST_FUNCPARAM,
    AST_FUNCCALL,

    AST_POINTERVALUE,
    AST_ADDRESSVALUE
} ast_node_type;

// ast node value
typedef union ast_node_val
{
    int ival;     /* Value of integer values */
    double rval;  /* Value of real values*/
    char *string; /* Value string */
} ast_node_val;
// the structure of an ast node
typedef struct ast_node
{
    int id; // for dataviz
    char *label;

    ast_node_val node_val;
    ast_node_type node_type;
    int index; // used to track the occupied positions in childre field
    struct ast_node *parent;
    struct ast_node *children[MAX_CHILDREN];

} ast_node;

typedef struct ast
{
    int number_of_nodes;
    ast_node *root;
} ast;

/*
 * Build new ast tree
 */
ast *build_ast(ast_node_type node_type);
ast_node *add_child(ast *ast, ast_node *node, ast_node_type node_type);
ast_node *get_child(ast_node *node, int index);
void set_val(ast_node *node, ast_node_val val);

bool is_leaf(ast_node *node);
size_t number_of_children(ast_node *node);
void destroy_ast(ast_node *root, int num_of_children);

void main_ast_print(ast *tree, FILE *stream);
void aux_ast_print(ast_node *node, FILE *stream);

#endif