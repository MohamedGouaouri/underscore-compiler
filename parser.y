
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
    char save[255];
    int currentColumn = 1;
    int showsuccess = 0;
    
    _YYSTYPE _yylval;

%}

%%



underscore: %empty
        | underscore func
        | error func {yyerrok;}
        ;

func: FUNCTIONDECLARE ret ID { _yylval.ident->symType = FUNCTIONDECLARE; set_attr(_yylval.ident, "typeretour", $<string>2); } OPENPARENTHESIS params_eps CLOSEPARENTHESIS body { insertNewGlobalEntry(gSymT, symt); symt = allocateSymTable();   yysuccess(1,"function ended.");}


ret: %empty
    | srt // simple return type 
    | crt // complex return type
    ; 
    // just for simplicity


srt: NUMBERDECLARE {$$=_yylval.type;} | STRINGDECLARE {$$=_yylval.type;} | BOOLEENDECLARE {$$=_yylval.type;} ;

crt: TABLEDECLARE {$$=_yylval.type;} | STRUCTTYPEDECLARE {$$=_yylval.type;};


params_eps: %empty
        | params
        ;
    

params: param comma_params;


comma_params: %empty
            | COMMA params
            ;


param: type_declare ID { if(_yylval.ident == NULL) yyerror("ID already declared!"); else set_attr(_yylval.ident, "type", $1); } ;


body: OPENHOOK bloc CLOSEHOOK
    ;

bloc: statement bloc {yysuccess(1, "Block.");}
     | %empty {yysuccess(1, "Emptyness.");} 
     | error bloc {yyerror("wrong statement inside block."); yyerrok;}
     ;

statement: declare SEMICOLON {yysuccess(1, "Simple declaration / with assign.");}
		| STRUCTTYPEDECLARE ID { if(_yylval.ident == NULL) yyerror("ID already declared!"); else { _yylval.ident->symType = STRUCTTYPEDECLARE; set_attr(_yylval.ident, "type", "typestruct"); yysuccess(1,"Déclaration d'un type structure.");}} OPENHOOK struct_fields CLOSEHOOK SEMICOLON 
		| assign SEMICOLON {yysuccess(1, "Assignment.");}
        | LOOP OPENPARENTHESIS expression CLOSEPARENTHESIS OPENHOOK bloc CLOSEHOOK {yysuccess(1, "while loop.");}
		| LOOP OPENPARENTHESIS assign SEMICOLON expression SEMICOLON assign CLOSEPARENTHESIS OPENHOOK bloc CLOSEHOOK {yysuccess(1, "for loop with assignment.");}
		| LOOP OPENPARENTHESIS init_declare SEMICOLON expression SEMICOLON assign CLOSEPARENTHESIS OPENHOOK bloc CLOSEHOOK {yysuccess(1, "for loop with declaration+assignment.");}
        | LOOP error OPENHOOK bloc CLOSEHOOK {yyerror("wrong syntax inside loop()."); yyerrok;} 
        
        
        
        | ifstmt {yysuccess(1,"Simplest if statement.");}
		| ifstmt elsestmt {yysuccess(1,"If else statement.");}
		| ifstmt elifstmt {yysuccess(1,"If elif statement.") ;}
		| ifstmt elifstmt elsestmt {yysuccess(1,"If elif else statement.");}

        | RETURN expression SEMICOLON {yysuccess(1, "Return statement.");}
        | ID OPENPARENTHESIS { checkif_globalsymbolexists(_yylval.ident); } CLOSEPARENTHESIS SEMICOLON {yysuccess(1, "Call without params statement.");}
		| ID OPENPARENTHESIS { checkif_globalsymbolexists(_yylval.ident); } call_param CLOSEPARENTHESIS SEMICOLON {yysuccess(1, "Call with params statement.");}
 
        | READ OPENPARENTHESIS ID { checkif_localsymbolexists(_yylval.ident); } CLOSEPARENTHESIS SEMICOLON {yysuccess(1, "Read input.");}
		| WRITE OPENPARENTHESIS expression CLOSEPARENTHESIS SEMICOLON {yysuccess(1, "Print output.");}
        | error SEMICOLON {yyerror("wrong statement"); yyerrok;}
        ;


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
            | just_declare ASSIGNMENT OPENBRACKET values_eps CLOSEBRACKET
            ;
values_eps: %empty
          | call_param /*static initialization of an array [ exp1, exp2, exp3, ... ]*/
          ;
            
declare: just_declare
	   | init_declare
       ;
struct_fields: type_declare ID { char saveName[255]; strcpy(saveName, _yylval.ident->symName); deleteEntry(symt, saveName); set_attr(symt->tail, $1, saveName); }
			 | type_declare ID { set_fieldattribute($1); } COMMA struct_fields
             | %empty {}
             ;

assign: var_exp ASSIGNMENT expression
	  | ADDRESSVALUE var ASSIGNMENT expression
	  | POINTERVALUE var ASSIGNMENT expression
      ;

ifstmt: IF OPENPARENTHESIS expression CLOSEPARENTHESIS body {yysuccess(1,"if stmt.");}
      | IF error body {yyerror("wrong syntax inside if()."); yyerrok;} 
      ;
elifstmt: ELSE OPENPARENTHESIS expression CLOSEPARENTHESIS body {yysuccess(1,"elif stmt.");}
        | ELSE error body {yyerror("wrong syntax inside elif()."); yyerrok;} 
        | elifstmt ELSE OPENPARENTHESIS expression CLOSEPARENTHESIS body {yysuccess(1,"elif elif stmt.");}
        ;
elsestmt: ELSE OPENPARENTHESIS CLOSEPARENTHESIS body {yysuccess(1,"else stmt.");}
        | ELSE error body {yyerror("wrong syntax inside else()."); yyerrok;} 
        ;

call_param: expression
		  | expression COMMA call_param


//General formula for experession
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

var_exp : var
	| ID {checkif_localsymbolexists(_yylval.ident);} OPENBRACKET expression CLOSEBRACKET {yysuccess("EXPRESSION : ARRAY ACCESS");}
	;

accessfield: ID { /*checkif_fieldisvalid(save, symt->tail->symName);*/ deleteEntry(symt, symt->tail->symName); }
		   | ID { deleteEntry(symt, symt->tail->symName); } DOT accessfield
           ;
var: ID {checkif_localsymbolexists(_yylval.ident);}
   | ID {checkif_localsymbolexists(_yylval.ident); /* strcpy(save, symt->tail->symName);*/} DOT accessfield
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

    // alocate the global symbols table
    gSymT = allocateGlobalSymTable();
    
    // alocate the symbols table
    symt = allocateSymTable();


    fprintf(stdout, "" MAGENTA "========= Stream of tokens found =========" RESET "\n");

    yyparse();


    printGlobalSymTable(gSymT);

    /**/
    checkif_fieldisvalid("teacher", "name"); 
     

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


void set_fieldattribute(char* type) {
    char saveName[255]; 
    strcpy(saveName, _yylval.ident->symName); 
    deleteEntry(symt, saveName); 
    set_attr(symt->tail, type, saveName);
}

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
    /*In this case, NULL means good, it means we're using a variable that's been declared before*/

    if(insertedNode != NULL) {
        yyerror("ID is not declared.");
        deleteEntry(symt, symt->tail->symName);
    }

    /* yyerror("Id is declared, all is good"); */
}

void checkif_fieldisvalid(char type[50], char fieldname[50]) {

        /*Going back to the first symtable*/

        symt = gSymT->head->symTable;

        /* SymTableNode* node = lookup(symt, precedent); //Look up its row

        if(node == NULL) return;

        AttrNode* typeattr_node = node->rootAttr; //Look up its type attribute

        if(typeattr_node == NULL) return;

        char* type; strcpy(type, typeattr_node->val); 

        char *str = malloc(strlen(type));  */

        SymTableNode* structnode = lookup(symt, type); /*Lookup the node where the struct type is declared (we need to remove the _ from the type string first)*/

        AttrNode* fieldattr_node = structnode->rootAttr;

        if(fieldattr_node == NULL) return;
        
        fieldattr_node = fieldattr_node->next; /*rootAttr node is dedicated for the type=typestruct, we need to skip it*/

        while(fieldattr_node != NULL) {

            if(strcmp(fieldattr_node->val, fieldname) == 0 ) {
                yysuccess("Field exists!"); return;
            }

            fieldattr_node = fieldattr_node -> next;

        }

        yyerror("Field doesn't exist for this type.");

}


