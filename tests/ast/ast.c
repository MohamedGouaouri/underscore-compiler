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

        "AST_LOOP",
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

ast_node *build_ast(ast_node_type node_type)
{
    ast_node *root = (ast_node *)malloc(sizeof(ast_node));
    root->id = 1;
    root->node_type = node_type;
    root->index = -1; // initially it's a leaf node
    root->label = stringFromNodeType(node_type);
    for (int i = 0; i < MAX_CHILDREN; i++)
    {
        root->children[i] = NULL;
    }
    return root;
}

ast_node *add_child(ast_node *node, ast_node_type node_type)
{
    int where = node->index + 1;
    ast_node *new_node = (ast_node *)malloc(sizeof(ast_node));
    new_node->index = -1; // added as a leaf node
    new_node->node_type = node_type;
    new_node->label = stringFromNodeType(node_type);

    for (int i = 0; i < MAX_CHILDREN; i++)
    {
        new_node->children[i] = NULL;
    }

    node->index = node->index + 1;
    node->children[where] = new_node; // linking

    if (where == 0)
    {
        new_node->id = node->id + 1;
    }
    else
    {
        new_node->id = node->children[where - 1]->id + 1;
    }

    return new_node;
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

    // recursive node distruction
    for (int i = 0; i < num_of_children; i++)
    {
        destroy_ast(node->children[i], node->children[i]->index + 1);
    }
}

void aux_ast_print(ast_node *node, FILE *stream, char *label)
{
    if (is_leaf(node))
    {
        fprintf(stream, "    %d[label=%s];\n", node->id, label);
        return;
    }

    for (int i = 0; i < node->index + 1; i++)
    {
        fprintf(stream, "    %d[label=%s];\n", node->id, label);
        fprintf(stream, "    %d -> %d;\n", node->id, node->children[i]->id);
        aux_ast_print(node->children[i], stream, node->children[i]->label);
    }
}

void main_ast_print(ast_node *tree, FILE *stream)
{
    fprintf(stream, "digraph AST {\n");
    fprintf(stream, "    node [fontname=\"Arial\"];\n");

    if (!tree)
        fprintf(stream, "\n");
    else if (is_leaf(tree))
        fprintf(stream, "    %d;\n", tree->id);
    else
        aux_ast_print(tree, stream, tree->label);

    fprintf(stream, "}\n");
}