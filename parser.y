%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "symtable.h"
    #include "ast.h"
    #include "misc.h"

    extern int yylineno;
    extern int yyleng;
    extern FILE *yyin, *yyout;

    extern int yylex();
    void yysuccess();
    void yyerror();
    void showLexicalError();

    SymTable* symt;
    int currentColumn = 1;
    int showsuccess = 0;
%}



%define parse.error verbose

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
        | error func {yyerrok;}
        ;

func: FUNCTIONDECLARE ret ID OPENPARENTHESIS params_eps CLOSEPARENTHESIS body {
        
        yysuccess(1,"function ended.");
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

bloc: statement bloc {yysuccess(1,"Block.");}
     | {yysuccess(1,"Emptyness.");} 
     | error bloc {yyerror("wrong statement inside block."); yyerrok;}
     ;

statement: declare SEMICOLON {yysuccess(1,"Simple declaration / with assign.");}
		| STRUCTTYPEDECLARE ID OPENHOOK struct_fields CLOSEHOOK SEMICOLON {yysuccess(1,"Déclaration d'un type structure.");}
		| assign SEMICOLON {yysuccess(1,"Assignment.");}
        
        | LOOP OPENPARENTHESIS expression CLOSEPARENTHESIS OPENHOOK bloc CLOSEHOOK {yysuccess(1, "while loop.");}
		| LOOP OPENPARENTHESIS assign SEMICOLON expression SEMICOLON assign CLOSEPARENTHESIS OPENHOOK bloc CLOSEHOOK {yysuccess(1, "for loop with assignment.");}
		| LOOP OPENPARENTHESIS init_declare SEMICOLON expression SEMICOLON assign CLOSEPARENTHESIS OPENHOOK bloc CLOSEHOOK {yysuccess(1, "for loop with declaration+assignment.");}
        //| LOOP OPENPARENTHESIS error CLOSEPARENTHESIS OPENHOOK bloc CLOSEHOOK {yyerror("wrong syntax inside loop()."); yyerrok;}
        
        | ifstmt {yysuccess(1,"Simplest if statement.");}
		| ifstmt elsestmt {yysuccess(1,"If else statement.");}
		| ifstmt elifstmt {yysuccess(1,"If elif statement.") ;}
		| ifstmt elifstmt elsestmt {yysuccess(1,"If elif else statement.");}

        | RETURN expression SEMICOLON {yysuccess(1,"Return statement.");}
        | ID OPENPARENTHESIS CLOSEPARENTHESIS SEMICOLON {yysuccess(1,"Call without params statement.");}
		| ID OPENPARENTHESIS call_param CLOSEPARENTHESIS SEMICOLON {yysuccess(1,"Call with params statement.");}
 
        | READ OPENPARENTHESIS ID CLOSEPARENTHESIS SEMICOLON {yysuccess(1,"Read input.");}
		| WRITE OPENPARENTHESIS expression CLOSEPARENTHESIS SEMICOLON {yysuccess(1,"Print output.");}

        | error SEMICOLON {yyerror("wrong statement"); yyerrok;}
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
            | just_declare ASSIGNMENT OPENBRACKET values_eps CLOSEBRACKET
            ;
values_eps: 
          | call_param /*static initialization of an array [ exp1, exp2, exp3, ... ]*/
          ;

declare: just_declare
	   | init_declare
       ;
struct_fields: declare
			 | declare COMMA struct_fields
             |   // added by mohammed in C we can have an empty struct like this struct name{};
             ;

assign: var ASSIGNMENT expression {yysuccess(1, "assign");}
	  | ID OPENBRACKET expression CLOSEBRACKET ASSIGNMENT expression
	  | ADDRESSVALUE var ASSIGNMENT expression
	  | POINTERVALUE var ASSIGNMENT expression
      ;

ifstmt: IF OPENPARENTHESIS expression CLOSEPARENTHESIS body {yysuccess(1,"if stmt.");}
      ;
elifstmt: ELSE OPENPARENTHESIS expression CLOSEPARENTHESIS body {yysuccess(1,"elif stmt.");}
        | elifstmt ELSE OPENPARENTHESIS expression CLOSEPARENTHESIS body {yysuccess(1,"elif elif stmt.");}
        ;
elsestmt: ELSE OPENPARENTHESIS CLOSEPARENTHESIS body {yysuccess(1,"else stmt.");}
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
    | OPENPARENTHESIS error CLOSEPARENTHESIS
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
	| ID OPENPARENTHESIS call_param CLOSEPARENTHESIS {yysuccess(1,"EXPRESSION : FUNCTION CALL");}
	;

var_exp : ID
	| ID DOT accessfield {yysuccess(1,"EXPRESSION : OBJECT  ACCESS");}
	| ID OPENBRACKET expression CLOSEBRACKET {yysuccess(1,"EXPRESSION : ARRAY ACCESS");}
	;



%%




void yyerror(char *s){
    fprintf(stdout, "%d: " RED " %s " RESET " \n", yylineno, s);
}

void yysuccess(int i, char *s){
    if(i) fprintf(stdout, "%d: " GREEN " %s " RESET "\n", yylineno, s);
    else fprintf(stdout, "%d: %s\n", yylineno, s);
    currentColumn+=yyleng;
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