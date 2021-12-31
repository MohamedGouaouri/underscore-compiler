
%define parse.error verbose

%code provides{
    typedef union{
        int ival;              /* Value of integer values */
        double rval;              /* Value of real values*/
        char* string;              /* Value string */
        SymTableNode *ident; /* Value of a IDENTIFIER */
    } _YYSTYPE;
    
    
}

%code requires{
    #include <stdio.h>
    #include <stdlib.h>
    #include "symtable.h"
    #include "ast.h"
    #include "misc.h"
    #include "ast.h"
}

%union {
    char* string;
    int token_type;
    ast_node* node;
}

%token ENTRY

%token LOOP 
%token IF
%token ELSE

%token READ
%token WRITE

%token BREAK
%token CONTINUE

%token <token_type> ID

%token FUNCTIONDECLARE
%token NUMBERDECLARE
%token STRINGDECLARE
%token CONSTDECLARE
%token BOOLEENDECLARE
%token STRUCTTYPEDECLARE
%token STRUCTDECLARE
%token TABLEDECLARE
%token POINTERDECLARE

%token ADDRESSVALUE "&"
%token POINTERVALUE "@"

%token OPENHOOK "{"
%token CLOSEHOOK "}"

%token OPENPARENTHESIS "("
%token CLOSEPARENTHESIS ")"

%token OPENBRACKET "["
%token CLOSEBRACKET "]"

%token EQUAL "="
%token NONEQUAL "!="
%token AND "&&"
%token OR "||"
%token NON "!"
%token INFERIOR "<"
%token SUPERIOR ">"
%token INFERIOREQUAL "<="
%token SUPERIOREQUAL ">="
%token ADD "+"
%token SUB "-"
%token MULT "*"
%token DIV "/"
%token MOD "%"
%token POWER "^"


%token DOT "."
%token COMMA ","
%token SEMICOLON ";"



%token ASSIGNMENT 
%token RETURN

%token INTEGER
%token REALNUMBER
%token STRING

%token TRUE
%token FALSE


// types
%type <node> func
%type <node> assign expression statement bloc ifstmt

%{
    

    extern int yylineno;
    extern FILE *yyin, *yyout;

    extern int yylex();
    void yysuccess();
    void yyerror();
    void showLexicalError();

    SymTable* symt;
    int currentColumn = 1;
    int showsuccess = 0;
    
    _YYSTYPE _yylval;
    ast* tree;
    ast_node* p;
    ast_node* prev;
%}

%%



underscore: /*eps*/ 
        | underscore func
        ;

func: FUNCTIONDECLARE ret ID OPENPARENTHESIS params_eps CLOSEPARENTHESIS {
        // begin a function
        tree = build_ast(AST_FUNCTION);
        p = tree->root;
        prev = p;
    } OPENHOOK bloc CLOSEHOOK {
        // add_child(tree, tree->root, $9);
        yysuccess("function ended.");
    }

ret: // eps
    | srt // simple return type
    | crt // complex return type
    ; 
    // just for simplicity


srt: NUMBERDECLARE | STRINGDECLARE | BOOLEENDECLARE ;

crt: TABLEDECLARE | STRUCTTYPEDECLARE;


params_eps: // eps
        | params
        ;
    

params: param comma_params;

comma_params: // eps
            | COMMA params
            ;


param: type ID ;

type: srt | crt ; // just for now it must be expanded to your type


bloc: statement{
    printf("P is: %d\n", p->node_type);
        add_child(tree, p, $1);
    }
    bloc {
        $$ = $1;
    }
    | {}
     ;

statement: declare SEMICOLON {yysuccess("Simple declaration / with assign.");}
		/* | STRUCTTYPEDECLARE ID OPENHOOK struct_fields CLOSEHOOK SEMICOLON {yysuccess("Déclaration d'un type structure.");} */
		| assign SEMICOLON {
            $$ = $1;

        }
        
        /* | LOOP OPENPARENTHESIS expression CLOSEPARENTHESIS OPENHOOK bloc CLOSEHOOK {yysuccess("while loop.");}
		| LOOP OPENPARENTHESIS assign SEMICOLON expression SEMICOLON assign CLOSEPARENTHESIS OPENHOOK bloc CLOSEHOOK {yysuccess("for loop with assignment.");}
		| LOOP OPENPARENTHESIS init_declare SEMICOLON expression SEMICOLON assign CLOSEPARENTHESIS OPENHOOK bloc CLOSEHOOK {yysuccess("for loop with declaration+assignment.");}
         */
        | ifstmt {$$ = $1;}
		/* | ifstmt elsestmt {yysuccess("If else statement.");}
		| ifstmt elifstmt {yysuccess("If elif statement.") ;}
		| ifstmt elifstmt elsestmt {yysuccess("If elif else statement.");} */

        | RETURN {$<node>$ = create_node(AST_RETURN);} expression SEMICOLON {
            // add children
            $$ = $<node>2;
            add_child(tree, $$, $3);
        ;}
        /* | ID OPENPARENTHESIS CLOSEPARENTHESIS SEMICOLON {yysuccess("Call without params statement.");}
		| ID OPENPARENTHESIS call_param CLOSEPARENTHESIS SEMICOLON {yysuccess("Call with params statement.");}
  */
        /* | READ OPENPARENTHESIS ID CLOSEPARENTHESIS SEMICOLON {yysuccess("Read input.");}
		| WRITE OPENPARENTHESIS expression CLOSEPARENTHESIS SEMICOLON {yysuccess("Print output.");}
        ; */
        ;

declare: just_declare
	   | init_declare
       ;
type_declare: NUMBERDECLARE
		    /* | STRINGDECLARE
			| CONSTDECLARE NUMBERDECLARE
			| CONSTDECLARE STRINGDECLARE
			| BOOLEENDECLARE
			| POINTERDECLARE
			| TABLEDECLARE
			| STRUCTDECLARE */
            ;

just_declare: type_declare ID;

init_declare: just_declare ASSIGNMENT expression;


/* struct_fields: declare
			 | declare COMMA struct_fields
             |   // added by mohammed in C we can have an empty struct like this struct name{};
             ; */

 assign: ID {
        $<node>$ = create_node(AST_ID);
     } ASSIGNMENT expression {
        $$ = create_node(AST_ASSIGNMENT);
        add_child(tree, $$, $<node>2);
        add_child(tree, $$, $4);
 }

	  /* | ID OPENBRACKET expression CLOSEBRACKET ASSIGNMENT expression */
	  /* | ADDRESSVALUE var ASSIGNMENT expression */
	  /* | POINTERVALUE var ASSIGNMENT expression */
      ;

ifstmt: IF {$<node>$ = create_node(AST_IF);} OPENPARENTHESIS expression CLOSEPARENTHESIS "{" 
            // enter new contexte
            {
                add_child(tree, $<node>2, $4);
                p = create_node(AST_BLOC);
                printf("P is: %d\n", p->node_type);
                add_child(tree, $<node>2, p);
            }
        bloc
        "}" {
            $$ = $<node>2;
            // // pop context
            p = prev;
        }
    ;
/* elifstmt: ELSE OPENPARENTHESIS expression CLOSEPARENTHESIS body {yysuccess("elif stmt.");} */
        /* | elifstmt ELSE OPENPARENTHESIS expression CLOSEPARENTHESIS body {yysuccess("elif elif stmt.");} */
        /* ; */
/* elsestmt: ELSE OPENPARENTHESIS CLOSEPARENTHESIS body {yysuccess("else stmt.");} */
        /* ; */

/* call_param: expression
		  | expression COMMA call_param */

/* accessfield: ID
		   | ID DOT accessfield
           ; */
/* var: ID {

} */
  /* ID DOT accessfield */
   ; 

expression: ID {$$ = create_node(AST_ID);}
            | INTEGER {
                // printf("%d\n", _yylval.ival);
                $$ = create_node(AST_INTEGER);
            }
            ;

%%




void yyerror(char *s){
    fprintf(stdout, "%d: " RED "%s" RESET "\n", yylineno, s);
}

void yysuccess(char *s){
    fprintf(stdout, "%d: " GREEN "%s" RESET "\n", yylineno, s);
}


int main(int argc, char **argv) {

    
    
    yyin = fopen(argv[1], "r");
  
    yyout = fopen("Output.txt", "w");

    if (argc>=3 && sscanf (argv[2], "%i", &showsuccess) != 1) {
        fprintf(stderr, "error - not an integer");
    }
    if(showsuccess != 0) showsuccess = 1;
    
    // alocate the symbols table
    symt = allocateSymTable();

    fprintf(stdout, "" MAGENTA "========= Stream of tokens found =========" RESET "\n");

    yyparse();
    
    printSymTable(symt);
    FILE *dotfile = fopen("ast.dot", "w+");
    main_ast_print(tree, dotfile);
    printf("Type: %d\n", tree->root->children[0]->node_type);
    destroy_ast(tree->root, number_of_children(tree->root));

    // free up the sym table
    freeUpSymTable(symt);
    fclose(yyin);
    fclose(yyout);
    return 0;

}

void showLexicalError() {

    char line[256], introError[80]; 

    fseek(yyin, 0, SEEK_SET);
    
    int i = 0; 

    while (fgets(line, sizeof(line), yyin)) { 
        i++; 
        if(i == yylineno) break;  
    } 
        
    sprintf(introError, "Lexical error in Line %d : Unrecognized character : ", yylineno);
    printf("%s%s", introError, line);  
    int j=1;
    while(j<currentColumn+strlen(introError)) { printf(" "); j++; }
    printf("^\n");


}