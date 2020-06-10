#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include <math.h>
#include "symtable.h"

VAR_CONTENTS operations(VAR_CONTENTS v, VAR_CONTENTS x, char *operation);
VAR_CONTENTS assign_var(SYMREC *var);
VAR_CONTENTS assign_id(char* id);
VAR_CONTENTS assign_fncall(char* fnacall);
void vardecl_function(VAR_CONTENTS v, SYMREC* s);

VAR_CONTENTS assign_var(SYMREC* var){

  if(get_variable(var->name) > 0) {
      VAR_CONTENTS v;
      v.type = get_variable(var->name)->type;
      v.string = get_variable(var->name)->value.string;
      v.number = get_variable(var->name)->value.number;
      return v;
    } else {
      extern int yylineno;
      fprintf(stderr, "!!! ERROR at line %d: Variable %s not declared !!!", yylineno, var->name);
      exit(1);
    }

} 

VAR_CONTENTS assign_id(char* id){
  VAR_CONTENTS v;
  v.type = VAR_ATOM;
  v.string = strdup(id);
  v.number = 0;
  return v; 
}

void vardecl_function(VAR_CONTENTS var, SYMREC* sym){
  VAR_CONTENTS v = var;
  SYMREC* symbol = insert_variable(sym, v.type);
  symbol->value.number = v.number;
  symbol->value.string = v.string;
}

VAR_CONTENTS assign_fncall(char* fnacall){
  VAR_CONTENTS v;
    v.type = VAR_FUNCTION;
    v.string = strdup(fnacall);
    return v; 
}


VAR_CONTENTS operations(VAR_CONTENTS v, VAR_CONTENTS x, char* operation){

    VAR_CONTENTS z;

    if(strcmp(operation, "+") == 0 || strcmp(operation, "-") == 0){
        if(v.type == x.type && v.type == 2 && strcmp(v.string, x.string) == 0){
            z.type = 2;
            z.string = v.string;
            if(strcmp(operation, "+") == 0){
                z.number = v.number + x.number;
            }
            else{
                z.number = v.number - x.number;
            }
        } 
        else{ 
            if(strcmp(operation, "+") == 0){
              extern int yylineno;
              fprintf(stderr, "!!! ERROR at line %d: sum between \"%s\" and \"%s\" not allowed !!!\n", yylineno, v.string, x.string);
              exit(1);
            }
            else{
              extern int yylineno;
              fprintf(stderr, "!!! ERROR at line %d: subtraction between \"%s\" and \"%s\" not allowed !!!\n", yylineno, v.string, x.string);
              exit(1);
            }
        }
    }

    if(strcmp(operation, "*") == 0){
        if(v.type == x.type && v.type == 2 && (strcmp(v.string, "") == 0 || (strcmp(x.string, "") == 0))){
            z.type = 2;
            if(strcmp(v.string, "") == 0){
                z.string = x.string;
            }
            else{
                z.string = v.string;
            }
                z.number = v.number * x.number;
        } 
        else{ 
             extern int yylineno;
             fprintf(stderr, "!!! ERROR at line %d: multiplication between \"%s\" and \"%s\" not allowed !!!\n", yylineno, v.string, x.string);
             exit(1);
        }
    }

      if(strcmp(operation, "/") == 0){
        if(v.type == x.type && v.type == 2 && (strcmp(v.string, "") == 0 || (strcmp(x.string, "") == 0))){
            z.type = 2;
            if(strcmp(v.string, "") == 0){
                z.string = x.string;
            }
            else{
                z.string = v.string;
            }
                z.number = v.number / x.number;
        }
        else if((strcmp(x.string, v.string) == 0)){
          z.type = 2;
          z.string = "";
          z.number = v.number / x.number;
        }
        else{
             extern int yylineno;
             fprintf(stderr, "!!! ERROR at line %d: division between \"%s\" and \"%s\" not allowed !!!\n", yylineno, v.string, x.string);
             exit(1);
        }
    }
    return z;
}