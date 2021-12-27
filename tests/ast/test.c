#include "ast.h"

int main()
{

    ast_node *root = build_ast(AST_BLOC);
    add_child(root, AST_STATEMENT);
    add_child(root, AST_STATEMENT);
    add_child(root, AST_STATEMENT);
    add_child(root, AST_STATEMENT);
    add_child(root, AST_STATEMENT);
    printf("%d\n", get_child(root, 1)->node_type);

    destroy_ast(root, number_of_children(root));
}