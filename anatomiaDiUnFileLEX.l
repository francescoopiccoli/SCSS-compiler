
//lex files have .l extension
//to run lex files: flex -l nameOfTheFile

/*this part regards some compatibility thing in order to make our code run on every machine*/
%option noyywrap 

/*inside this %{}‰ we have the very beginning of the declaration part where 
we define variables we will use and libraries*/
%{
#include <stdio.h>  
int TokenCont=0;
%}


/*this is still the declaration part (till %%) here we have definitions/regular names */
digit  [0-9]  
letter [a-zA-Z]
digits {digit}+
stringconst \"({letter}|{digit})+\"
%%

/here the rule part, on the left hand side we have a regular expression (if, {letter}+ ...), on the right, 
//the associated action to execute as soon as the regex recognises the input
//the actions in this case are just printf, since we are not working with a parser (YACC)
//all the parameters (yytext, yyleng) are transmitted by the action (to the parser (?))
// yytext = lexeme matched      yyleng = length of the lexeme
//. means: if none of the regex is matched, it means, an error occured, input not recognised
//"if" declared before {letter}+, since it is a keyword, the order of the rules matters,
/se "if" fosse dopo {letter}+, l'input "if" verrebbe riconosciuto come {letter}+

[ \t\n] {} //whenever the lexical analyser meets a white/blank space tab new line, it ignores them

if        {printf("%d IF \"%s\" Lenght = %lu\n",++TokenCont,yytext,yyleng);}

{letter}+ {printf("%d Word \"%s\" Lenght = %lu\n",++TokenCont,yytext,yyleng);}

{digits} {printf("%d Number \"%d\" Lenght = %lu\n",++TokenCont,atoi(yytext),yyleng);}

{stringconst} {printf("%d Str-Const \"%s\" Lenght = %lu\n",++TokenCont,yytext,yyleng);}

.              {printf("LEXICAL ERROR  \"%s\"\n",yytext);}
%%

main()
{

//calling this funciton will generate lex.yy.c file, this file contains all the automata and the control logic
//needed for the next phase (parsing), once this lex.yy.c file is generated, compile it with gcc, a.out will 
//be generated, if we run this a.out file, now you can input a lexeme (a word or whatever), as soon as you click
//enter the terminal will output the results of the actions associated to the regex which corresponds to the input
//for example "ciao" -> {letter}+, so 1 Word ... will be outputted, (1 = TokenCont)

yylex(); 

}
