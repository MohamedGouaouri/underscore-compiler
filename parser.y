
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
}

%union {
    char* string;
    int token_type;
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
%}

%%



underscore: /*eps*/ 
        | underscore func
        ;

func: FUNCTIONDECLARE ret ID OPENPARENTHESIS params_eps CLOSEPARENTHESIS body {
        
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

body: OPENHOOK bloc CLOSEHOOK
    ;

bloc: statement bloc {yysuccess("Block.");}
     | {yysuccess("Emptyness.");} 
     ;

statement: declare SEMICOLON {yysuccess("Simple declaration / with assign.");}
		| STRUCTTYPEDECLARE ID OPENHOOK struct_fields CLOSEHOOK SEMICOLON {yysuccess("Déclaration d'un type structure.");}
		| assign SEMICOLON {yysuccess("Assignment.");}
        
        | LOOP OPENPARENTHESIS expression CLOSEPARENTHESIS OPENHOOK loop_bloc CLOSEHOOK {yysuccess("while loop.");}
		| LOOP OPENPARENTHESIS assign SEMICOLON expression SEMICOLON assign CLOSEPARENTHESIS OPENHOOK loop_bloc CLOSEHOOK {yysuccess("for loop with assignment.");}
		| LOOP OPENPARENTHESIS init_declare SEMICOLON expression SEMICOLON assign CLOSEPARENTHESIS OPENHOOK loop_bloc CLOSEHOOK {yysuccess("for loop with declaration+assignment.");}
        
        | ifstmt {yysuccess("Simplest if statement.");}
		| ifstmt elsestmt {yysuccess("If else statement.");}
		| ifstmt elifstmt {yysuccess("If elif statement.") ;}
		| ifstmt elifstmt elsestmt {yysuccess("If elif else statement.");}

        | RETURN expression SEMICOLON {yysuccess("Return statement.");}
        | ID OPENPARENTHESIS CLOSEPARENTHESIS SEMICOLON {yysuccess("Call without params statement.");}
		| ID OPENPARENTHESIS call_param CLOSEPARENTHESIS SEMICOLON {yysuccess("Call with params statement.");}
 
        | READ OPENPARENTHESIS ID CLOSEPARENTHESIS SEMICOLON {yysuccess("Read input.");}
		| WRITE OPENPARENTHESIS expression CLOSEPARENTHESIS SEMICOLON {yysuccess("Print output.");}
        ;

loop_bloc: statement loop_bloc
        | loop_bloc BREAK ";" loop_bloc
        | loop_bloc CONTINUE ";" loop_bloc
        |
        ;

type_declare: NUMBERDECLARE
		    | STRINGDECLARE
			| CONSTDECLARE NUMBERDECLARE
			| CONSTDECLARE STRINGDECLARE
			| BOOLEENDECLARE
			| POINTERDECLARE
			| TABLEDECLARE
			| STRUCTDECLARE
            ;
just_declare: type_declare ID {
                    // if (symbol_exists(symt, $2)){
                    //     printf("symbol exists");
                    // }
                    printf("%s\n", _yylval.ident->symName);
                }
            ;
init_declare: just_declare ASSIGNMENT expression
            ;
declare: just_declare
	   | init_declare
       ;
struct_fields: declare
			 | declare COMMA struct_fields
             |   // added by mohammed in C we can have an empty struct like this struct name{};
             ;

assign: var ASSIGNMENT expression
	  | ID OPENBRACKET expression CLOSEBRACKET ASSIGNMENT expression
	  | ADDRESSVALUE var ASSIGNMENT expression
	  | POINTERVALUE var ASSIGNMENT expression
      ;

ifstmt: IF OPENPARENTHESIS expression CLOSEPARENTHESIS body {yysuccess("if stmt.");}
      ;
elifstmt: ELSE OPENPARENTHESIS expression CLOSEPARENTHESIS body {yysuccess("elif stmt.");}
        | elifstmt ELSE OPENPARENTHESIS expression CLOSEPARENTHESIS body {yysuccess("elif elif stmt.");}
        ;
elsestmt: ELSE OPENPARENTHESIS CLOSEPARENTHESIS body {yysuccess("else stmt.");}
        ;

call_param: expression
		  | expression COMMA call_param

accessfield: ID
		   | ID DOT accessfield
           ;
var: ID
   | ID DOT accessfield
   ;

expression: ID 
            | INTEGER {
                printf("%d\n", _yylval.ival);
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