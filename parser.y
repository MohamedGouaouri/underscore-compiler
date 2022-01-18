
%define parse.error verbose

%code provides{
    typedef union{
        int ival;              /* Value of integer values */
        double rval;              /* Value of real values*/
        char *string;              /* Value string */
        char type[255];
        SymTableNode *ident; /* Value of a IDENTIFIER */
    } _YYSTYPE;
    
    
}

%code requires{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "symtable.h"
    #include "ast.h"
    #include "misc.h"
    #include "ast.h"
}

%union {
    char string[255];
    int token_type;
    ast_node* node;
}

%token UNDERSCORE
%token ENTRY

%token LOOP "loop"
%token IF "?"
%token ELSE ":"

%token READ
%token WRITE

%token BREAK "break"
%token CONTINUE "continue"

%token <token_type> ID
%type <string> simple_type_declare
%type <string> complex_type_declare
%type <string> just_declare
%type <string> struct_fields
%type <string> srt
//%type <string> crt

%token <string> FUNCTIONDECLARE
%token <string> NUMBERDECLARE
%token <string> STRINGDECLARE
%token <string> CONSTDECLARE
%token <string> BOOLEENDECLARE
%token <string> STRUCTTYPEDECLARE 
%token <string> STRUCTDECLARE
%token NUMBERSYMBOL
%token STRINGSYMBOL
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



%token ASSIGNMENT "<-"
%token RETURN "->"

%token <token_type> INTEGER
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

%type <string> ret

%{
    

    extern int yylineno;
    extern int yyleng;
    extern FILE *yyin, *yyout;
    char* currentFileName;

    extern int yylex();
    void yysuccess();
    void yyerror();
    void showLexicalError();


    GlobalSymTable* gSymT; //Our global table of symbols
    SymTable* symt;        //Current table of symboles (used by scanner.l as well)
    char save[50];
    int declared_size = -1;         //Declared Size of array/string
    int effective_size = 0;
    int currentColumn = 1;
    int showsuccess = 0;
    
    _YYSTYPE _yylval;
    ast* tree;
    ast_node* p;
    ast_node* prev;

%}

%%



underscore: %empty
        | underscore func
        | error func {yyerrok;}
        ;

func: FUNCTIONDECLARE ret ID { _yylval.ident->symType = FUNCTIONDECLARE; set_attr(_yylval.ident, "typeretour", $<string>2); char str[5]; sprintf(str, "%d", declared_size); if(declared_size!=-1) set_attr(_yylval.ident, "size", str); declared_size=-1; } OPENPARENTHESIS params_eps CLOSEPARENTHESIS OPENHOOK bloc CLOSEHOOK { insertNewGlobalEntry(gSymT, symt); symt = allocateSymTable();   yysuccess(1,"function ended.");}


ret: %empty {strcpy($$ , "void");}
    | srt // simple return type 
    | complex_type_declare // complex return type
    ; 
    // just for simplicity


srt: NUMBERDECLARE {strcpy($$ , _yylval.type); } | STRINGDECLARE {strcpy($$ , _yylval.type); } | BOOLEENDECLARE {strcpy($$ , _yylval.type); } ;



params_eps: %empty
        | params
        ;
    

params: param comma_params;


comma_params: %empty
            | COMMA params
            ;


param: simple_type_declare ID { setupNewSimpleVariable($1); } ;
     | complex_type_declare ID { setupNewComplexVariable($1); }


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
 
        | BREAK SEMICOLON {yysuccess(1,"Break statement.") ;}
        | CONTINUE SEMICOLON {yysuccess(1,"Continue statement.") ;}
        | READ OPENPARENTHESIS ID { checkif_localsymbolexists(_yylval.ident); } CLOSEPARENTHESIS SEMICOLON {yysuccess(1, "Read input.");}
		| WRITE OPENPARENTHESIS expression CLOSEPARENTHESIS SEMICOLON {yysuccess(1, "Print output.");}
        | error SEMICOLON {yyerror("wrong statement"); yyerrok;}
        ;


simple_type_declare: NUMBERDECLARE {strcpy($$ , _yylval.type); }
		    | STRINGDECLARE {strcpy($$ , _yylval.type);}
			| CONSTDECLARE NUMBERDECLARE {strcpy($$ , "nombre constant");}
			| CONSTDECLARE STRINGDECLARE {strcpy($$ , "chaine constante"); }
			| BOOLEENDECLARE {strcpy($$ , _yylval.type); }
			| POINTERDECLARE {strcpy($$ , _yylval.type); }
			| STRUCTDECLARE {strcpy($$ , _yylval.type); }
            ;
complex_type_declare: NUMBERSYMBOL OPENBRACKET INTEGER CLOSEBRACKET UNDERSCORE {strcpy($$ , "number array"); saveSize(_yylval.ival); };
                    | STRINGSYMBOL OPENBRACKET INTEGER CLOSEBRACKET UNDERSCORE {strcpy($$ , "string array"); saveSize(_yylval.ival); };
                    | IF OPENBRACKET INTEGER CLOSEBRACKET UNDERSCORE {strcpy($$ , "boolean array"); saveSize(_yylval.ival); }
                    | TABLEDECLARE { strcpy($$ , _yylval.type); }
                    | STRINGSYMBOL INTEGER UNDERSCORE {strcpy($$ , "sized string"); saveSize(_yylval.ival);}
                    ;

just_declare: simple_type_declare ID { setupNewSimpleVariable($1); }
            | complex_type_declare ID { setupNewComplexVariable($1); }
            ;
init_declare: just_declare ASSIGNMENT expression 
            | just_declare ASSIGNMENT OPENBRACKET values_eps CLOSEBRACKET
            ;
values_eps: %empty { if(declared_size<effective_size) yywarning("Excess of elements in array initializer."); declared_size=-1; }
          | call_param /*static initialization of an array [ exp1, exp2, exp3, ... ]*/
          ;
            
declare: just_declare 
	   | init_declare 
       ;
struct_fields: simple_type_declare ID { char saveName[255];   if(_yylval.ident == NULL) { strcpy(saveName, save); } else { strcpy(saveName, _yylval.ident->symName); deleteEntry(symt, saveName); }  set_attr(symt->tail, $1, saveName); }
			 | simple_type_declare ID { set_fieldattribute($1); } COMMA struct_fields
             | complex_type_declare ID { yyerror("Complex types aren't allowed within structs."); } //just for now, don't panic
             ;

assign: var_exp ASSIGNMENT expression
	  | ADDRESSVALUE var ASSIGNMENT expression
	  | POINTERVALUE var ASSIGNMENT expression
      ;

ifstmt: IF OPENPARENTHESIS expression CLOSEPARENTHESIS OPENHOOK bloc CLOSEHOOK {yysuccess(1,"if stmt.");}
      | IF error OPENHOOK bloc CLOSEHOOK {yyerror("wrong syntax inside if()."); yyerrok;} 
      ;
elifstmt: ELSE OPENPARENTHESIS expression CLOSEPARENTHESIS OPENHOOK bloc CLOSEHOOK {yysuccess(1,"elif stmt.");}
        | ELSE error OPENHOOK bloc CLOSEHOOK {yyerror("wrong syntax inside elif()."); yyerrok;} 
        | elifstmt ELSE OPENPARENTHESIS expression CLOSEPARENTHESIS OPENHOOK bloc CLOSEHOOK {yysuccess(1,"elif elif stmt.");}
        ;
elsestmt: ELSE OPENPARENTHESIS CLOSEPARENTHESIS OPENHOOK bloc CLOSEHOOK {yysuccess(1,"else stmt.");}
        ;

call_param: expression {effective_size++; if(declared_size<effective_size) yywarning("Excess of elements in array initializer."); effective_size=0; declared_size=-1; }
		  | expression {effective_size++;} COMMA call_param 


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



const :    INTEGER 
	    |  REALNUMBER
        |  STRING
        |  TRUE
        |  FALSE
        ;

variable : var_exp
	| ID OPENPARENTHESIS {checkif_globalsymbolexists(_yylval.ident);} call_param CLOSEPARENTHESIS {yysuccess(1, "EXPRESSION : FUNCTION CALL");}
	| ID OPENPARENTHESIS {checkif_globalsymbolexists(_yylval.ident);} CLOSEPARENTHESIS {yysuccess(1, "EXPRESSION : FUNCTION CALL");}
	;

var_exp : var
	| ID {checkif_localsymbolexists(_yylval.ident);} OPENBRACKET expression CLOSEBRACKET {yysuccess(1, "EXPRESSION : ARRAY ACCESS");}
	;

accessfield: ID { char fieldnameCopy[50]; strcpy(fieldnameCopy, symt->tail->symName); checkif_fieldisvalid(save, fieldnameCopy); deleteEntry(symt, symt->tail->symName); }
		   | ID { deleteEntry(symt, symt->tail->symName); } DOT accessfield
           ;
var: ID {checkif_localsymbolexists(_yylval.ident);}
   | ID {checkif_localsymbolexists(_yylval.ident); strcpy(save, symt->tail->symName);} DOT accessfield
   ;

%%


void yyerror(char *s){
    fprintf(stdout, "File '%s', line %d, character %d : syntax error: " RED " %s " RESET "\n", currentFileName, yylineno, currentColumn, s);
    //fprintf(stdout, "%d: " RED " %s " RESET " \n", yylineno, s);
}

void yywarning(char *s){
    fprintf(stdout, "File '%s', line %d, character %d : warning: " YELLOW " %s " RESET "\n", currentFileName, yylineno, currentColumn, s);
    
}

void yysuccess(int i, char *s){
    if(i) fprintf(stdout, "%d: " GREEN " %s " RESET "\n", yylineno, s);
    else fprintf(stdout, "%d: %s\n", yylineno, s);
    currentColumn+=yyleng;
}


int main(int argc, char **argv) {

    currentFileName = argv[1];

    yyin = fopen(currentFileName, "r");
  
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

    if(_yylval.ident == NULL) strcpy(saveName, save); 
    else { 
        strcpy(saveName, _yylval.ident->symName); 
        deleteEntry(symt, saveName); 
        deleteEntry(symt, saveName); 
    } 
    
    set_attr(symt->tail, type, saveName);
}

void checkif_globalsymbolexists(SymTableNode* currentNode) {

    if(currentNode == NULL) {
        //yyerror("ID already in use.");
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

void checkif_fieldisvalid(char precedent[50], char fieldname[50]) { /*Works with variable.field*/


        SymTableNode* node = lookup(symt, precedent); //Look up its row

        if(node == NULL) return;

        AttrNode* typeattr_node = node->rootAttr; //Look up its type attribute

        if(typeattr_node == NULL) return;

        char* type; strcpy(type, typeattr_node->val); 

        char *str = malloc(strlen(type)); 

        strncpy(str, type + 1, strlen(type));

        SymTableNode* structnode = lookup(symt, str); /*Lookup the node where the struct type is declared (we need to remove the _ from the type string first)*/

        if (structnode == NULL) {
            printf("\n\nType wasn't found %s\n\n", str);
            return;
        } 


        AttrNode* fieldattr_node = structnode->rootAttr;

        if(fieldattr_node == NULL) return;
        
        fieldattr_node = fieldattr_node->next; /*rootAttr node is dedicated for the type=typestruct, we need to skip it*/

        while(fieldattr_node != NULL) {


            if(strcmp(fieldattr_node->val, fieldname) == 0 ) {
                yysuccess(1, "Field exists!"); return;
            }

            fieldattr_node = fieldattr_node -> next;

        }

        yyerror("Field doesn't exist for this type.");

}

void saveSize(int ival) {
    declared_size=ival; 
    if(declared_size<0) { 
        yyerror("The size of an array needs to be a positive integer."); 
        /* declared_size=-1 */
    }
}


void setupNewSimpleVariable(char type[255]) {
    if(_yylval.ident == NULL) yyerror("ID already declared!"); 
    else set_attr(_yylval.ident, "type", type);
}

void setupNewComplexVariable(char type[255]) {
    if(_yylval.ident == NULL) yyerror("ID already declared!"); 
    else { 
        set_attr(_yylval.ident, "type", type); 
        char str[5];
        sprintf(str, "%d", declared_size); 
        if(declared_size!=-1) set_attr(_yylval.ident, "size", str); 
        /* declared_size=-1;  */
    }
}

