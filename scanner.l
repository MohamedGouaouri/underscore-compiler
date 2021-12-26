
%{
    #include "parser.tab.h"
    #include "symtable.h"

    extern int currentColumn;
    extern SymTable* symt;
    
    extern _YYSTYPE _yylval;
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
ENTRY entry

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
TABLEDECLARE ((\@)*)((\$)|((\"\")|(\'\'))|(\~)|(\?)|(\{\}))((\[\])+){UNDERSCORE}

/*Pointers*/
ADDRESSVALUE &
POINTERVALUE @

/*Comments*/
INLINECOMMENT #[^_]{ANYTHING}


%%



{LOOP} {
    yysuccess("LOOP");
    return LOOP;
}

{READ} {
    yysuccess("READ");
    return READ;
}

{WRITE} {
    yysuccess("WRITE");
    return WRITE;
}

{ENTRY} {
    yysuccess("the main entry");
    return ENTRY;
}

{IF} {
    yysuccess("IF condition");
    return IF;
}

{ELSE} {
    yysuccess("ELSE condition");
    return ELSE;
}

{BREAK} {
    yysuccess("Loop break");
    return BREAK;
}

{CONTINUE} {
    yysuccess("Loop continue");
    return CONTINUE;
}

{TRUE} {
    yysuccess("TRUE continue");
    return TRUE;
}

{FALSE} {
    yysuccess("FALSE");
    return FALSE;
}


{ID} {
    yysuccess("IDENTIFIER");
    SymTableNode* node = insertNewEntry(symt, ID, yytext);
    _yylval.ident = node;
    return ID;
}


{DOT} {
    yysuccess("DOT");
    return DOT;
}

{COMMA} {
    yysuccess("COMMA");
    return COMMA;
}

{SEMICOLON} {
    yysuccess("SEMICOLON");
    return SEMICOLON;
}




{OPENPARENTHESIS} {
    yysuccess("OPENPARENTHESIS");
    return OPENPARENTHESIS;
}

{CLOSEPARENTHESIS} {
    yysuccess("CLOSEPARENTHESIS");
    return CLOSEPARENTHESIS;
}

{OPENHOOK} {
    yysuccess("OPENHOOK");
    return OPENHOOK;
}

{CLOSEHOOK} {
    yysuccess("CLOSEHOOK");
    return CLOSEHOOK;
}

{OPENBRACKET} {
    yysuccess("OPENBRACKET");
    return OPENBRACKET;
}

{CLOSEBRACKET} {
    yysuccess("CLOSEBRACKET");
    return CLOSEBRACKET;
}


			
{EQUAL} {
    yysuccess("EQU operator");
    return EQUAL;
}

{NONEQUAL} {
    yysuccess("NONEQU operator");
    return NONEQUAL;
}

{AND} {
    yysuccess("AND operator");
    return AND;
}

{OR} {
    yysuccess("OR operator");
    return OR;
}

{NON} {
    yysuccess("NON operator");
    return NON;
}

{INFERIOR} {
    yysuccess("INFERIOR sign");
    return INFERIOR;
}

{SUPERIOR} {
    yysuccess("SUPERIOR sign");
    return SUPERIOR;
}

{INFERIOREQUAL} {
    yysuccess("INFERIOREQUAL sign");
    return INFERIOREQUAL;
}

{SUPERIOREQUAL} {
    yysuccess("SUPERIOREQUAL sign");
    return SUPERIOREQUAL;
}

{ADD} {
    yysuccess("ADDITION operator");
    return ADD;
}

{SUB} {
    yysuccess("SUBTRACTION operator");
    return SUB;

}

{MULT} {
    yysuccess("MULTIPLICATION operator");
    return MULT;
}

{DIV} {
    yysuccess("DIVISION operator");
    return DIV;
}

{MOD} {
    yysuccess("MODULO operator");
    return MOD;
}

{POWER} {
    yysuccess("POWER operator");
    return POWER;
}


{ASSIGNMENT} {
    yysuccess("ASSIGNMENT");
    return ASSIGNMENT;
}

{RETURN} {
    yysuccess("RETURN");
    return RETURN;
}



{INTEGER} {
    yysuccess("constant INTEGER");
    // SymTableNode* node = insertNewEntry(symt, _INTEGER);
    // // insert integer value
    // set_attr(node, _VALUE_ATTR, yytext);
    _yylval.ival = atoi(yytext);
    return INTEGER;
}

{REALNUMBER} {
    yysuccess("constant REALNUMBER");
    // SymTableNode* node = insertNewEntry(symt, _REALNUMBER);
    // // insert rea lnumber value
    // set_attr(node, _VALUE_ATTR, yytext);
    _yylval.rval = strtod(yytext, NULL);
    return REALNUMBER;
}


{STRING} {
    yysuccess("constant STRING");

    // SymTableNode* node = insertNewEntry(symt, _STRING);
    // // insert string value & length
    // set_attr(node, _VALUE_ATTR, yytext);

    _yylval.ival = yytext;
    return STRING;
} 


{FUNCTIONDECLARE} {
    yysuccess("FUNCTION declaration");
    return FUNCTIONDECLARE;
} 

{NUMBERDECLARE} {
    yysuccess("NUMBER declaration");
    return NUMBERDECLARE;
}

{STRINGDECLARE} {
    yysuccess("STRING declaration");
    return STRINGDECLARE;
}

{CONSTDECLARE} {
    yysuccess("CONSTANT declaration");
    return CONSTDECLARE;
}

{BOOLEENDECLARE} {
    yysuccess("BOOLEAN declaration");
    return BOOLEENDECLARE;
}

{STRUCTTYPEDECLARE} {
    yysuccess("STRUCTTYPE declaration");
    return STRUCTTYPEDECLARE;
}

{STRUCTDECLARE} {
    yysuccess("STRUCT declaration");
    return STRUCTDECLARE;
}

{POINTERDECLARE} {
    yysuccess("POINTER declaration");
    return POINTERDECLARE;
}

{TABLEDECLARE} {
    yysuccess("TABLE declaration");
    return TABLEDECLARE;
}

{ADDRESSVALUE} {
    yysuccess("ADDRESS value");
    return ADDRESSVALUE;
}

{POINTERVALUE} {
    yysuccess("POITER value");
    return POINTERVALUE;
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
    yyerror("Unrecognized character");
    showLexicalError();
    yyterminate();
}

%%