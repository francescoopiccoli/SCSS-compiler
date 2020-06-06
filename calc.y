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
#include "header/scssFunctions.h"
#include "header/symtable.h"
#include "header/error.h"

int yylex();
int yyerror (char const *message);

%}

// here we define all return values that lex can return

%union {
       char* string;
       double number;
       symrec *sym;
       enum var_type varType;
       // typedef scalar ...
       }



// here we define the tokens with its respective precedences

%token<string>    ID
%token<number>    NUM
%token<string>    UNIT
%token<sym>       VAR
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

%type <varType>   EXPR

%left T_MINUS T_PLUS
%left T_STAR T_DIV



%start S

// here we define the grammar

%%

// line and statement rules



S: ST S
  | EPS
  ;

EPS:
  ;

ST: VARDECL
  | CSSRULE
  ;

VARDECL: VAR T_COLON EXPR T_SEMICOLON {
  insertSymbol($1,$3);
}
  ;

EXPR: VAR {$$ = VAR_SCALAR; /* todo : det. type */}
  | SCALAR {$$ = VAR_SCALAR ; }
  | ID {$$ = VAR_ATOM; }
  | FNCALL {$$ = VAR_FUNCTION;}
  | T_PL EXPR T_PR {$$ = $2;}
  | EXPR T_PLUS EXPR {$$ = VAR_SCALAR; /* todo : type check */}
  | EXPR T_MINUS EXPR {$$ = VAR_SCALAR; /* todo : type check */}
  | EXPR T_STAR EXPR {$$ = VAR_SCALAR; /* todo : type check */}
  | EXPR T_DIV EXPR {$$ = VAR_SCALAR; /* todo : type check */}
  ;

SCALAR: NUM UNIT
  | NUM
  ;

FNCALL: ID T_PL P T_PR
  /*| FNNAME T_PL P T_PR*/
  ;

P: EXPR PARAMS 
  | EPS
  ;

PARAMS: T_COMMA EXPR PARAMS
  | EPS
  ;

CSSRULE: SELECTORS T_BL DECLS T_BR
  ;

SELECTORS: SELECTOR PSEUDOCLASS RELATIONSHIP
  ;

SELECTOR: /* HTML_DATA_TYPE  */
  | ID
  | T_HASH ID
  | T_DOT ID
  /*
  | T_HASH HTML_DATA_TYPE
  */
   /*
  | T_DOT HTML_DATA_TYPE
   */
  ;

PSEUDOCLASS: T_COLON ID
  | EPS
  ;

  RELATIONSHIP: T_COMMA SELECTORS
  | T_GT SELECTORS
  | SELECTORS
  | EPS
  ;
  
DECLS: DECL DECLS
  | EPS
  ;
  
DECL: ID T_COLON EXPR T_SEMICOLON
  /* | CSS_DATA_TYPE T_COLON EXPR T_SEMICOLON */
  | CSSRULE
  | VARDECL

%%

symrec *sym_table = 0;

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