
%{
    #include "scanner.h"
    
    int currentColumn = 1;
    void yyerror(const char *s, int line, int col);
%}

%option yylineno
%option noyywrap
%option outfile = "scanner.c"
%x c_comment

UNDERSCORE "_"

FOR loop
READ READ
WRITE WRITE
IF \?
ELSE :
ENTRY entry
MAIN (\(\)){UNDERSCORE}" entry"(\(\))

ANYTHING .*
DOT \.
LINEBREAK "\n"|"\r"
SEMICOLON ;
COMMA \,

FUNCTIONDECLARE \(\){UNDERSCORE}
NUMBERDECLARE \${UNDERSCORE}
STRINGDECLARE ((\"\")|(\'\')){UNDERSCORE}
CONSTDECLARE \~{UNDERSCORE}
BOOLEENDECLARE \?{UNDERSCORE}

STRUCTTYPEDECLARE \{\}{UNDERSCORE}
STRUCTDECLARE {UNDERSCORE}{ID}
POINTERDECLARE ((\*)+)(({STRUCTDECLARE})|({NUMBERDECLARE}|{STRINGDECLARE}|{CONSTDECLARE}|{BOOLEENDECLARE}))
TABLEDECLARE ((\*)*)((\$)|((\"\")|(\'\'))|(\~)|(\?)|(\{\}))((\[\])+){UNDERSCORE}

ADDRESSVALUE &
POINTERVALUE @

ASSIGNMENT \<\-
RETURN -\>

DIGIT [0-9]
NUMBER [1-9]{DIGIT}*
INTEGER -?{NUMBER}
REALNUMBER -?["0"{NUMBER}]"\."{DIGIT}+

STRING (\"{ANYTHING}\")|(\'{ANYTHING}\') 
OPENPARENTHESIS \(
CLOSEPARENTHESIS \)
OPENHOOK \{
CLOSEHOOK \}
OPENBRACKET \[
CLOSEBRACKET \]

ID [a-zA-Z][a-zA-Z0-9_]*

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


INLINECOMMENT #[^_]{ANYTHING}


%%




{FOR} {
    printf("Found a loop '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{READ} {
    printf("Found a read '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{WRITE} {
    printf("Found a write '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}


{IF} {
    printf("Found an if Condition '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{ELSE} {
    printf("Found an else Condition '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}


{ENTRY} {
    printf("Found the entry '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}


{DOT} {
    printf("Found a dot '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{COMMA} {
    printf("Found a comma '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{SEMICOLON} {
    printf("Found a semicolon '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}


{FUNCTIONDECLARE} {
    printf("Found a function declaration '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
} 

{NUMBERDECLARE} {
    printf("Found a number declaration '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{STRINGDECLARE} {
    printf("Found a string declaration '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{CONSTDECLARE} {

    printf("Found a constant declaration '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{BOOLEENDECLARE} {
    printf("Found a booleen declaration '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{STRUCTTYPEDECLARE} {
    printf("Found a struct type declaration '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{STRUCTDECLARE} {
    printf("Found a struct declaration '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{POINTERDECLARE} {
    printf("Found a pointer declaration '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{TABLEDECLARE} {
    printf("Found a table declaration '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{ADDRESSVALUE} {
    printf("Found an address value '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{POINTERVALUE} {
    printf("Found a pointer value '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{ASSIGNMENT} {
    printf("Found an assignment  '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{RETURN} {
    printf("Found a return '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{INTEGER} {
    printf("Found a constant integer '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;

}

{REALNUMBER} {
    printf("Found a constant real number '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;

}


{STRING} {
    printf("Found a constant string '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
} 

{OPENPARENTHESIS} {
    printf("Found an opening parenthesis '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{CLOSEPARENTHESIS} {
    printf("Found a closing parenthesis '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{OPENHOOK} {
    printf("Found an opening hook '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{CLOSEHOOK} {
    printf("Found a closing hook '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{OPENBRACKET} {
    printf("Found an opening bracket '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{CLOSEBRACKET} {
    printf("Found a closing bracket '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{ID} {
    printf("Found an identifier '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;

}

			
{EQUAL} {
    printf("Found an equality operator'%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{NONEQUAL} {
    printf("Found a non equality operator'%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{AND} {
    printf("Found a and operator'%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{OR} {
    printf("Found an or operator '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{NON} {
    printf("Found a non operator '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{INFERIOR} {
    printf("Found an inferiority operator '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{SUPERIOR} {
    printf("Found a superiority operator '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{INFERIOREQUAL} {
    printf("Found an inferiority or equality operator '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{SUPERIOREQUAL} {
    printf("Found a superiority or equality operator '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{ADD} {
    printf("Found an addition operator '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{SUB} {
    printf("Found a substraction operator '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{MULT} {
    printf("Found a multiplication operator '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{DIV} {
    printf("Found a division operator '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{MOD} {
    printf("Found a modulo operator '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}

{POWER} {
    printf("Found a power operator '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;
}


{INLINECOMMENT} {
    yyless(yyleng-2);
    printf("Found an inline comment '%s' at Ln %d Col %d \n", yytext, yylineno, currentColumn);
    currentColumn+=yyleng;

}

{LINEBREAK} {
    currentColumn = 1;
}

#_ { BEGIN(c_comment); yymore(); }
<c_comment>[^_]* { yymore(); }
<c_comment>"_"+[^_#]* { yymore(); }
<c_comment>"_#" { printf("Found a multiline comment '%s'\n", yytext); currentColumn+=yyleng; BEGIN(INITIAL);}



[ \t]+ {
    currentColumn+=yyleng;
}


. {
    yyerror("Unrecognized character", yylineno, currentColumn);
    currentColumn+=yyleng;
}


%%

int main(int argc, char **argv) {

    
    extern FILE *yyin, *yyout;
  
    yyin = fopen(argv[1], "r");
  
    yyout = fopen("Output.txt", "w");
  
    yylex();

    printf("Dernière position %d %d \n", yylineno, currentColumn);

    return 0;


}

void yyerror(const char *s, int line, int col) {
    printf("\033[0;31m"); 
    printf("%s at Ln %d Col %d \n", s, line, col);
    printf("\033[0m"); 
}

