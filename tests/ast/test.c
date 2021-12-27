#include "ast.h"

int main()
{

    ast_node *root = build_ast(AST_BLOC);
    add_child(root, AST_STATEMENT);
    add_child(root, AST_STATEMENT);
    add_child(root, AST_STATEMENT);
    add_child(root, AST_STATEMENT);
    ast_node *node = add_child(root, AST_STATEMENT);

    add_child(node, AST_ID);
    add_child(node, AST_ASSIGNMENT);
    add_child(node, AST_ID);
    // printf("%d\n", get_child(root, 1)->node_type);

    FILE *dotfile = fopen("ast.dot", "w+");
    main_ast_print(root, dotfile);
    // printf("%d\n", node->children[0]->node_type);
    destroy_ast(root, number_of_children(root));
}