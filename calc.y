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

typedef struct {
    char *string;
    double number;
    enum var_type type;
} var_contents;

%}

// here we define all return values that lex can return

%union {
        char* string;
        double number;
        symrec *sym;
        enum var_type varType;
        var_contents expression;
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

%type <expression>   EXPR
%type <expression>   SCALAR
%type <string>       FNCALL

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
  var_contents v = $3;
  
  symrec* symbol = insertSymbol($1,v.type);
  symbol->value.number = v.number;
  symbol->value.string = v.string;

}
  ;

EXPR: VAR 
  {
    if(getSymbol($1->name) > 0) {
      var_contents v;
      v.type = getSymbol($1->name)->type;
      v.string = getSymbol($1->name)->value.string;
      v.number = getSymbol($1->name)->value.number;
      $$ = v;
    } else {
      // crash?
      printf("Variable %s not declared!",$1->name);
    }
  }
  | SCALAR { $$ = $1; }
  | ID {
    var_contents v;
    v.type = VAR_ATOM;
    v.string = $1;
    $$ = v; 
    }
  | FNCALL {
    var_contents v;
    v.type = VAR_FUNCTION;
    v.string = $1;
    $$ = v; 
    }
  | T_PL EXPR T_PR {$$ = $2;}
  /*| EXPR T_PLUS EXPR {$$ = VAR_SCALAR; /* todo : type check /}
  | EXPR T_MINUS EXPR {$$ = VAR_SCALAR; /* todo : type check /}
  | EXPR T_STAR EXPR {$$ = VAR_SCALAR; /* todo : type check /}
  | EXPR T_DIV EXPR {$$ = VAR_SCALAR; /* todo : type check /}*/
  ;

SCALAR: NUM UNIT {
    var_contents v;
    v.type = VAR_SCALAR;
    v.number = $1;
    v.string = $2;
    $$ = v; 
    }
  | NUM {
    var_contents v;
    v.type = VAR_SCALAR;
    v.number = $1;
    $$ = v; 
    }
  ;

FNCALL: ID T_PL P T_PR { $$ = $1; }
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