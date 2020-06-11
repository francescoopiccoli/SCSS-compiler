%option noyywrap
%option yylineno

%{
#include <stdlib.h>
#include <string.h>

%}

DIGIT       [0-9]
NUM         {DIGIT}+(\.{DIGIT}+)?
LETTER      [a-zA-Z]
ID          ({LETTER}|_)({LETTER}|{DIGIT}|\-|_)*
COMMENT     \/\/.*\n
UNIT        (px|em|\%)
PSEUDO      :(active|checked|disabled|empty|enabled|first-child|first-of-type|focus|hover|in-range|invalid|last-child|last-of-type|link|only-of-type|only-child|optional|out-of-range|read-only|read-write|required|root|target|valid|visited)
STRING      \"(\\.|[^"\\])*\"

%%

\@SYMTAB    {print_variables();} // DEBUG
\/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+\/ {ECHO; printf("\n");} // report identically in output; regex by https://blog.ostermiller.org/finding-comments-in-source-code-using-regular-expressions/
[   \v\t\n\r\f] {} // ignore whitespace
{COMMENT}   {} // ignore comments of type "//"

"+"         {return T_PLUS;}
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

{UNIT}      {yylval.string = strdup(yytext);  return UNIT;}

{NUM}       {yylval.number = atof(yytext); return NUM;}


\${ID}      {
            char* name = strdup(yytext); 
            SYMREC* s = get_variable(name);
            if(s == 0) {
                  s = create_variable_table(name);
            }
            yylval.sym = s;
            return VAR;}

{PSEUDO}    {yylval.string = strdup(yytext); return PSEUDO;}

{STRING}    {yylval.string = strdup(yytext); return STRING;}

{ID}        {yylval.string = strdup(yytext); return ID;}


.           { fprintf(stderr, "!!! ERROR Unexpected character: %u !!!\n", yytext[0]); return yytext[0]; } //return error if unrecognized token

%%