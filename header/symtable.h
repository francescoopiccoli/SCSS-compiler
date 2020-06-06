#ifndef H_SYMTABLE
#define H_SYMTABLE

#include <stdlib.h>       // needed for malloc. 
#include <string.h>       // needed for strlen.
#include <stdbool.h>
#include <stdio.h>

// variable type enumeration
enum var_type{
  VAR_ATOM = 1,
  VAR_SCALAR = 2,
  VAR_FUNCTION = 3
};

// structure of a symbol record 
typedef struct {
  char *name;           // name of symbol
  union
  {
    char* string;
    double number;         // value of a simple variable
  } value; 
  struct symrec *next;  // ptr to next symbol record
  enum var_type type;   // type of symbol: either DBL or CMP
  bool init;     
} symrec;

/* The symbol table: a chain of 'struct symrec'.  */
extern symrec* sym_table;


/**
* Put a symbol in the specified symbol table
*
* @param sym_name   Specifies the name of symbol to insert
* @param sym_type   Specifies the type of symbol to insert
*
* @return  A pointer to next symbol table record
*/
symrec* symbol_put(char const *sym_name)
{
  symrec* ptr = (symrec*) malloc (sizeof (symrec));
  ptr->name = (char*) malloc (strlen (sym_name) + 1);
  strcpy (ptr->name, sym_name);
  ptr->next = (struct symrec*)sym_table;
  sym_table = ptr;
  return ptr;
}


/**
* Create a symbol with specified name by allocating memory
*
* @param sym_name   Specifies the name of symbol to insert
*
* @return  A pointer to the created symbol
*/
symrec* createSymbol(char const *sym_name)
{
  symrec* ptr = (symrec*) malloc (sizeof (symrec));
  ptr->name = (char*) malloc (strlen (sym_name) + 1);
  ptr->init = 0;
  strcpy (ptr->name, sym_name);
  return ptr;
}

/**
* Get a symbol from the symbol table
*
* @param sym_name   Specifies the name of symbol to search for
*
* @return  A pointer to next symbol table record or 0 if not found
*/
symrec* getSymbol(char const *sym_name)
{
  symrec* ptr;
  for (ptr = sym_table; ptr != 0; ptr = (symrec*)ptr->next)
   { if (strcmp (ptr->name, sym_name) == 0)
      return ptr;
   }
  return 0;
}


/**
* Insert a symbol in the symbol table 
*
* @param s    Specifies a pointer to the symbol to insert
* @param t    Specifies the type of symbol that has to be inserted
*
* @return  A pointer to next symbol table record
*/
symrec* insertSymbol(symrec* s, enum var_type t)
{
  if(getSymbol(s->name) == 0) {
      s->init = 0;
    s->type = t;
    s->next = (struct symrec*)sym_table;
    sym_table = s;
    return s;
  } else {
    printf("Redeclaration of variable %s.\n", s->name);
    return 0;
  }

}



/**
* Print the entire symbol table in human readable form
*
*/
void showSymTable ()
{
  symrec* ptr;
  int i = 1;
  
  printf("------- ------------ ------ ------------\n");
  printf("Number  Name         Type   Value       \n");
  printf("------- ------------ ------ ------------\n");
  
  for (ptr = sym_table; ptr != (symrec *) 0; ptr = (symrec *)ptr->next) 
  {
    printf("%-7i ", i);
    printf("%-12.12s ", ptr->name);
    /*if (ptr->type == DBL) {
          printf("%-7s","dbl");
          if(ptr->init != 0) {
            printf("%f", ptr->value.var);
          } else {
            printf("not init.");
          }
        }
      if (ptr->type == CMP) {
        printf("%-7s","cmp");
        if(ptr->init != 0) {
          //printComplex(ptr->value.cmp);
        } else {
          printf("not init.");
        }
      }*/
    i++;
    printf("\n");
  }
  
}

/**
* Count the number of symbol table records
*
* @return  The number of records
*/
int size ()
{
  symrec* ptr;
  int i = 0;
  for (ptr = sym_table; ptr != (symrec *) 0; ptr = (symrec *)ptr->next) 
  {
    i++;
  }
  return i;
}



/**
* Check if symbol table is empty
*
* @return  True if empty, false otherwise
*/

bool isEmpty() {
  return (size(sym_table) == 0);
}

/*
Complex createComplexFromSymbol(symrec* s)
{
  if (s->type == DBL)
      return createComplex(s->value.var, 0);
  else return s->value.cmp;
}

symrec* mixedOperation(symrec* a,symrec* b, char op){
  symrec* temp=createSymbol("temp");
  temp->init=1;
  
  if(a->type==DBL && b->type==DBL){
    double doubleResult;
    if(op=='+'){doubleResult=a->value.var+b->value.var;}
    if(op=='-'){doubleResult=a->value.var-b->value.var;}
    if(op=='*'){doubleResult=a->value.var*b->value.var;}
    if(op=='/'){doubleResult=a->value.var/b->value.var;}
    temp->type=DBL;
    temp->value.var=doubleResult;
  }
  else if(a->type==DBL && b->type==CMP || a->type==CMP && b->type==DBL || a->type==CMP && b->type==CMP){
    Complex compResult;
    Complex compA=createComplexFromSymbol(a);
    Complex compB=createComplexFromSymbol(b);
    if(op=='+'){compResult=addComplex(compA,compB);}
    if(op=='-'){compResult=subtractComplex(compA,compB);}
    if(op=='*'){compResult=multiplyComplex(compA,compB);}
    if(op=='/'){int error=0; compResult=divideComplex(compA,compB,&error);}
    temp->type=CMP;
    temp->value.cmp=compResult;
  }
return temp;
}

symrec* doubleToSymbol(double a){
  symrec* temp1=createSymbol("temp1");
  temp1->init=1;
  temp1->type=DBL;
  temp1->value.var=a;
return temp1;
}
symrec* complexToSymbol(Complex a){
  symrec* temp2=createSymbol("temp2");
  temp2->init=1;
  temp2->type=CMP;
  temp2->value.cmp=a;
return temp2;
}
*/


#endif