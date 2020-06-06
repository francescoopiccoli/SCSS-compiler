%{
/** @file calc.y
 *  @brief Grammar rules for the scss to css compiler/preprocessor.
 *
 *  This contains the Grammar rules for the preprocessor 
 *  together with some rudimentary error handling and
 *  the main function which either prompts for input or
 *  parses a input file to the command line if given as 
 *  argument. 
 *
 *  @author Raffaele Tranquillini  <rtranquillini@unibz.it>
 *  @author Francesco Piccoli <fpiccoli@unibz.it> 
 *
 *
 *  @bug No known bugs?
 */


//BUGS
// - prod di relationship
// - numeri con - passati come identifier invece che come espressioni -> precedenza 

#define YYERROR_VERBOSE 1

#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
//#include "header/scssFunctions.h"
//#include "header/symtable.h"
//#include "header/error.h"

int yylex();
int yyerror (char const *message);

%}

// here we define all return values that lex can return

%union {
       char* string;
       double number;
       //symtable sym;
       // typedef scalar ...
       }



// here we define the tokens with its respective precedences

%token<string>    ID
%token<number>    NUM
%token<string>    UNIT
%token<string>    SCALAR
%token<string>    ATOM
%token            T_DOLLAR
%token            T_SEMICOLON
%token            T_COLON
%token            T_DOT
%token            T_COMMA
%token            T_HASH
%token            T_PL
%token            T_PR
%token            T_BL
%token            T_BR
%token            T_PLUS
%token            T_MINUS
%token            T_STAR
%token            T_DIV
%token            T_GT
/* %token            CSS_DATA_TYPE  
%token            HTML_DATA_TYPE 
%token            FNNAME */



%left T_MINUS T_PLUS
%left T_STAR T_DIV

%start S

// here we define the grammar

%%

// line and statement rules



S: ST S {printf("Starting point reached\n");}
  | EPS {printf("Starting point reached\n");}
  ;

EPS:
  ;

ST: VARDECL {printf("This is a variable declaration statement\n"); }
  | CSSRULE {printf("This is a css rule statement\n");}
  ;

VARDECL: VAR T_COLON EXPR T_SEMICOLON {printf("This is a variable declaration\n");}
  ;

VAR: T_DOLLAR ID {printf("This is a variable name\n");}
  ;

EXPR: VAR {printf("This is a var expression\n");}
  | SCALAR {printf("This is a scalar expression\n");}
  | NUM {printf("This is num expression\n");}
  | ATOM {printf("This is atom expression\n");}
  | FNCALL {printf("This is fncall expression\n");}
  | T_PL EXPR T_PR {printf("This an expression within parenthisi\n");}
  | EXPR T_PLUS EXPR {printf("This a sum between expressions\n");}
  | EXPR T_MINUS EXPR {printf("This a subtraction between expressions\n");}
  | EXPR T_STAR EXPR {printf("This a multiplication between expressions\n");}
  | EXPR T_DIV EXPR {printf("This a division between expressions\n");}
  ;

FNCALL: ID T_PL P T_PR {printf("This is a function call\n");}
  /*| FNNAME T_PL P T_PR*/
  ;

P: EXPR PARAMS 
  | EPS
  ;

PARAMS: T_COMMA EXPR PARAMS {printf("This is a paramater\n");}
  | EPS
  ;

CSSRULE: SELECTORS T_BL DECLS T_BR {printf("This is a css rule\n");}
  ;

SELECTORS: SELECTOR PSEUDOCLASS RELATIONSHIP
  ;

SELECTOR: /* HTML_DATA_TYPE  */
  | ID {printf("This is selector\n");}
  | T_HASH ID {printf("This is selector\n");}
  | T_DOT ID {printf("This is selector\n");}
  /*
  | T_HASH HTML_DATA_TYPE {printf("This is selector\n");}
  */
   /*
  | T_DOT HTML_DATA_TYPE {printf("This is selector\n");}
   */
  ;

PSEUDOCLASS: T_COLON ID
  | EPS
  ;

  RELATIONSHIP: T_COMMA SELECTORS {printf("This is a comma relationship\n");}
  | T_GT SELECTORS {printf("This is a hierarchy relationship\n");}
  | SELECTORS {printf("This is another hierarchy relationship\n");}
  | EPS
  ;
  
DECLS: DECL DECLS
  | EPS
  ;
  
DECL: ID T_COLON EXPR T_SEMICOLON {printf("This is a declaration\n");}
  /* | CSS_DATA_TYPE T_COLON EXPR T_SEMICOLON */
  | CSSRULE {printf("This is a nested css rule\n");}
  | VARDECL {printf("This is a local variable declaration\n");}

%%

#include "lex.yy.c"

int main(int argc, char *argv[]) 
{      

 // interactive mode or file mode
      if(argc < 2) 
      {
            printf("To exit at any time, press Ctrl+D (EOF).\n");
            return yyparse();
      } 
      else 
      {
            FILE *fp = fopen(argv[1],"r");
            if(!fp) 
            {
                  printf("Unable to open file for reading\n");
                  exit(0);
            }
            yyin = fp;
            int flag = yyparse();
            fclose(yyin);
            
            return flag;
      }
}

int yyerror (char const *message)
{
  return fprintf (stderr, "%s\n", message);
  fputs (message, stderr);
  fputc ('\n', stderr);
  return 0;
}