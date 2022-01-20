
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
    #include "misc.h"
    #include "ast.h"
    #include "semantic.h"
}

%union {
    char string[255];

    int token_type;
    struct boolean_expression boolean_expression;
    struct expression expression;
    struct statement statement;
    struct ifstatement ifstatement; 
}

%token ENTRY

%token LOOP "loop"
%token IF "?"
%token ELSE ":"

%token READ
%token WRITE

%token BREAK "break"
%token CONTINUE "continue"

%token <string> ID
%type <string> type_declare
%type <string> just_declare
/* %type <string> struct_fields */
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
%token <token_type> CLOSEHOOK "}"

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

%token INTEGER
%token REALNUMBER
%token STRING

%token TRUE
%token FALSE

// special token
%type <token_type> M;
%type <statement> statement bloc N ifstmtonly;
%type <ifstatement>  ifstmt elsestmt;
%type <expression> expression;
%type <expression> var_exp; 


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
    int currentColumn = 1;
    int showsuccess = 0;
    
    _YYSTYPE _yylval;

    /* Set of instruction of the current statement */
    quadruplets_node quads[MAXCODE];
    int currentInstruction = 0;

    // temp name storage just for testing
    // cuz they must be stored in the semtable
    char tempnames[255][255]; int indicator;

%}

%%



underscore: %empty
        | underscore func
        | error func {yyerrok;}
        ;

func: FUNCTIONDECLARE ret ID { 
        _yylval.ident->symType = FUNCTIONDECLARE; 
        set_attr(_yylval.ident, "typeretour", $<string>2); 
        } OPENPARENTHESIS params_eps CLOSEPARENTHESIS OPENHOOK bloc CLOSEHOOK { 
            insertNewGlobalEntry(gSymT, symt); symt = allocateSymTable();
            yysuccess(1,"function ended.");
            for(int i = 0; i < currentInstruction; i++){
                print_quadruplets_node(&quads[i]);
            }
            printf("NB INST: %d\n", currentInstruction);
            print_tempnames();
        }


ret: %empty {strcpy($$ , "void");}
    | srt // simple return type 
    | crt // complex return type
    ; 
    // just for simplicity


srt: NUMBERDECLARE {strcpy($$ , _yylval.type); } | STRINGDECLARE {strcpy($$ , _yylval.type); } | BOOLEENDECLARE {strcpy($$ , _yylval.type); } ;

crt: TABLEDECLARE {strcpy($$ , _yylval.type); };


params_eps: %empty
        | params
        ;
    

params: param comma_params;


comma_params: %empty
            | COMMA params
            ;


param: type_declare ID { if(_yylval.ident == NULL) yyerror_semantic("ID already declared!"); else set_attr(_yylval.ident, "type", $1); } ;



bloc: bloc  statement  M {
            yysuccess(1, "Block.");
           if ($2.nextlist != NULL){
                backpatch(quads, currentInstruction+1, $2.nextlist, $3);
                $$.nextlist = $2.nextlist;
           }
        }
    
     | %empty {
        /*yysuccess(1, "Emptyness.");*/

     } 
     ;

statement: declare SEMICOLON {
            /*yysuccess(1, "Simple declaration / with assign.");*/
            $$.nextlist = NULL;
        }


		| assign SEMICOLON {
            /*yysuccess(1, "Assignment.");*/

        }
        | LOOP M OPENPARENTHESIS  expression  CLOSEPARENTHESIS OPENHOOK M bloc CLOSEHOOK {
if (!$4.is_boolean){yyerror_semantic("expression in loop() should be boolean! ");}
            backpatch(quads, currentInstruction+1, $8.nextlist, $2);
            backpatch(quads, currentInstruction+1, $4.boolean_expression.truelist, $7);
            $$.nextlist = $4.boolean_expression.falselist;
            
            union operandValue* operand1_val = create_operand_value();
            union operandValue* operand2_val = create_operand_value();
            union operandValue* result_val = create_operand_value();
            operand1_val->label = $2;

            operand2_val->empty = 1;
            result_val->empty = 1;

             // gen quad
            quadruplets_node* quad = create_quadruplet(currentInstruction, quadruplets_operators_names[BR],
                                               create_operand(Labels, operand1_val), create_operand(Empty,operand2_val), create_operand(Empty, result_val));
            quads[currentInstruction] = *quad;
            currentInstruction++;

        }
		| LOOP M OPENPARENTHESIS assign SEMICOLON M expression SEMICOLON M assign M CLOSEPARENTHESIS OPENHOOK M bloc CLOSEHOOK {
if (!$7.is_boolean){yyerror_semantic("expression in loop() should be boolean! ");}
            backpatch(quads, currentInstruction+1, $15.nextlist, $6);
            backpatch(quads, currentInstruction+1, $7.boolean_expression.truelist, $14);
            $$.nextlist = $7.boolean_expression.falselist;
            
            union operandValue* operand1_val = create_operand_value();
            union operandValue* operand2_val = create_operand_value();
            union operandValue* result_val = create_operand_value();
            operand1_val->label = $6;

            operand2_val->empty = 1;
            result_val->empty = 1;

            // migrate instructions
            migrate(quads, $9, $11-1, $14, currentInstruction-1);

             // gen quad
            quadruplets_node* quad = create_quadruplet(currentInstruction, quadruplets_operators_names[BR],
                                               create_operand(Labels, operand1_val), create_operand(Empty,operand2_val), create_operand(Empty, result_val));
            quads[currentInstruction] = *quad;
            currentInstruction++;
        }
		| LOOP M OPENPARENTHESIS init_declare SEMICOLON M expression SEMICOLON M assign M CLOSEPARENTHESIS OPENHOOK M bloc CLOSEHOOK {
if (!$7.is_boolean){yyerror_semantic("expression in loop() should be boolean! ");}
            backpatch(quads, currentInstruction+1, $15.nextlist, $6);
            backpatch(quads, currentInstruction+1, $7.boolean_expression.truelist, $14);
            $$.nextlist = $7.boolean_expression.falselist;
            
            union operandValue* operand1_val = create_operand_value();
            union operandValue* operand2_val = create_operand_value();
            union operandValue* result_val = create_operand_value();
            operand1_val->label = $6;

            operand2_val->empty = 1;
            result_val->empty = 1;

            // migrate instructions
            migrate(quads, $9, $11-1, $14, currentInstruction-1);

             // gen quad
            quadruplets_node* quad = create_quadruplet(currentInstruction, quadruplets_operators_names[BR],
                                               create_operand(Labels, operand1_val), create_operand(Empty,operand2_val), create_operand(Empty, result_val));
            quads[currentInstruction] = *quad;
            currentInstruction++;
        }
        
        
        | ifstmtonly {
            $$.nextlist = $1.nextlist;
            
        }
         | ifstmt elsestmt {
            $$.nextlist = $2.nextlist;
        }
        ;


type_declare: NUMBERDECLARE {strcpy($$ , _yylval.type); }
		    | STRINGDECLARE {strcpy($$ , _yylval.type);}
			/*| CONSTDECLARE NUMBERDECLARE {strcpy($$ , "nombre constant");}
			| CONSTDECLARE STRINGDECLARE {strcpy($$ , "chaine constante"); }*/
			| BOOLEENDECLARE {strcpy($$ , _yylval.type); }
			/*| POINTERDECLARE {strcpy($$ , _yylval.type); }*/
			| TABLEDECLARE {strcpy($$ , _yylval.type); }
			/*| STRUCTDECLARE {strcpy($$ , _yylval.type); } */
            ;
just_declare: type_declare ID { 
                if(_yylval.ident == NULL) yyerror_semantic("ID already declared!"); 
                else set_attr(_yylval.ident, "type", $1);
            }
            ;
init_declare: just_declare ASSIGNMENT expression {

                    char sym[255];
		    char val[255];	
		    bool type_checked=false;

                    // get symbole from symtable
                    strcpy(sym, symt->tail->symName);
                    printf("Symbol declared recenlty: %s\n", sym);
                        AttrNode *node = symt->tail->rootAttr;
                        while(node != NULL){
                            if(strcmp(node->name,"type")== 0){
                            if($3.is_boolean){
                        if(strcmp(node->val,"boolean")== 0)			{type_checked=true;yysuccess(1,"boolean checked");}
            else{yyerror_semantic("type mismatch");}
            }
                            else if($3.is_string){
            if( strcmp(node->val,"string")== 0){type_checked=true;yysuccess(1,"string checked");}else{yyerror_semantic("type mismatch");}}
                            else if(strcmp(node->val,"number")== 0){type_checked=true;yysuccess(1,"number checked");}
            else{yyerror_semantic("type mismatch");}
                        }
                        node=node->next;
                        }	

		    if(type_checked==1){
				
                    if (!$3.is_boolean){
			
                        union operandValue* operand1_val = create_operand_value();
                        union operandValue* operand2_val = create_operand_value();
                        union operandValue* result_val = create_operand_value();
                        
                        operand* operand1;
                        operand* operand2;
                        operand* result;
                        
                        // operand1 management
                        if ($3.arithmetic_expression.is_litteral){
                            operand1_val->integer = $3.arithmetic_expression.value;
                            operand1 = create_operand(Integers , operand1_val);
                        }else{
                            // strcpy(operand1_val->variable, $3.arithmetic_expression.sym);
                            // fetch symbole from symtable normally
                            strcpy(operand1_val->variable, tempnames[indicator-1]);
                            operand1 = create_operand(Variable , operand1_val);
                        }
                        operand2_val->empty = true; // or 1
                        operand2 = create_operand(Empty , operand1_val);

                        strcpy(result_val->variable, sym);
                        // printf("ID: %s\n", $<string>2);
                        result = create_operand(Variable, result_val);


                        quadruplets_node* quad = create_quadruplet(currentInstruction, quadruplets_operators_names[AFFECT],
                                                            operand1, operand2, result);
                        quads[currentInstruction] = *quad;
                        currentInstruction++;
                    }} 
            }
            /* | just_declare ASSIGNMENT OPENBRACKET values_eps CLOSEBRACKET */
            ;
/* values_eps: %empty
          | call_param /*static initialization of an array [ exp1, exp2, exp3, ... ]*/
          ; 
            
declare: just_declare
	 | init_declare
       ;
/* struct_fields: type_declare ID { char saveName[255];   if(_yylval.ident == NULL) { strcpy(saveName, save); } else { strcpy(saveName, _yylval.ident->symName); deleteEntry(symt, saveName); }  set_attr(symt->tail, $1, saveName); }
			 | type_declare ID { set_fieldattribute($1); } COMMA struct_fields
             ; */

// TODO change this to var_exp
assign: ID {
            // strcpy($<string>$ , _yylval.ident->symName);
            char saveName[255];   
            if(_yylval.ident == NULL) { 
                strcpy($<string>$, save); 
            } else { 
                strcpy($<string>$, _yylval.ident->symName);
            }
            
        } ASSIGNMENT expression {
            if (!$4.is_boolean){
                union operandValue* operand1_val = create_operand_value();
                union operandValue* operand2_val = create_operand_value();
                union operandValue* result_val = create_operand_value();
                
                operand* operand1;
                operand* operand2;
                operand* result;
                
                // operand1 management
                if ($4.arithmetic_expression.is_litteral){
                    operand1_val->integer = $4.arithmetic_expression.value;
                    operand1 = create_operand(Integers , operand1_val);
                }else{
                    // strcpy(operand1_val->variable, $4.arithmetic_expression.sym);
                    // fetch symbole from symtable normally
                    strcpy(operand1_val->variable, tempnames[indicator-1]);
                    operand1 = create_operand(Variable , operand1_val);
                }
                operand2_val->empty = true; // or 1
                operand2 = create_operand(Empty , operand1_val);

                strcpy(result_val->variable, $<string>2);
                // printf("ID: %s\n", $<string>2);
                result = create_operand(Variable, result_val);


                quadruplets_node* quad = create_quadruplet(currentInstruction, quadruplets_operators_names[AFFECT],
                                                    operand1, operand2, result);
                quads[currentInstruction] = *quad;
                currentInstruction++;
            }
      }
	  /* | ADDRESSVALUE var ASSIGNMENT expression
	  | POINTERVALUE var ASSIGNMENT expression */
	  | var_exp ASSIGNMENT expression 
      ;

ifstmtonly: IF OPENPARENTHESIS expression CLOSEPARENTHESIS OPENHOOK M bloc CLOSEHOOK {
if (!$3.is_boolean){yyerror_semantic("expression in ?() should be boolean!");}
            // yysuccess(1,"if stmt.");
            // Check if <expression> is boolean, otherwise throw a semantic error

            backpatch(quads,currentInstruction+1, $3.boolean_expression.truelist, $6);
            // printf("False list: %d", $3.boolean_expression.falselist->index);
            $$.nextlist = merge($3.boolean_expression.falselist, $7.nextlist);
            

        }
ifstmt: IF OPENPARENTHESIS expression CLOSEPARENTHESIS OPENHOOK M bloc CLOSEHOOK {
            // backpatch(quads,currentInstruction+1, $3.boolean_expression.truelist, $6);
            // backpatch(quads,currentInstruction+1, $3.boolean_expression.falselist, $6);
            // $$.nextlist = merge($3.boolean_expression.falselist, $7.nextlist);
            $$.boolean_expression.truelist = $3.boolean_expression.truelist;
            $$.boolean_expression.falselist = $3.boolean_expression.falselist;
            $$.m1 = $6;
    }
elsestmt: N ELSE M OPENPARENTHESIS CLOSEPARENTHESIS OPENHOOK bloc CLOSEHOOK {
            yysuccess(1,"else stmt.");

            backpatch(quads, currentInstruction+1, ($<ifstatement>0).boolean_expression.truelist, ($<ifstatement>0).m1); // backpatch it to M1.inst
            backpatch(quads, currentInstruction+1, ($<ifstatement>0).boolean_expression.falselist, $3); // backpatch it toM2.inst
            struct jump_indices* temp = merge(($<ifstatement>0).nextlist, $1.nextlist);

            $$.nextlist = merge(temp, $7.nextlist);
        };
        


//General formula for experession
expression: 
    OPENPARENTHESIS expression CLOSEPARENTHESIS {
        if ($2.is_boolean){
            $$.is_boolean = true;
            $$.boolean_expression.falselist = $2.boolean_expression.falselist;
            $$.boolean_expression.truelist = $2.boolean_expression.truelist;
        }
        else if($2.arithmetic_expression.is_litteral){
            $$.arithmetic_expression.value = $2.arithmetic_expression.value;
            $$.arithmetic_expression.is_litteral = $2.arithmetic_expression.is_litteral;
            // printf("VALUE: x) %d\n", $2.arithmetic_expression.value);
        }
        else if($2.is_string){

	        $$.is_string = true;
        }
        else{
                // is expression
                strcpy($$.arithmetic_expression.sym, tempnames[indicator-1]);
            }
        }

    | OPENPARENTHESIS error CLOSEPARENTHESIS { /* stop code */ }
	| NON expression {
        if ($2.is_boolean){
            $$.is_boolean = true;
            $$.boolean_expression.truelist = $2.boolean_expression.falselist;
            $$.boolean_expression.falselist = $2.boolean_expression.truelist;
        }
	else{yyerror("Expression after ! need to be boolean");}
    }
	/* | POINTERVALUE var_exp
	| ADDRESSVALUE var_exp */

    | expression OR M expression{
        
        if ($1.is_boolean && $4.is_boolean){
            $$.is_boolean = true;
            backpatch(quads ,currentInstruction+1, $1.boolean_expression.falselist, $3);
            $$.boolean_expression.truelist = merge($1.boolean_expression.truelist, $4.boolean_expression.truelist);
            $$.boolean_expression.falselist = $4.boolean_expression.falselist;
        }
	else if (!$1.is_boolean){yyerror("Expression before || need to be boolean");}
	else{yyerror("Expression after || need to be boolean");}
    }
    | expression AND M expression {
        if ($1.is_boolean && $4.is_boolean){
            $$.is_boolean = true;
            backpatch(quads, currentInstruction+1,$1.boolean_expression.truelist, $3);
            $$.boolean_expression.truelist = $4.boolean_expression.truelist;
            $$.boolean_expression.falselist = merge($1.boolean_expression.falselist, $4.boolean_expression.falselist);
        }
	else if (!$1.is_boolean){yyerror("Expression before && need to be boolean");}
	else{yyerror("Expression after && need to be boolean");}
    }
    | expression EQUAL expression{

	if($1.is_boolean && $3.is_boolean){$$.is_boolean = true;}

	else if ($1.is_string && $3.is_string){$$.is_boolean = true;}

	else if ($1.arithmetic_expression.is_litteral && $3.arithmetic_expression.is_litteral){
            $$.is_boolean = true;
            $$.boolean_expression.truelist = makelist(currentInstruction);
            $$.boolean_expression.falselist = makelist(currentInstruction+1);

            union operandValue* operand1_val = create_operand_value();
            union operandValue* operand2_val = create_operand_value();
            union operandValue* result_val = create_operand_value();
        
            operand* operand1;
            operand* operand2;
            operand* result;
        
            operand1_val->label = -1;
            operand1 = create_operand(Labels, operand1_val);
            // operand1 management
            if ($1.arithmetic_expression.is_litteral){
                operand2_val->integer = $1.arithmetic_expression.value;
                operand2 = create_operand(Integers , operand2_val);
            }else{
                strcpy(operand2_val->variable, $1.arithmetic_expression.sym);
                operand2 = create_operand(Variable , operand2_val);
            }
            // operand2 management
            if ($3.arithmetic_expression.is_litteral){
                result_val->integer = $3.arithmetic_expression.value;
                result = create_operand(Integers , result_val);
            }else{
                strcpy(result_val->variable, $3.arithmetic_expression.sym);
                result = create_operand(Variable , result_val);
            }


            quadruplets_node* quad = create_quadruplet(currentInstruction, quadruplets_operators_names[BE],
                                                operand1, operand2, result);
            
            // indicator++;
            quads[currentInstruction] = *quad;
            currentInstruction++;


            operand1_val->label = -1; operand1=create_operand(Labels, operand1_val);
            operand2_val->empty = 1; operand2=create_operand(Empty, operand1_val);
            result_val->empty = 1; result=create_operand(Empty, operand1_val);
            quad = create_quadruplet(currentInstruction, quadruplets_operators_names[BR],
                                                operand1, operand2, result);
            
            quads[currentInstruction] = *quad;
            currentInstruction++;

	}
	else{yyerror_semantic(" = takes Expressions of same type");}

    }
    | expression NONEQUAL expression{
	if($1.is_boolean && $3.is_boolean){$$.is_boolean = true;}

	else if ($1.is_string && $3.is_string){$$.is_boolean = true;}

	else if ($1.arithmetic_expression.is_litteral && $3.arithmetic_expression.is_litteral){
            $$.is_boolean = true;
            $$.boolean_expression.truelist = makelist(currentInstruction);
            $$.boolean_expression.falselist = makelist(currentInstruction+1);

            union operandValue* operand1_val = create_operand_value();
            union operandValue* operand2_val = create_operand_value();
            union operandValue* result_val = create_operand_value();
        
            operand* operand1;
            operand* operand2;
            operand* result;
        
            operand1_val->label = -1;
            operand1 = create_operand(Labels, operand1_val);
            // operand1 management
            if ($1.arithmetic_expression.is_litteral){
                operand2_val->integer = $1.arithmetic_expression.value;
                operand2 = create_operand(Integers , operand2_val);
            }else{
                strcpy(operand2_val->variable, $1.arithmetic_expression.sym);
                operand2 = create_operand(Variable , operand2_val);
            }
            // operand2 management
            if ($3.arithmetic_expression.is_litteral){
                result_val->integer = $3.arithmetic_expression.value;
                result = create_operand(Integers , result_val);
            }else{
                strcpy(result_val->variable, $3.arithmetic_expression.sym);
                result = create_operand(Variable , result_val);
            }


            quadruplets_node* quad = create_quadruplet(currentInstruction, quadruplets_operators_names[BNE],
                                                operand1, operand2, result);
            
            // indicator++;
            quads[currentInstruction] = *quad;
            currentInstruction++;


            operand1_val->label = -1; operand1=create_operand(Labels, operand1_val);
            operand2_val->empty = 1; operand2=create_operand(Empty, operand1_val);
            result_val->empty = 1; result=create_operand(Empty, operand1_val);
            quad = create_quadruplet(currentInstruction, quadruplets_operators_names[BR],
                                                operand1, operand2, result);
            
            quads[currentInstruction] = *quad;
            currentInstruction++;

        }
	else{yyerror_semantic(" != takes Expressions of same type");}
    }

    | expression INFERIOR expression {
	if ($1.is_string || $3.is_string || $1.is_boolean || $3.is_boolean){yyerror_semantic("invalid type for this operation");}

	else if ($1.arithmetic_expression.is_litteral && $3.arithmetic_expression.is_litteral){
            $$.is_boolean = true;
            $$.boolean_expression.truelist = makelist(currentInstruction);
            $$.boolean_expression.falselist = makelist(currentInstruction+1);

            union operandValue* operand1_val = create_operand_value();
            union operandValue* operand2_val = create_operand_value();
            union operandValue* result_val = create_operand_value();
        
            operand* operand1;
            operand* operand2;
            operand* result;
        
            operand1_val->label = -1;
            operand1 = create_operand(Labels, operand1_val);
            // operand1 management
            if ($1.arithmetic_expression.is_litteral){
                operand2_val->integer = $1.arithmetic_expression.value;
                operand2 = create_operand(Integers , operand2_val);
            }else{
                strcpy(operand2_val->variable, $1.arithmetic_expression.sym);
                operand2 = create_operand(Variable , operand2_val);
            }
            // operand2 management
            if ($3.arithmetic_expression.is_litteral){
                result_val->integer = $3.arithmetic_expression.value;
                result = create_operand(Integers , result_val);
            }else{
                strcpy(result_val->variable, $3.arithmetic_expression.sym);
                result = create_operand(Variable , result_val);
            }


            quadruplets_node* quad = create_quadruplet(currentInstruction, quadruplets_operators_names[BL],
                                                operand1, operand2, result);
            

            quads[currentInstruction] = *quad;
            currentInstruction++;

            operand1_val->label = -1; operand1=create_operand(Labels, operand1_val);
            operand2_val->empty = 1; operand2=create_operand(Empty, operand1_val);
            result_val->empty = 1; result=create_operand(Empty, operand1_val);
            quad = create_quadruplet(currentInstruction, quadruplets_operators_names[BR],
                                                operand1, operand2, result);
            
            quads[currentInstruction] = *quad;
            currentInstruction++;

        }
	else{yyerror_semantic(" < takes Expressions of same type");}
    }
    | expression INFERIOREQUAL expression{
        if ($1.is_string || $3.is_string || $1.is_boolean || $3.is_boolean){yyerror_semantic("invalid type for this opperation");}

	else if ($1.arithmetic_expression.is_litteral && $3.arithmetic_expression.is_litteral){
            $$.is_boolean = true;
            $$.boolean_expression.truelist = makelist(currentInstruction);
            $$.boolean_expression.falselist = makelist(currentInstruction+1);

            union operandValue* operand1_val = create_operand_value();
            union operandValue* operand2_val = create_operand_value();
            union operandValue* result_val = create_operand_value();
        
            operand* operand1;
            operand* operand2;
            operand* result;
        
            operand1_val->label = -1;
            operand1 = create_operand(Labels, operand1_val);
            // operand1 management
            if ($1.arithmetic_expression.is_litteral){
                operand2_val->integer = $1.arithmetic_expression.value;
                operand2 = create_operand(Integers , operand2_val);
            }else{
                strcpy(operand2_val->variable, $1.arithmetic_expression.sym);
                operand2 = create_operand(Variable , operand2_val);
            }
            // operand2 management
            if ($3.arithmetic_expression.is_litteral){
                result_val->integer = $3.arithmetic_expression.value;
                result = create_operand(Integers , result_val);
            }else{
                strcpy(result_val->variable, $3.arithmetic_expression.sym);
                result = create_operand(Variable , result_val);
            }


            quadruplets_node* quad = create_quadruplet(currentInstruction, quadruplets_operators_names[BLE],
                                                operand1, operand2, result);
            
            quads[currentInstruction] = *quad;
            currentInstruction++;

            operand1_val->label = -1; operand1=create_operand(Labels, operand1_val);
            operand2_val->empty = 1; operand2=create_operand(Empty, operand1_val);
            result_val->empty = 1; result=create_operand(Empty, operand1_val);
            quad = create_quadruplet(currentInstruction, quadruplets_operators_names[BR],
                                                operand1, operand2, result);
            
            quads[currentInstruction] = *quad;
            currentInstruction++;

        }
	else{yyerror_semantic(" <= takes Expressions of same type");}

    }
    | expression SUPERIOR expression {
	if ($1.is_string || $3.is_string || $1.is_boolean || $3.is_boolean){yyerror_semantic("invalid type for this opperation");}

	if ($1.arithmetic_expression.is_litteral && $3.arithmetic_expression.is_litteral){
            $$.is_boolean = true;
            $$.boolean_expression.truelist = makelist(currentInstruction);
            $$.boolean_expression.falselist = makelist(currentInstruction+1);

            union operandValue* operand1_val = create_operand_value();
            union operandValue* operand2_val = create_operand_value();
            union operandValue* result_val = create_operand_value();
        
            operand* operand1;
            operand* operand2;
            operand* result;
        
            operand1_val->label = -1;
            operand1 = create_operand(Labels, operand1_val);
            // operand1 management
            if ($1.arithmetic_expression.is_litteral){
                operand2_val->integer = $1.arithmetic_expression.value;
                operand2 = create_operand(Integers , operand2_val);
            }else{
                strcpy(operand2_val->variable, $1.arithmetic_expression.sym);
                operand2 = create_operand(Variable , operand2_val);
            }
            // operand2 management
            if ($3.arithmetic_expression.is_litteral){
                result_val->integer = $3.arithmetic_expression.value;
                result = create_operand(Integers , result_val);
            }else{
                strcpy(result_val->variable, $3.arithmetic_expression.sym);
                result = create_operand(Variable , result_val);
            }


            quadruplets_node* quad = create_quadruplet(currentInstruction, quadruplets_operators_names[BG],
                                                operand1, operand2, result);
            

            quads[currentInstruction] = *quad;
            currentInstruction++;

            operand1_val->label = -1; operand1=create_operand(Labels, operand1_val);
            operand2_val->empty = 1; operand2=create_operand(Empty, operand1_val);
            result_val->empty = 1; result=create_operand(Empty, operand1_val);
            quad = create_quadruplet(currentInstruction, quadruplets_operators_names[BR],
                                                operand1, operand2, result);
            
            quads[currentInstruction] = *quad;
            currentInstruction++;

        }
	else{yyerror_semantic(" > takes Expressions of same type");}

    }
    | expression SUPERIOREQUAL expression{
        if ($1.is_string || $3.is_string || $1.is_boolean || $3.is_boolean){yyerror_semantic("invalid type for this opperation");}

	else if ($1.arithmetic_expression.is_litteral && $3.arithmetic_expression.is_litteral){
            $$.is_boolean = true;
            $$.boolean_expression.truelist = makelist(currentInstruction);
            $$.boolean_expression.falselist = makelist(currentInstruction+1);

            union operandValue* operand1_val = create_operand_value();
            union operandValue* operand2_val = create_operand_value();
            union operandValue* result_val = create_operand_value();
        
            operand* operand1;
            operand* operand2;
            operand* result;
        
            operand1_val->label = -1;
            operand1 = create_operand(Labels, operand1_val);
            // operand1 management
            if ($1.arithmetic_expression.is_litteral){
                operand2_val->integer = $1.arithmetic_expression.value;
                operand2 = create_operand(Integers , operand2_val);
            }else{
                strcpy(operand2_val->variable, $1.arithmetic_expression.sym);
                operand2 = create_operand(Variable , operand2_val);
            }
            // operand2 management
            if ($3.arithmetic_expression.is_litteral){
                result_val->integer = $3.arithmetic_expression.value;
                result = create_operand(Integers , result_val);
            }else{
                strcpy(result_val->variable, $3.arithmetic_expression.sym);
                result = create_operand(Variable , result_val);
            }


            quadruplets_node* quad = create_quadruplet(currentInstruction, quadruplets_operators_names[BGE],
                                                operand1, operand2, result);
            

            quads[currentInstruction] = *quad;
            currentInstruction++;

            operand1_val->label = -1; operand1=create_operand(Labels, operand1_val);
            operand2_val->empty = 1; operand2=create_operand(Empty, operand1_val);
            result_val->empty = 1; result=create_operand(Empty, operand1_val);
            quad = create_quadruplet(currentInstruction, quadruplets_operators_names[BR],
                                                operand1, operand2, result);
            
            quads[currentInstruction] = *quad;
            currentInstruction++;
            

        }
	else{yyerror_semantic(" >= takes Expressions of same type");}

    }

    // Arithmetic expressions
    | expression ADD expression {
	if ($1.is_string || $3.is_string || $1.is_boolean || $3.is_boolean){yyerror_semantic("invalid type for this opperation");}

	else if ($1.arithmetic_expression.is_litteral && $3.arithmetic_expression.is_litteral){
        $$.is_boolean = false;
        union operandValue* operand1_val = create_operand_value();
        union operandValue* operand2_val = create_operand_value();
        union operandValue* result_val = create_operand_value();
        
        operand* operand1;
        operand* operand2;
        operand* result;
        
        // operand1 management
        if ($1.arithmetic_expression.is_litteral){
            operand1_val->integer = $1.arithmetic_expression.value;
            operand1 = create_operand(Integers , operand1_val);
        }else{
            strcpy(operand1_val->variable, $1.arithmetic_expression.sym);
            operand1 = create_operand(Variable , operand1_val);
        }
        // operand2 management
        if ($3.arithmetic_expression.is_litteral){
            operand2_val->integer = $3.arithmetic_expression.value;
            operand2 = create_operand(Integers , operand2_val);
        }else{
            strcpy(operand2_val->variable, $3.arithmetic_expression.sym);
            operand2 = create_operand(Variable , operand2_val);
        }
        strcpy(tempnames[indicator], gentemp());
        
        strcpy(result_val->variable, tempnames[indicator]);
        result = create_operand(Variable, result_val);
        // int x = indicator;
        


        quadruplets_node* quad = create_quadruplet(currentInstruction, quadruplets_operators_names[PLUS],
                                               operand1, operand2, result);
        
        indicator++;
        quads[currentInstruction] = *quad;
        currentInstruction++;
        $$.arithmetic_expression.is_litteral = false;
        strcpy($$.arithmetic_expression.sym, tempnames[indicator-1]);}
	else{yyerror_semantic(" >= takes Expressions of same type");}

    }
    | expression SUB expression {
	if ($1.is_string || $3.is_string || $1.is_boolean || $3.is_boolean){yyerror_semantic("invalid type for this opperation");}

	else if ($1.arithmetic_expression.is_litteral && $3.arithmetic_expression.is_litteral){
        $$.is_boolean = false;
        union operandValue* operand1_val = create_operand_value();
        union operandValue* operand2_val = create_operand_value();
        union operandValue* result_val = create_operand_value();
        
        operand* operand1;
        operand* operand2;
        operand* result;
        
        // operand1 management
        if ($1.arithmetic_expression.is_litteral){
            operand1_val->integer = $1.arithmetic_expression.value;
            operand1 = create_operand(Integers , operand1_val);
        }else{
            strcpy(operand1_val->variable, $1.arithmetic_expression.sym);
            operand1 = create_operand(Variable , operand1_val);
        }
        // operand2 management
        if ($3.arithmetic_expression.is_litteral){
            operand2_val->integer = $3.arithmetic_expression.value;
            operand2 = create_operand(Integers , operand2_val);
        }else{
            strcpy(operand2_val->variable, $3.arithmetic_expression.sym);
            operand2 = create_operand(Variable , operand2_val);
        }
        strcpy(tempnames[indicator], gentemp());
        
        strcpy(result_val->variable, tempnames[indicator]);
        result = create_operand(Variable, result_val);


        quadruplets_node* quad = create_quadruplet(currentInstruction, quadruplets_operators_names[MINUS],
                                               operand1, operand2, result);
        indicator++;
        quads[currentInstruction] = *quad;
        currentInstruction++;
        $$.arithmetic_expression.is_litteral = false;
        strcpy($$.arithmetic_expression.sym, tempnames[indicator-1]);}
	else{yyerror_semantic(" >= takes Expressions of same type");}

    }
    | expression MULT expression {
	if ($1.is_string || $3.is_string || $1.is_boolean || $3.is_boolean){yyerror_semantic("invalid type for this opperation");}

	else if ($1.arithmetic_expression.is_litteral && $3.arithmetic_expression.is_litteral){
        $$.is_boolean = false;
        union operandValue* operand1_val = create_operand_value();
        union operandValue* operand2_val = create_operand_value();
        union operandValue* result_val = create_operand_value();
        
        operand* operand1;
        operand* operand2;
        operand* result;
        
        // operand1 management
        if ($1.arithmetic_expression.is_litteral){
            operand1_val->integer = $1.arithmetic_expression.value;
            operand1 = create_operand(Integers , operand1_val);
        }else{
            strcpy(operand1_val->variable, $1.arithmetic_expression.sym);
            operand1 = create_operand(Variable , operand1_val);
        }
        // operand2 management
        if ($3.arithmetic_expression.is_litteral){
            operand2_val->integer = $3.arithmetic_expression.value;
            operand2 = create_operand(Integers , operand2_val);
        }else{
            strcpy(operand2_val->variable, $3.arithmetic_expression.sym);
            operand2 = create_operand(Variable , operand2_val);
        }
        strcpy(tempnames[indicator], gentemp());
        
        strcpy(result_val->variable, tempnames[indicator]);
        result = create_operand(Variable, result_val);


        quadruplets_node* quad = create_quadruplet(currentInstruction, quadruplets_operators_names[MULTIPLY],
                                               operand1, operand2, result);
        indicator++;
        quads[currentInstruction] = *quad;
        currentInstruction++;
        $$.arithmetic_expression.is_litteral = false;
        strcpy($$.arithmetic_expression.sym, tempnames[indicator-1]);}
	else{yyerror_semantic(" >= takes Expressions of same type");}
    }
    | expression DIV expression {
	if ($1.is_string || $3.is_string || $1.is_boolean || $3.is_boolean){yyerror_semantic("invalid type for this opperation");}

	else if ($1.arithmetic_expression.is_litteral && $3.arithmetic_expression.is_litteral){
        $$.is_boolean = false;
        union operandValue* operand1_val = create_operand_value();
        union operandValue* operand2_val = create_operand_value();
        union operandValue* result_val = create_operand_value();
        
        operand* operand1;
        operand* operand2;
        operand* result;
        
        // operand1 management
        if ($1.arithmetic_expression.is_litteral){
            operand1_val->integer = $1.arithmetic_expression.value;
            operand1 = create_operand(Integers , operand1_val);
        }else{
            strcpy(operand1_val->variable, $1.arithmetic_expression.sym);
            operand1 = create_operand(Variable , operand1_val);
        }
        // operand2 management
        if ($3.arithmetic_expression.is_litteral){
            operand2_val->integer = $3.arithmetic_expression.value;
            operand2 = create_operand(Integers , operand2_val);
        }else{
            strcpy(operand2_val->variable, $3.arithmetic_expression.sym);
            operand2 = create_operand(Variable , operand2_val);
        }
        strcpy(tempnames[indicator], gentemp());
        
        strcpy(result_val->variable, tempnames[indicator]);
        result = create_operand(Variable, result_val);


        quadruplets_node* quad = create_quadruplet(currentInstruction, quadruplets_operators_names[DIVIDE],
                                               operand1, operand2, result);
        indicator++;
        quads[currentInstruction] = *quad;
        currentInstruction++;
        $$.arithmetic_expression.is_litteral = false;
        strcpy($$.arithmetic_expression.sym, tempnames[indicator-1]);}
	else{yyerror_semantic(" >= takes Expressions of same type");}
    }

    // Frozen for the moment since we don't have quad ops for these high level operations
    | expression MOD expression {
        // $$.is_boolean = false;
        // union operandValue* operand1_val = create_operand_value();
        // union operandValue* operand2_val = create_operand_value();
        // union operandValue* result_val = create_operand_value();
        
        // operand* operand1;
        // operand* operand2;
        // operand* result;
        
        // // operand1 management
        // if ($1.arithmetic_expression.is_litteral){
        //     operand1_val->integer = $1.arithmetic_expression.value;
        //     operand1 = create_operand(Integers , operand1_val);
        // }else{
        //     strcpy(operand1_val->variable, $1.arithmetic_expression.sym);
        //     operand1 = create_operand(Variable , operand1_val);
        // }
        // // operand2 management
        // if ($3.arithmetic_expression.is_litteral){
        //     operand2_val->integer = $3.arithmetic_expression.value;
        //     operand2 = create_operand(Integers , operand2_val);
        // }else{
        //     strcpy(operand2_val->variable, $3.arithmetic_expression.sym);
        //     operand2 = create_operand(Variable , operand2_val);
        // }
        // strcpy(tempnames[indicator], gentemp());
        
        // strcpy(result_val->variable, tempnames[indicator]);
        // result = create_operand(Variable, result_val);
        // // int x = indicator;
        


        // quadruplets_node* quad = create_quadruplet(currentInstruction, quadruplets_operators_names[MOD],
        //                                        operand1, operand2, result);
        
        // indicator++;
        // quads[currentInstruction] = *quad;
        // currentInstruction++;
        // $$.arithmetic_expression.is_litteral = false;
        // strcpy($$.arithmetic_expression.sym, tempnames[indicator-1]);

    }
    | expression POWER expression {
	if ($1.is_string || $3.is_string || $1.is_boolean || $3.is_boolean){yyerror_semantic("invalid type for this opperation");}

	else if ($1.arithmetic_expression.is_litteral && $3.arithmetic_expression.is_litteral){
        $$.is_boolean = false;
        union operandValue* operand1_val = create_operand_value();
        union operandValue* operand2_val = create_operand_value();
        union operandValue* result_val = create_operand_value();
        
        operand* operand1;
        operand* operand2;
        operand* result;
        
        // operand1 management
        if ($1.arithmetic_expression.is_litteral){
            operand1_val->integer = $1.arithmetic_expression.value;
            operand1 = create_operand(Integers , operand1_val);
        }else{
            strcpy(operand1_val->variable, $1.arithmetic_expression.sym);
            operand1 = create_operand(Variable , operand1_val);
        }
        // operand2 management
        if ($3.arithmetic_expression.is_litteral){
            operand2_val->integer = $3.arithmetic_expression.value;
            operand2 = create_operand(Integers , operand2_val);
        }else{
            strcpy(operand2_val->variable, $3.arithmetic_expression.sym);
            operand2 = create_operand(Variable , operand2_val);
        }
        strcpy(tempnames[indicator], gentemp());
        
        strcpy(result_val->variable, tempnames[indicator]);
        result = create_operand(Variable, result_val);
        // int x = indicator;
        


        quadruplets_node* quad = create_quadruplet(currentInstruction, quadruplets_operators_names[POWER],
                                               operand1, operand2, result);
        
        indicator++;
        quads[currentInstruction] = *quad;
        currentInstruction++;
        $$.arithmetic_expression.is_litteral = false;
        strcpy($$.arithmetic_expression.sym, tempnames[indicator-1]);}
	else{yyerror_semantic(" >= takes Expressions of same type");}

    }
/* 
	| const */
	| var_exp 
    | TRUE {
        $$.is_boolean = true;
        $$.boolean_expression.truelist = makelist(currentInstruction);
        union operandValue* operand1 = create_operand_value();
        union operandValue* operand2 = create_operand_value();
        union operandValue* result = create_operand_value();
        operand1->label = -1;
        operand2->empty = 1;
        result->empty = 1;
        // int x = -1;
        quadruplets_node* quad = create_quadruplet(currentInstruction, quadruplets_operators_names[BR],
                                               create_operand(Labels , operand1), create_operand(Empty , operand2), result);
        
        quads[currentInstruction] = *quad;
        currentInstruction++;
    }
    | FALSE {
        $$.is_boolean = true;
        $$.boolean_expression.falselist = makelist(currentInstruction);
        union operandValue* operand1 = create_operand_value();
        union operandValue* operand2 = create_operand_value();
        union operandValue* result = create_operand_value();
        operand1->label = -1;
        operand2->empty = 1;
        result->empty = 1;
        quadruplets_node* quad = create_quadruplet(currentInstruction, quadruplets_operators_names[BR],
                                               create_operand(Labels , operand1), create_operand(Empty , operand2), result);
        quads[currentInstruction] = *quad;
        currentInstruction++;
    }
    | INTEGER {
        $$.arithmetic_expression.is_litteral = true;
        $$.arithmetic_expression.value  = _yylval.ival;
    }
    | ID {
        checkif_localsymbolexists(_yylval.ident);
        $$.arithmetic_expression.is_litteral = false;
        if(_yylval.ident == NULL) {
             strcpy($$.arithmetic_expression.sym, save); 
        } else { 
            strcpy($$.arithmetic_expression.sym, _yylval.ident->symName); 
        }
        
    }
	
    |  STRING {$$.is_string = true;}

        ; 



/* const :  INTEGER {
                printf("%d\n", _yylval.ival);
            }
	    |  REALNUMBER
        |  STRING
        ; */

/* variable : var_exp
	| ID OPENPARENTHESIS {checkif_globalsymbolexists(_yylval.ident);} call_param CLOSEPARENTHESIS {yysuccess("EXPRESSION : FUNCTION CALL");}
	| ID OPENPARENTHESIS {checkif_globalsymbolexists(_yylval.ident);} CLOSEPARENTHESIS {yysuccess("EXPRESSION : FUNCTION CALL");}
	; */

 var_exp : 
	 ID {checkif_localsymbolexists(_yylval.ident);} OPENBRACKET expression {if($<expression>4.is_string || $<expression>4.is_boolean){yyerror("array index is not an integer !!!");}
	   else	{yysuccess(1,"EXPRESSION : ARRAY ACCESS");}} CLOSEBRACKET
	; 

/* accessfield: ID { char fieldnameCopy[50]; strcpy(fieldnameCopy, symt->tail->symName); checkif_fieldisvalid(save, fieldnameCopy); deleteEntry(symt, symt->tail->symName); }
		   | ID { deleteEntry(symt, symt->tail->symName); } DOT accessfield
           ;
var: ID {checkif_localsymbolexists(_yylval.ident);}
   | ID {checkif_localsymbolexists(_yylval.ident); strcpy(save, symt->tail->symName);} DOT accessfield
   ; */



M: %empty{
    $$ = currentInstruction;
};

N: %empty {
    $$.nextlist = makelist(currentInstruction);

    // generate ( goto - )
    union operandValue* operand1 = create_operand_value();
    union operandValue* operand2 = create_operand_value();
    union operandValue* result = create_operand_value();
    operand1->label = -1;
    operand2->empty = 1;
    result->empty = 1;
    quadruplets_node* quad = create_quadruplet(currentInstruction, quadruplets_operators_names[BR],
                                               create_operand(Labels , operand1), create_operand(Empty , operand2), result);
    quads[currentInstruction] = *quad;
    currentInstruction++;
}
%%


void yyerror(char *s){
    fprintf(stdout, "File '%s', line %d, character %d : syntax error: " RED " %s " RESET "\n", currentFileName, yylineno, currentColumn, s);
    //fprintf(stdout, "%d: " RED " %s " RESET " \n", yylineno, s);
}
void yyerror_semantic(char *s){
    fprintf(stdout, "File '%s', line %d, character %d : semantic error: " RED " %s " RESET "\n", currentFileName, yylineno, currentColumn, s);
    //fprintf(stdout, "%d: " RED " %s " RESET " \n", yylineno, s);
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


void print_tempnames(){
    int i = 0;
    printf("Temporary names with %d entries: \n", indicator);
    while(i < indicator){
        printf("(%d, %s)\n", i, tempnames[i]);
        i++;
    }
}

