
%define parse.error verbose

%code provides{
    typedef union{
        int ival;              /* Value of integer values */
        double rval;              /* Value of real values*/
        char *string;              /* Value string */
        char *type;
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
/* %token <string> STRUCTTYPEDECLARE */
%type <string> type_declare
%type <string> just_declare
%type <string> struct_fields
%type <string> srt
%type <string> crt

%token <string> FUNCTIONDECLARE
%token <string> NUMBERDECLARE
%token <string> STRINGDECLARE
%token <string> CONSTDECLARE
%token <string> BOOLEENDECLARE
%token <string> STRUCTTYPEDECLARE 
%token <string> STRUCTDECLARE
%token <string> TABLEDECLARE
%token <string> POINTERDECLARE

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


%{
    

    extern int yylineno;
    extern FILE *yyin, *yyout;

    extern int yylex();
    void yysuccess();
    void yyerror();
    void showLexicalError();


    GlobalSymTable* gSymT; //Our global table of symbols
    SymTable* symt;        //Current table of symboles (used by scanner.l as well)
    int currentColumn = 1;
    int showsuccess = 0;
    
    _YYSTYPE _yylval;

%}

%%



underscore: /*eps*/ 
        | underscore func
        ;

func: FUNCTIONDECLARE ret ID { _yylval.ident->symType = FUNCTIONDECLARE; /*set_attr(_yylval.ident, "typeretour", $1);*/ } OPENPARENTHESIS params_eps CLOSEPARENTHESIS body { insertNewGlobalEntry(gSymT, symt); symt = allocateSymTable();   yysuccess("function ended.");}

ret: // eps
    | srt // simple return type 
    | crt // complex return type
    ; 
    // just for simplicity


srt: NUMBERDECLARE {$$=_yylval.type;} | STRINGDECLARE {$$=_yylval.type;} | BOOLEENDECLARE {$$=_yylval.type;} ;

crt: TABLEDECLARE {$$=_yylval.type;} | STRUCTTYPEDECLARE {$$=_yylval.type;};


params_eps: // eps
        | params
        ;
    

params: param comma_params;


comma_params: // eps
            | COMMA params
            ;


param: type_declare ID { if(_yylval.ident == NULL) yyerror("ID already declared!"); else set_attr(_yylval.ident, "type", $1); } ;


body: OPENHOOK bloc CLOSEHOOK
    ;

bloc: statement bloc {yysuccess("Block.");}
     | {yysuccess("Emptyness.");} 
     ;

statement: declare SEMICOLON {yysuccess("Simple declaration / with assign.");}
		| STRUCTTYPEDECLARE ID { if(_yylval.ident == NULL) yyerror("ID already declared!"); else set_attr(_yylval.ident, "type", "typestruct");} OPENHOOK struct_fields CLOSEHOOK SEMICOLON 
		| assign SEMICOLON {yysuccess("Assignment.");}
        
        | LOOP OPENPARENTHESIS expression CLOSEPARENTHESIS OPENHOOK bloc CLOSEHOOK {yysuccess("while loop.");}
		| LOOP OPENPARENTHESIS assign SEMICOLON expression SEMICOLON assign CLOSEPARENTHESIS OPENHOOK bloc CLOSEHOOK {yysuccess("for loop with assignment.");}
		| LOOP OPENPARENTHESIS init_declare SEMICOLON expression SEMICOLON assign CLOSEPARENTHESIS OPENHOOK bloc CLOSEHOOK {yysuccess("for loop with declaration+assignment.");}
        
        | ifstmt {yysuccess("Simplest if statement.");}
		| ifstmt elsestmt {yysuccess("If else statement.");}
		| ifstmt elifstmt {yysuccess("If elif statement.") ;}
		| ifstmt elifstmt elsestmt {yysuccess("If elif else statement.");}

        | RETURN expression SEMICOLON {yysuccess("Return statement.");}
        | ID OPENPARENTHESIS { checkif_globalsymbolexists(_yylval.ident); } CLOSEPARENTHESIS SEMICOLON {yysuccess("Call without params statement.");}
		| ID OPENPARENTHESIS { checkif_globalsymbolexists(_yylval.ident); } call_param CLOSEPARENTHESIS SEMICOLON {yysuccess("Call with params statement.");}
 
        | READ OPENPARENTHESIS ID { checkif_localsymbolexists(_yylval.ident); } CLOSEPARENTHESIS SEMICOLON {yysuccess("Read input.");}
		| WRITE OPENPARENTHESIS expression CLOSEPARENTHESIS SEMICOLON {yysuccess("Print output.");}
        ;

/* loop_bloc: statement loop_bloc
        | loop_bloc BREAK ";" loop_bloc
        | loop_bloc CONTINUE ";" loop_bloc
        |
        ; */

type_declare: NUMBERDECLARE {$$=_yylval.type;}
		    | STRINGDECLARE {$$=_yylval.type;}
			| CONSTDECLARE NUMBERDECLARE {$$="nombre constant";}
			| CONSTDECLARE STRINGDECLARE {$$="chaine constante";}
			| BOOLEENDECLARE {$$=_yylval.type;}
			| POINTERDECLARE {$$=_yylval.type;}
			| TABLEDECLARE {$$=_yylval.type;}
			| STRUCTDECLARE {$$=_yylval.type;}
            ;
just_declare: type_declare ID { if(_yylval.ident == NULL) yyerror("ID already declared!"); else set_attr(_yylval.ident, "type", $1); }
            ;
init_declare: just_declare ASSIGNMENT expression 
            ;
declare: just_declare 
	   | init_declare
       ;
struct_fields: type_declare ID { char saveName[255]; strcpy(saveName, _yylval.ident->symName); deleteEntry(symt, saveName); set_attr(symt->tail, $1, saveName);}
			 | type_declare ID { char saveName[255]; strcpy(saveName, _yylval.ident->symName); deleteEntry(symt, saveName); set_attr(symt->tail, $1, saveName);} COMMA struct_fields
             |   // added by mohammed in C we can have an empty struct like this struct name{};
             ;

assign: var ASSIGNMENT expression
	  | ID {checkif_localsymbolexists(_yylval.ident);} OPENBRACKET expression CLOSEBRACKET ASSIGNMENT expression
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
var: ID {checkif_localsymbolexists(_yylval.ident);}
   | ID {checkif_localsymbolexists(_yylval.ident);} DOT accessfield
   ;

//General formula for experession
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



const :  INTEGER {
                printf("%d\n", _yylval.ival);
            }
	    |  REALNUMBER
        |  STRING
        |  TRUE
        | FALSE
        ;

variable : var_exp
	| ID OPENPARENTHESIS {checkif_globalsymbolexists(_yylval.ident);} call_param CLOSEPARENTHESIS {yysuccess("EXPRESSION : FUNCTION CALL");}
	| ID OPENPARENTHESIS {checkif_globalsymbolexists(_yylval.ident);} CLOSEPARENTHESIS {yysuccess("EXPRESSION : FUNCTION CALL");}
	;

var_exp : ID {checkif_localsymbolexists(_yylval.ident); yysuccess("variable");}
	| ID {checkif_localsymbolexists(_yylval.ident);} DOT accessfield {yysuccess("EXPRESSION : OBJECT  ACCESS");}
	| ID {checkif_localsymbolexists(_yylval.ident);} OPENBRACKET expression CLOSEBRACKET {yysuccess("EXPRESSION : ARRAY ACCESS");}
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

    // alocate the global symbols table
    gSymT = allocateGlobalSymTable();
    
    // alocate the symbols table
    symt = allocateSymTable();


    fprintf(stdout, "" MAGENTA "========= Stream of tokens found =========" RESET "\n");

    //while (yylex()) {}

    yyparse();
     
    printGlobalSymTable(gSymT);

    // free up the sym table
    freeUpSymTable(symt);
    freeUpGlobalSymTable(gSymT);
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

/* void addPotentialEntryWithTypeAttribute(int type) {
    insertNewEntry(symt, type, "identifier"); /* identifier is just a placeholder for the ID name later 
    set_attr(symt->tail, "type", _yylval.type );
}


void confirmOrDenyEntryID() {
    if (symbol_exists(symt, _yylval.string)) {  /* Symbol already exists, we need to display an error and delete the potential entry added earlier 
        deleteEntry(symt, "identifier"); /* Delete last entry 
        yyerror("ID already declared."); /* First kind of symtable errors 
    } 
    else {  /* Symbol doesn't exist in this scope, we add the name of the identifier to the last entry 
        SymTableNode* node = symt->tail; 
        strcpy(node->symName, _yylval.string); 
        _yylval.ident = node; 
    }
}

void addStructTypeEntryWithTypeAttribute() {
    char saveSymName[255]; strcpy(saveSymName, _yylval.string);
    /*deleteEntry(symt, _yylval.string); /* Delete it from being a regular identifier (different symNodeType) 
    if (symbol_exists(symt, _yylval.string)) yyerror("symbol exists"); 
    else { 
        SymTableNode* node = insertNewEntry(symt, STRUCTTYPEDECLARE, saveSymName); /* Insert it as a struct type declare 
        set_attr(node, "type", "typestructure");
        yysuccess("Déclaration d'un type structure.");
    }
} */

void checkif_globalsymbolexists(SymTableNode* currentNode) {


    if(currentNode == NULL) {
        yyerror("ID already in use.");
        return;
    }  

    if( !globalsymbol_exists(gSymT, currentNode->symName) ){
        yyerror("Appel à une fonction non déclarée.");
    }

    deleteEntry(symt, symt->tail->symName);

}

void checkif_localsymbolexists(SymTableNode* insertedNode) {
    /*Scanner returns NULL if it finds symbol already inserted in the symTable*/

    if(insertedNode != NULL) printf("%s", insertedNode->symName); else printf("inserted null\n");
 
    if(insertedNode != NULL) {
        yyerror("ID is not declared.");
        deleteEntry(symt, symt->tail->symName);
    }

}

