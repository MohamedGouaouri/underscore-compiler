
%{
    #include "parser.tab.h"
    #include "symtable.h"

    extern int currentColumn;
    extern SymTable* symt;
    
    extern _YYSTYPE _yylval;
    extern char save[50];
    
    
%}

/*Used to get the current line number*/
%option yylineno 
%option noyywrap 
%option outfile = "scanner.lex.c"
/*Used for multiline comments*/
%x c_comment     

UNDERSCORE "_"

/*Reserved keywords*/
LOOP loop
READ READ
WRITE WRITE

IF \?
ELSE :

BREAK break
CONTINUE continue

/*true/false*/
TRUE true
FALSE false


/*Identifiers*/
ID [a-zA-Z][a-zA-Z0-9_]*

ANYTHING .*
DOT \.
LINEBREAK "\n"|"\r"
SEMICOLON ;
COMMA \,

OPENPARENTHESIS \(
CLOSEPARENTHESIS \)
OPENHOOK \{
CLOSEHOOK \}
OPENBRACKET \[
CLOSEBRACKET \]


/*Logical and arithmetic operators*/
EQUAL =
NONEQUAL !=
AND &&
OR \|\|
NON !
INFERIOR \<
SUPERIOR \>
INFERIOREQUAL \<\=
SUPERIOREQUAL \>\=
ADD \+
SUB -
MULT \*
DIV \/
MOD \%
POWER \^

/*Elementary instructions*/
ASSIGNMENT \<\-
RETURN -\>

/*Constant strings and numbers*/
DIGIT [0-9]
NUMBER ([1-9]{DIGIT}*|"0")
INTEGER -?{NUMBER}
REALNUMBER -?{NUMBER}"\."{DIGIT}+
STRING (\"[^\n\"\"]*\")|(\'{ANYTHING}\') 

/*Declarations*/
FUNCTIONDECLARE \(\){UNDERSCORE}
NUMBERDECLARE \${UNDERSCORE}
STRINGDECLARE ((\"\")|(\'\')){UNDERSCORE}
CONSTDECLARE \~{UNDERSCORE}
BOOLEENDECLARE \?{UNDERSCORE}

STRUCTTYPEDECLARE \{\}{UNDERSCORE}
STRUCTDECLARE {UNDERSCORE}{ID}
POINTERDECLARE ((\@)+)(({STRUCTDECLARE})|({NUMBERDECLARE}|{STRINGDECLARE}|{CONSTDECLARE}|{BOOLEENDECLARE}))

NUMBERSYMBOL (\$)
STRINGSYMBOL (\"\")

/*sizeless array*/
TABLEDECLARE ((\@)*)((\$)|((\"\")|(\'\'))|(\~)|(\?)|(\{\}))((\[\])+){UNDERSCORE} 

/*Pointers*/
ADDRESSVALUE &
POINTERVALUE @

/*Comments*/
INLINECOMMENT #[^_]{ANYTHING}


%%

{UNDERSCORE} {
    yysuccess(0,"Stray underscore");
    return UNDERSCORE;
}

{LOOP} {
    yysuccess(0,"LOOP");
    return LOOP;
}

{READ} {
    yysuccess(0,"READ");
    return READ;
}

{WRITE} {
    yysuccess(0,"WRITE");
    return WRITE;
}


{IF} {
    yysuccess(0,"IF condition / Boolean symbol");
    return IF;
}

{ELSE} {
    yysuccess(0,"ELSE condition");
    return ELSE;
}

{BREAK} {
    yysuccess(0,"Loop break");
    return BREAK;
}

{CONTINUE} {
    yysuccess(0,"Loop continue");
    return CONTINUE;
}

{TRUE} {
    yysuccess(0,"TRUE continue");
    return TRUE;
}

{FALSE} {
    yysuccess(0,"FALSE");
    return FALSE;
}


{ID} {
    //printSymTable(symt);
    yysuccess(0, "IDENTIFIER");
    SymTableNode* node = lookup(symt, yytext); 
    if ( node == NULL ) { 
        node = insertNewEntry(symt, ID, yytext);
        _yylval.ident = node; 
    } else {
        _yylval.ident = NULL;
        strcpy(save, yytext);
    }
    //_yylval.string = yytext;
    //yyerror(yytext);
    //printSymTable(symt);
    return ID;
}


{DOT} {
    yysuccess(0,"DOT");
    return DOT;
}

{COMMA} {
    yysuccess(0,"COMMA");
    return COMMA;
}

{SEMICOLON} {
    yysuccess(0,"SEMICOLON");
    return SEMICOLON;
}




{OPENPARENTHESIS} {
    yysuccess(0,"OPENPARENTHESIS");
    return OPENPARENTHESIS;
}

{CLOSEPARENTHESIS} {
    yysuccess(0,"CLOSEPARENTHESIS");
    return CLOSEPARENTHESIS;
}

{OPENHOOK} {
    yysuccess(0,"OPENHOOK");
    return OPENHOOK;
}

{CLOSEHOOK} {
    yysuccess(0,"CLOSEHOOK");
    return CLOSEHOOK;
}

{OPENBRACKET} {
    yysuccess(0,"OPENBRACKET");
    return OPENBRACKET;
}

{CLOSEBRACKET} {
    yysuccess(0,"CLOSEBRACKET");
    return CLOSEBRACKET;
}


			
{EQUAL} {
    yysuccess(0,"EQU operator");
    return EQUAL;
}

{NONEQUAL} {
    yysuccess(0,"NONEQU operator");
    return NONEQUAL;
}

{AND} {
    yysuccess(0,"AND operator");
    return AND;
}

{OR} {
    yysuccess(0,"OR operator");
    return OR;
}

{NON} {
    yysuccess(0,"NON operator");
    return NON;
}

{INFERIOR} {
    yysuccess(0,"INFERIOR sign");
    return INFERIOR;
}

{SUPERIOR} {
    yysuccess(0,"SUPERIOR sign");
    return SUPERIOR;
}

{INFERIOREQUAL} {
    yysuccess(0,"INFERIOREQUAL sign");
    return INFERIOREQUAL;
}

{SUPERIOREQUAL} {
    yysuccess(0,"SUPERIOREQUAL sign");
    return SUPERIOREQUAL;
}

{ADD} {
    yysuccess(0,"ADDITION operator");
    return ADD;
}

{SUB} {
    yysuccess(0,"SUBTRACTION operator");
    return SUB;

}

{MULT} {
    yysuccess(0,"MULTIPLICATION operator");
    return MULT;
}

{DIV} {
    yysuccess(0,"DIVISION operator");
    return DIV;
}

{MOD} {
    yysuccess(0,"MODULO operator");
    return MOD;
}

{POWER} {
    yysuccess(0,"POWER operator");
    return POWER;
}


{ASSIGNMENT} {
    yysuccess(0,"ASSIGNMENT");
    return ASSIGNMENT;
}

{RETURN} {
    yysuccess(0,"RETURN");
    return RETURN;
}

{FUNCTIONDECLARE} {
    yysuccess(0, "FUNCTION declaration");

    strcpy(_yylval.type, "function");
    return FUNCTIONDECLARE;
} 

{NUMBERDECLARE} {
    yysuccess(0, "NUMBER declaration");
    
    strcpy(_yylval.type, "number");
    return NUMBERDECLARE;
}

{STRINGDECLARE} {
    yysuccess(0, "STRING declaration");

    strcpy(_yylval.type, "string");
    return STRINGDECLARE;
}

{CONSTDECLARE} {
    yysuccess(0, "CONSTANT declaration");
    return CONSTDECLARE;
}

{BOOLEENDECLARE} {
    yysuccess(0, "BOOLEAN declaration");

    strcpy(_yylval.type, "boolean");
    return BOOLEENDECLARE;
}

{STRUCTTYPEDECLARE} {
    yysuccess(0, "STRUCTTYPE declaration");

    strcpy(_yylval.type, "structtype");
    return STRUCTTYPEDECLARE;
}

{STRUCTDECLARE} {
    yysuccess(0, "STRUCT declaration");
    // char* passtoyylval;
    // strcpy(passtoyylval, yytext);
    // _yylval.type = passtoyylval;
    //_yylval.type = yytext;
    strcpy(_yylval.type, yytext);
    return STRUCTDECLARE;
}

{POINTERDECLARE} {
    yysuccess(0,"POINTER declaration");
    return POINTERDECLARE;
}

{NUMBERSYMBOL} {
    yysuccess(0, "Number symbol");
    return NUMBERSYMBOL;
}

{STRINGSYMBOL} {
    yysuccess(0, "String symbol");
    return STRINGSYMBOL;
}

{TABLEDECLARE} {
    yysuccess(0, "TABLE declaration");

    strcpy(_yylval.type, "array");
    return TABLEDECLARE;
}


{ADDRESSVALUE} {
    yysuccess(0,"ADDRESS value");
    return ADDRESSVALUE;
}

{POINTERVALUE} {
    yysuccess(0,"POINTER value");
    return POINTERVALUE;
}


{INTEGER} {
    yysuccess(0, "constant INTEGER");
    _yylval.ival = atoi(yytext);
    return INTEGER;
}

{REALNUMBER} {
    yysuccess(0, "constant REALNUMBER");
    _yylval.rval = strtod(yytext, NULL);
    return REALNUMBER;
}


{STRING} {
    yysuccess(0, "constant STRING");
    _yylval.string = yytext;
    return STRING;
} 



{INLINECOMMENT} {;}

{LINEBREAK} {
    currentColumn = 1;
}


#_ { BEGIN(c_comment); yymore(); }
<c_comment>[^_]* { yymore(); }
<c_comment>"_"+[^_#]* { yymore(); }
<c_comment>"_#" {BEGIN(INITIAL);}


[ \t]+ {
    currentColumn+=yyleng;
}

<<EOF>> yyterminate();

. {
    
    // yyerror("Unrecognized character");
    showLexicalError();
    yyterminate();
}

%%