#include "ast.h"

ast_node *build_ast(ast_node_type node_type)
{
    ast_node *root = (ast_node *)malloc(sizeof(ast_node));
    root->node_type = node_type;
    root->index = -1; // initially it's a leaf node

    // for (size_t i = 0; i < MAX_CHILDREN; i++)
    // {
    //     root->children[i] = NULL;
    // }
    return root;
}

ast_node *add_child(ast_node *node, ast_node_type node_type)
{
    int where = node->index + 1;
    ast_node *new_node = (ast_node *)malloc(sizeof(ast_node));
    new_node->index = -1; // added as a leaf node
    new_node->node_type = node_type;

    node->children[where] = new_node; // linking
    return new_node;
}

ast_node *get_child(ast_node *node, int index)
{
    return node->children[index];
}

bool is_leaf(ast_node *node)
{
    return node->index == -1 ? true : false;
}

void destroy_ast(ast_node *root, size_t num_of_children)
{
    if (is_leaf(root))
    {
        free(root);
    }

    // recursive node distruction
    for (size_t i = 0; i < root->index + 1; i++)
    {

        destroy_ast(root->children[i], root->index + 1);
    }
}