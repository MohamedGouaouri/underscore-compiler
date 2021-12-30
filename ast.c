#include "ast.h"

char *stringFromNodeType(ast_node_type f)
{
    char *strings[] = {
        "AST_BLOC",
        "AST_STATEMENT",
        "AST_EXPRESSION",

        "AST_IF",
        "AST_ELSE",
        "AST_ELIF",

        "AST_FOR_LOOP",
        "AST_WHILE_LOOP",
        "AST_BREAK",
        "AST_CONTINUE",

        "AST_TRUE",
        "AST_FALSE",
        "AST_ID",

        "AST_OPENPARENTHESIS",
        "AST_CLOSEPARENTHESIS",

        // logical operations
        "AST_EQUAL",
        "AST_NONEQUAL",
        "AST_AND",
        "AST_OR",
        "AST_NON",
        "AST_INFERIOR",
        "AST_SUPERIOR",
        "AST_INFERIOREQUAL",
        "AST_SUPERIOREQUAL",

        // Arithmetic operation
        "AST_ADD",
        "AST_SUB",
        "AST_MULT",
        "AST_DIV",
        "AST_MOD",
        "AST_POWER",

        "AST_ASSIGNMENT",
        "AST_RETURN",

        // constants
        "AST_INTEGER",
        "AST_REAL",
        "AST_STRING",

        // For functions
        "AST_FUNCTION",
        "AST_FUNCPARAM",
        "AST_FUNCCALL",

        "AST_POINTERVALUE",
        "AST_ADDRESSVALUE",
    };

    return strings[f];
}

ast *build_ast(ast_node_type node_type)
{
    ast *tree = (ast *)malloc(sizeof(ast));
    ast_node *root = (ast_node *)malloc(sizeof(ast_node));

    tree->root = root;
    tree->root->parent = NULL;
    tree->root->node_type = node_type;
    tree->root->index = -1; // initially it's a leaf node
    tree->root->label = stringFromNodeType(node_type);
    for (int i = 0; i < MAX_CHILDREN; i++)
    {
        tree->root->children[i] = NULL;
    }
    tree->number_of_nodes = 1;
    tree->root->id = 1;
    return tree;
}

ast_node *add_child(ast *tree, ast_node *node, ast_node_type node_type)
{
    int where = node->index + 1;
    ast_node *new_node = (ast_node *)malloc(sizeof(ast_node));
    // increase the number of nodes
    tree->number_of_nodes += 1;

    new_node->index = -1; // added as a leaf node
    new_node->node_type = node_type;
    new_node->label = stringFromNodeType(node_type);

    for (int i = 0; i < MAX_CHILDREN; i++)
    {
        new_node->children[i] = NULL;
    }

    node->index = node->index + 1;
    node->children[where] = new_node; // linking
    new_node->id = tree->number_of_nodes;
    new_node->parent = node;
    return new_node;
}

void set_val(ast_node *node, ast_node_val val)
{
    // node values are only for string, int and reals
    node->node_val = val;
}

ast_node *get_child(ast_node *node, int index)
{
    return node->children[index];
}

size_t number_of_children(ast_node *node)
{
    return node->index + 1;
}

bool is_leaf(ast_node *node)
{
    return node->index == -1 ? true : false;
}

void destroy_ast(ast_node *node, int num_of_children)
{
    if (is_leaf(node))
    {
        free(node);
        return;
    }

    // recursive node destruction
    for (int i = 0; i < num_of_children; i++)
    {
        destroy_ast(node->children[i], node->children[i]->index + 1);
    }
}

void aux_ast_print(ast_node *node, FILE *stream)
{
    if (is_leaf(node))
    {
        fprintf(stream, "    %d[label=%s];\n", node->id, node->label);
        return;
    }

    for (int i = 0; i < node->index + 1; i++)
    {
        fprintf(stream, "    %d[label=%s];\n", node->id, node->label);
        fprintf(stream, "    %d -> %d;\n", node->id, node->children[i]->id);
        aux_ast_print(node->children[i], stream);
    }
}

void main_ast_print(ast *tree, FILE *stream)
{
    fprintf(stream, "digraph AST {\n");
    fprintf(stream, "    node [fontname=\"Arial\"];\n");

    if (!tree)
        fprintf(stream, "\n");
    else if (is_leaf(tree->root))
    {
        fprintf(stream, "    %d[label=%s];\n", tree->root->id, tree->root->label);
        fprintf(stream, "    %d;\n", tree->root->id);
    }
    else
        aux_ast_print(tree->root, stream);

    fprintf(stream, "}\n");
}