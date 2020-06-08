%option noyywrap
%option yylineno

%{
#include <stdlib.h>
#include <string.h>
//#include "header/scssFunctions.h"
//#include "header/symtable.h"


//BUGS


%}

DIGIT       [0-9]
NUM         {DIGIT}+(\.{DIGIT}+)?
LETTER      [a-zA-Z]
ID          ({LETTER}|_)({LETTER}|{DIGIT}|\-|_)*
COMMENT     \/\/.*\n
UNIT        (px|em|\%)
ATOM        black|red|white|blue|green
PSEUDOCLASS :active|:checked|:disabled|:empty|:enabled|:first-child|:first-of-type|:focus|:hover|:in-range|:invalid|:last-child|:last-of-type|:link|:only-of-type|:only-child|:optional|:out-of-range|:read-only|:read-write|:required|:root|:target|:valid|:visited
HTML_DATA_TYPE (li|a|ul|ol|div|span|body|i|h1|h2|h3|h4|h5|h6|b|p|header|footer|td|th|tr|table|section|small)
CSS_DATA_TYPE (color|margin|padding|background-color|left|right|float|clear|bottom|top|position|display|font-size|font-family|height|width|text-align|z-index)
FNNAME (url|rgb|linear-gradient)



%%

\@SYMTAB    {print_variables();} // DEBUG
\/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+\/ ECHO; // report identically in output; regex by https://blog.ostermiller.org/finding-comments-in-source-code-using-regular-expressions/
[ \t\n]     {} // ignore whitespace -> only outside strings?
{COMMENT}   {} // ignore comments of type "//"

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

{UNIT}      {yylval.string = strdup(yytext);  return UNIT;}

{NUM}       {yylval.number = atof(yytext); return NUM;}


\${ID}      {
            char* name = strdup(yytext); 
            symrec* s = get_variable(name);
            if(s == 0) {
                  s = create_variable_table(name);
            }
            yylval.sym = s;
            return VAR;}

{ID}        {yylval.string = strdup(yytext); return ID;}


.           { printf("Unexpected character: %c\n", yytext[0]); return yytext[0]; } //return error if all else fails

%%