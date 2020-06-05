%option noyywrap

%{
#include <stdlib.h>
#include <string.h>
//#include "header/scssFunctions.h"
//#include "header/symtable.h"

//variabili usate spesso che potrebbero tornare utili
int badtoken_cnt = 0;
int token_cnt = 0;
int col_cnt = 0;
int lineno = 0;

%}

DIGIT       [0-9]
NUM         {DIGIT}+(\.{DIGIT}+)?
LETTER      [a-zA-Z]
ID          ({LETTER}|\-|_)({LETTER}|{DIGIT}|\-_)* 
COMMENT     \/\/.*\n
UNIT        %|px
ATOM        black|red|white|blue|green
PSEUDOCLASS :active|:checked|:disabled|:empty|:enabled|:first-child|:first-of-type|:focus|:hover|:in-range|:invalid|:last-child|:last-of-type|:link|:only-of-type|:only-child|:optional|:out-of-range|:read-only|:read-write|:required|:root|:target|:valid|:visited

%%

[ \t\n]       {} // ignore whitespace
{COMMENT}     {} // ignore comments of type "//"
"/\*.*\*/"    {}  ECHO; // report identically in new file

"+"         {return T_PLUS;}   // operators 
"-"         {return T_MINUS;}
"*"         {return T_STAR;}
"/"         {return T_DIV;}     
"("         {return T_PL;}
")"         {return T_PR;}     
"{"         {return T_BL;}
"}"         {return T_BR;}
":"         {return T_COLON;}
";"         {return T_SEMICOLON;} 
","         {return T_COMMA;}
">"         {return T_GT;}
"."         {return T_DOT;}
"#"         {return T_HASH;}
"$"         {return T_DOLLAR;}

{NUM}       {printf("num"); /*yylval.value = atof(yytext); return NUM; */}


{ATOM}      {printf("atom"); /*yylval.lexeme = strdup(yytext); return ATOM; */}

{ID}        {printf("id"); /*yylval.lexeme = strdup(yytext); return ID; */}

{PSEUDOCLASS} {printf("PSEUDOCLASS"); /*yylval.lexeme = strdup(yytext); return PSEUDO; */}

{UNIT}      {printf("unit"); /*yylval.lexeme = strdup(yytext); return UNIT; */}

.           { printf("Unexpected character: %c\n", yytext[0]); return yytext[0]; } //return error if all else fails

%%
