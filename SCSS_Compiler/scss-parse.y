%{
/** @file scss-parse.y
 *  @brief Grammar rules for the scss compiler/preprocessor.
 *
 *  This contains the Grammar rules for the preprocessor together with some rudimentary error handling and
 *  the main function which either prompts for input or parses a input file to the command line if given as 
 *  argument. 

 *  @author Raffaele Tranquillini  <rtranquillini@unibz.it>
 *  @author Francesco Piccoli <fpiccoli@unibz.it> 
 */


#define YYERROR_VERBOSE 1
#define BUFFER_SIZE_SMALL 128
#define BUFFER_SIZE_LARGE 1024

#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include <math.h>

#include "functions.h"
#include "symtable.h"

int yylex();
void yyerror (char const *message);

%}

// more useful syntax error messages for the user
%define parse.error verbose

// all the possible return values
%union {
        char* string;
        double number;
        SYMREC *sym;
        TABLE *decls;
        SYMREC *decl;
        VAR_CONTENTS expression;
}

// tokens and their respective precedences

%token<string>    ID
%token<number>    NUM
%token<string>    UNIT
%token<string>    PSEUDO
%token<string>    STRING
%token<sym>       VAR
%token            T_SEMICOLON
%token<string>    T_COLON
%token<string>    T_DOT
%token<string>    T_COMMA
%token<string>    T_HASH
%token            T_PL
%token            T_PR
%token            T_BL
%token            T_BR
%token            T_PLUS
%token            T_MINUS
%token            T_STAR
%token            T_DIV
%token            T_GT

// here we define the return type of non-terminals

%type <expression>   EXPR
%type <expression>   SCALAR
%type <decls>        CSSRULE
%type <decl>         DECLS
%type <decl>         DECL
%type <string>       FNCALL
%type <string>       SELECTORS 
%type <string>       SELECTOR 
%type <string>       PSEUDOCLASS 
%type <string>       RELATIONSHIP 
%type <string>       P 
%type <string>       PARAMS
%type <string>       COLORHEX

// precedence rules
%left T_MINUS T_PLUS
%left T_STAR T_DIV

// S is the starting symbol
%start S

%%

// here we define the grammar productions

S: ST S
  | { /*epsilon*/ }
  ;

ST: VARDECL
  | CSSRULE { print_css_tree();}
  ;

VARDECL: VAR T_COLON EXPR T_SEMICOLON { declare_variable($1,$3); }
  ;

EXPR: VAR { $$ = generate_var($1); }
  | SCALAR { $$ = $1; }
  | ID { $$ = generate_id($1); }
  | COLORHEX {char* hashColor = malloc(sizeof($1) + 4); sprintf(hashColor, "#%s", strdup($1)); $$ = generate_id(hashColor); }
  | FNCALL { $$ = generate_fncall($1); }
  | T_PL EXPR T_PR {$$ = $2;}
  | EXPR T_PLUS EXPR  {$$ = operation($1, $3, "+");}
  | EXPR T_MINUS EXPR {$$ = operation($1, $3, "-");}
  | EXPR T_STAR EXPR {$$ = operation($1, $3, "*");}
  | EXPR T_DIV EXPR  {$$ = operation($1, $3, "/");}
  | STRING { $$ = generate_atom($1);}
  ;

COLORHEX:  T_HASH ID {$$ = $2;}
  | T_HASH NUM {char* hashColor = malloc(11); sprintf(hashColor, "%.0f", $2); $$ = hashColor;}
  ;

SCALAR: NUM UNIT { $$ = generate_scalar($1, $2); }
  | NUM { $$ = generate_scalar($1, ""); }
  ;

FNCALL: ID T_PL P T_PR { $$ = malloc(BUFFER_SIZE_SMALL); snprintf($$, BUFFER_SIZE_SMALL, "%s(%s)", strdup($1), strdup($3)); }
  ;

P: EXPR PARAMS { $$ = malloc(BUFFER_SIZE_SMALL); snprintf($$, BUFFER_SIZE_SMALL, "%s%s", strdup(var_to_string(&$1)), strdup($2)); }
  | {$$=""; /*epsilon*/}
  ;

PARAMS: T_COMMA EXPR PARAMS { $$ = malloc(BUFFER_SIZE_SMALL); snprintf($$, BUFFER_SIZE_SMALL, ",%s%s", strdup(var_to_string(&$2)), strdup($3)); }
  | {$$=""; /*epsilon*/}
  ;

CSSRULE: SELECTORS  { css_decl_table_init($1); } T_BL DECLS T_BR { css_decl_insert_all(parent, $4); parent = (TABLE*) parent->parent; } 
  ;

SELECTORS: SELECTOR PSEUDOCLASS RELATIONSHIP { $$ = selector_to_string($1, $2, $3); }
  ;

SELECTOR: ID { $$ = $1; }
  | T_HASH ID { $$ = malloc(BUFFER_SIZE_SMALL);  snprintf($$, BUFFER_SIZE_SMALL, "#%s", strdup($2)); }
  | T_DOT ID { $$ = malloc(BUFFER_SIZE_SMALL); snprintf($$, BUFFER_SIZE_SMALL, ".%s", strdup($2)); }
  ;

PSEUDOCLASS: PSEUDO { $$ = malloc(BUFFER_SIZE_SMALL); snprintf($$, BUFFER_SIZE_SMALL, "%s", strdup($1)); }
  | {$$=""; /*epsilon*/}
  ;

  RELATIONSHIP: T_COMMA SELECTORS { $$ = malloc(BUFFER_SIZE_SMALL); snprintf($$, BUFFER_SIZE_SMALL, ",%s", strdup($2)); }
  | T_GT SELECTORS { $$ = malloc(BUFFER_SIZE_SMALL); snprintf($$, BUFFER_SIZE_SMALL, "> %s", strdup($2)); }
  | SELECTORS { $$ = $1; }
  | {$$=""; /*epsilon*/}
  ;
  
DECLS: DECL DECLS { $$ = css_decl_merge($1, $2); }
  | {$$ = 0; /*epsilon*/}
  ;
  
DECL: ID T_COLON EXPR T_SEMICOLON { $$ = generate_decl($1, &$3);}
  | CSSRULE {$$ = 0; /* handled at lower level */}
  | VARDECL {$$ = 0; /*nothing to do */}
  ;
%%

#include "lex.yy.c"

/* 
 * Global variables for the program 
 */

SYMREC *sym_table = 0;    // table for variables
TABLE *parent = 0;        // pointer to "level" of current table in tree
TABLES *root_nodes = 0;   // array of "root" nodes, that is, CSS rules/nodes with no parent

/* 
 * Custom error handler with line number
 */
void yyerror (char const *message) {
  extern int yylineno;
  fprintf (stderr, "\n!!! ERROR at line %d: %s !!!\n  ", yylineno, message);
  fputc ('\n', stderr);
}

/* 
 * Entry point of application
 */

int main(int argc, char *argv[]) {
  
      root_nodes = malloc(sizeof(TABLES));
      // either command line/Bash input, or input file as parameter

      if(argc < 2) {
            fprintf(stderr,"To exit at any time, press Ctrl+D (EOF).\n");
            fprintf(stderr,"-------------------------------------------\n");
            return yyparse();
      } 
      else {
            FILE *fp = fopen(argv[1],"r");
            if(!fp) 
            {
                  printf("!!! ERROR: source file cannot be opened !!!\n");
                  exit(0);
            }
            yyin = fp;
            int flag = yyparse();
            fclose(yyin);
            return flag;
      }
}