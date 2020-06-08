%{
/** @file calc.y
 *  @brief Grammar rules for the imaginair calculator.
 *
 *  This contains the Grammar rules for calculator 
 *  together with some rudimentary error handling and
 *  the main function which either prompts for input or
 *  parses a input file to the command line if given as 
 *  argument. 
 *
 *  @author Werner Sperandio  <werner.sperandio@yahoo.de>
 *  @author Alessandro Piccoli <alessandro.piccoli@stud-inf.unibz.it> 
 *  @author Stefan Brocanelli <stefan.brocanelli@stud-inf.unibz.it> 
 *
 *
 *  @bug No known bugs?
 */
#define YYERROR_VERBOSE 1

#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include "header/complex_num.h"
#include "header/symtable.h"
#include "header/error.h"

%}

// here we define all return values that lex can return
%union {
       char* lexeme;			// token text itself
       double value;			// value of an identifier of type NUM
       Complex complex;             // structure of type Complex
       symrec* symbol;              // structure of type symbol record (for ID)
       enum var_type varType;
       }



// here we define the tokens with its respective precedences

%token            LP
%token            RP
%token <value>    NUM
%token            SEMI
%token            OP_ASSIGN
%token            OP_EXP
%token            IF
%token            THEN
%token            ELSE
%token <symbol>   ID
%token            EXIT
%token            RETURN
%token            QUIT
%token            OP_COMP
%token            VAR_TYPE
%token            CMP_TYPE

%type <varType>   DECL_TYPE
%type <symbol>    MEXPR

%left OP_MINUS OP_PLUS 
%left OP_MULT OP_DIV 
%right UMINUS OP_I

%start LINE

// here we define the grammar
%%

// line and statement rules

LINE
    
    : STMT SEMI LINE 
    | STMT SEMI 
    | SEMI LINE 
    | error SEMI LINE {printf("ERROR"); yyclearin; yyerrok;} // on error continue prompting

    ;

// statement rules: expression or declaration or assignment or complex expression

STMT  
      :DECL           {printf("Declaration\n"); print_variables();}
      | ASSIGN         {printf("Assignment\n"); print_variables();}
      | MEXPR          {if($1->type==CMP){printComplex($1->value.cmp);}else{printf("%f\n",$1->value.var);}}
      ;

// declaration rules

DECL  
      : DECL_TYPE ID           {insert_variable($2, $1);}
      | DECL_TYPE ID OP_ASSIGN MEXPR {
                                   if (get_variable($2->name) != 0)
                                   {
                                         printf("Redeclaration of variable %s\n", $2->name);
                                    YYERROR;
                                   }
                                    if($1==CMP){
                                           symrec* s1 = insert_variable($2,$1 );
                                          if($4->type==CMP){
                                                s1->value.cmp=$4->value.cmp;
                                                s1->init=1;
                                          }
                                          else{
                                                s1->value.cmp=createComplex($4->value.var,0);
                                                s1->init=1;  
                                          }

                                    }  
                                    else{
                                          if($4->type==CMP){
                                                printf("Cannot assign complex to double\n");
                                                YYERROR;
                                          }
                                          else{
                                                  symrec* s1 = insert_variable($2,$1 );
                                                s1->value.var=$4->value.var;
                                                s1->init=1;  
                                          }
                                    }
                                
                             }
      ;


// type rules

DECL_TYPE    
      : VAR_TYPE  { $$ = DBL; }
      | CMP_TYPE  { $$ = CMP; }
      ;


MEXPR : MEXPR OP_PLUS MEXPR  {$$ = mixedOperation($1,$3,'+');} 
      | MEXPR OP_MINUS MEXPR {$$ = mixedOperation($1,$3,'-');}
      | MEXPR OP_MULT MEXPR  {$$ = mixedOperation($1,$3,'*');} 
      | MEXPR OP_DIV MEXPR   {$$ = mixedOperation($1,$3,'/');}
      | LP MEXPR RP          {$$ = $2;}
      | MEXPR OP_I MEXPR  { if($1->type==DBL && $3->type==DBL){$$ = complexToSymbol(createComplex($1->value.var,$3->value.var));}else{printf("Cannot build complex out of complex.\n"); YYERROR;}}
      | OP_MINUS MEXPR %prec UMINUS {if ($2->type == DBL)
                                           {$$ = doubleToSymbol(-($2->value.var));} 
                                           else
                                           {$$ = complexToSymbol(negateComplex($2->value.cmp));}
                                           }

      | ID                   { if (strcmp($1->name, "exit")==0) { exit(0);}
            
            if (!isSymbolInitialized($1->name))
                                {
                                    YYERROR;
                                }
                              else{
                                  symrec* s1 = get_variable($1->name);
                                  $$=s1;                     
                             }
                             }
      | NUM                  {$$=doubleToSymbol($1);}
      ;

// expression rules

ASSIGN  : ID OP_ASSIGN MEXPR   {if(!isSymbolDefined($1->name)){
                                    YYERROR;
                                }
                                else{
                                    symrec* s1 = get_variable($1->name);
                                    if(s1->type==CMP){
                                          if($3->type==CMP){
                                                s1->value.cmp=$3->value.cmp;
                                                s1->init=1;
                                          }
                                          else{
                                                s1->value.cmp=createComplex($3->value.var,0);
                                                s1->init=1;  
                                          }

                                    }  
                                    else{
                                          if($3->type==CMP){
                                                printf("Cannot assign complex to double");
                                                YYERROR;
                                          }
                                          else{
                                                s1->value.var=$3->value.var;
                                                s1->init=1;  
                                          }
                                    }
                                }
                             }
;


%%

/* The symbol table: a chain of 'struct symrec'.  */
symrec *sym_table = 0;

#include "lex.yy.c"

int main(int argc, char *argv[]) 
{      
      // interactive mode or file mode
      if(argc < 2) 
      {
            printf("Welcome to Imaginair, a calculator optimized for complex numbers! To exit at any time, type \"exit;\".\n");
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


