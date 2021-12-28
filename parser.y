%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "symtable.h"
    #include "ast.h"
    #include "misc.h"

    extern int yylineno;
    extern FILE *yyin, *yyout;

    extern int yylex();
    void yysuccess();
    void yyerror();
    void showLexicalError();

    SymTable* symt;
    int currentColumn = 1;
    int showsuccess = 0;
%}



//%define parse.error detailed

%union {
    char* string;
}

%token ENTRY

%token LOOP 
%token IF
%token ELSE

%token READ
%token WRITE

%token BREAK
%token CONTINUE

%token ID

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

// Lof
//Comparison
%left COMMA
%nonassoc ASSIGNMENT
%left OR
%left AND
%nonassoc EQUAL NONEQUAL
%nonassoc INFERIOR  SUPERIOR INFERIOREQUAL SUPERIOREQUAL
%left ADD SUB
%left MULT DIV MOD
%nonassoc NON
%nonassoc ADDRESSVALUE POINTERVALUE
%left DOT OPENBRACKET CLOSEBRACKET
%left POWER
%left OPENPARENTHESIS CLOSEPARENTHESIS


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
        
        | LOOP OPENPARENTHESIS expression CLOSEPARENTHESIS OPENHOOK bloc CLOSEHOOK {yysuccess("while loop.");}
		| LOOP OPENPARENTHESIS assign SEMICOLON expression SEMICOLON assign CLOSEPARENTHESIS OPENHOOK bloc CLOSEHOOK {yysuccess("for loop with assignment.");}
		| LOOP OPENPARENTHESIS init_declare SEMICOLON expression SEMICOLON assign CLOSEPARENTHESIS OPENHOOK bloc CLOSEHOOK {yysuccess("for loop with declaration+assignment.");}
        
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

/* loop_bloc: statement loop_bloc
        | loop_bloc BREAK ";" loop_bloc
        | loop_bloc CONTINUE ";" loop_bloc
        |
        ; */

type_declare: NUMBERDECLARE
		    | STRINGDECLARE
			| CONSTDECLARE NUMBERDECLARE
			| CONSTDECLARE STRINGDECLARE
			| BOOLEENDECLARE
			| POINTERDECLARE
			| TABLEDECLARE
			| STRUCTDECLARE
            ;
just_declare: type_declare ID
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

//General formuala for experession
expression: OPENPARENTHESIS expression CLOSEPARENTHESIS
	| NON expression
	| POINTERVALUE var_exp
	| ADDRESSVALUE var_exp

	| expression EQUAL expression
    | expression NONEQUAL expression
    | expression OR expression
    | expression AND expression

    | expression INFERIOR expression
    | expression INFERIOREQUAL expression
    | expression SUPERIOR expression
    | expression SUPERIOREQUAL expression

    | expression ADD expression
    | expression SUB expression
    | expression MULT expression
    | expression DIV expression
    | expression MOD expression
    | expression POWER expression

	| const
	| variable
	;



const :  INTEGER
	    |  REALNUMBER
        |  STRING
        |  TRUE
        | FALSE
        ;

variable : var_exp
	| ID OPENPARENTHESIS call_param CLOSEPARENTHESIS {yysuccess("EXPRESSION : FUNCTION CALL");}
	;

var_exp : ID
	| ID DOT accessfield {yysuccess("EXPRESSION : OBJECT  ACCESS");}
	| ID OPENBRACKET expression CLOSEBRACKET {yysuccess("EXPRESSION : ARRAY ACCESS");}
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