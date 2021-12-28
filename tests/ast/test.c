#include "ast.h"

int main()
{

    ast *tree = build_ast(AST_BLOC);
    ast_node *root = tree->root;
    ast_node *statement = add_child(tree, root, AST_STATEMENT);
    ast_node *assign = add_child(tree, statement, AST_ASSIGNMENT);

    add_child(tree, assign, AST_ID);
    add_child(tree, assign, AST_INTEGER);

    ast_node *if_node = add_child(tree, root, AST_IF);
    ast_node *while_loop = add_child(tree, root, AST_WHILE_LOOP);

    ast_node *compare = add_child(tree, if_node, AST_SUPERIOR);
    add_child(tree, compare, AST_ID);
    add_child(tree, compare, AST_ID);

    ast_node *bloc = add_child(tree, if_node, AST_BLOC);

    assign = add_child(tree, bloc, AST_ASSIGNMENT);
    add_child(tree, assign, AST_ID);
    ast_node *mult = add_child(tree, assign, AST_MULT);
    add_child(tree, mult, AST_INTEGER);
    add_child(tree, mult, AST_ID);

    compare = add_child(tree, while_loop, AST_SUPERIOR);

    add_child(tree, compare, AST_ID);
    add_child(tree, compare, AST_INTEGER);
    bloc = add_child(tree, while_loop, AST_BLOC);

    assign = add_child(tree, bloc, AST_ASSIGNMENT);
    add_child(tree, assign, AST_ID);
    ast_node *minus = add_child(tree, assign, AST_ID);
    add_child(tree, minus, AST_ID);
    add_child(tree, minus, AST_INTEGER);

    // printf("%d\n", get_child(root, 1)->node_type);

    FILE *dotfile = fopen("ast.dot", "w+");
    main_ast_print(tree, dotfile);

    // printf("%d\n", if_node->id);
    destroy_ast(root, number_of_children(root));
}