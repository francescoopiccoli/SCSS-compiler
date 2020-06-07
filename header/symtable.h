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

typedef struct
{
  char* string;
  double number;         // value of a simple variable
} hybrid_value; 

// structure of a symbol record 
typedef struct {
  char *name;           // name of symbol
  hybrid_value value;
  struct symrec *next;  // ptr to next symbol record
  enum var_type type;   // type of symbol: either DBL or CMP
} symrec;

typedef struct
{
  char *name;
  char *value;
  struct decl *next;
} decl;

typedef struct
{
  char *name;
  decl *head;
  struct declarations *parent;
} declarations;


/* The symbol table: a chain of 'struct symrec'.  */
extern symrec* sym_table;
extern declarations* parent;

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
  symrec *symbol = getSymbol(s->name);
  if(symbol == 0) {
    s->type = t;
    s->next = (struct symrec*)sym_table;
    sym_table = s;
    return s;
  } else {
    symbol->type = t;
    return s;
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
  
  printf("---------- ---------- ---------- ----------\n");
  printf("%-10s %-10s %-10s %-10s", "Number", "Name", "Type", "Value");
  printf("\n---------- ---------- ---------- ----------\n");
  
  for (ptr = sym_table; ptr != (symrec *) 0; ptr = (symrec *)ptr->next) 
  {
    printf("%-10i ", i);
    printf("%-12.12s ", ptr->name);
    if (ptr->type == VAR_SCALAR) {
          printf("%-10s","scalar");
          printf("%.0f%s", ptr->value.number, ptr->value.string);
        }
      if (ptr->type == VAR_ATOM) {
        printf("%-10s","atom");
        printf("%s", ptr->value.string);
     
      }
      if (ptr->type == VAR_FUNCTION) {
        printf("%-10s","function");
        printf("%s", ptr->value.string);
      }
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

/*
typedef struct
{
  char *name;
  char *value;
  decl *next;
} decl;

typedef struct
{
  char *name;
  declarations *parent;
  decl *head;
} declarations;*/

declarations *create_decl_table(char *name, declarations *parent) {
  declarations *d = (declarations*) malloc(sizeof(declarations));
  d->name = name;
  d->parent = (struct declarations*) parent;
  d->head = 0;
  return d;
}

void *insert_decl(declarations *decls, char *name, char *value) {
  decl *d = (decl*) malloc(sizeof(decl));
  d->name = strdup(name);
  d->value = strdup(value);
  d->next = 0;

  if(decls->head > 0) {
    decl *last = decls->head;
    while(last->next != 0)
      last = (decl*) last->next;
    last->next = (struct decl*) d;
  } else {
    decls->head = d; 
  }
}

void print_decls(declarations *decls) {
  if(decls != 0) {
    // traversal w/ parent rules listed first
    print_decls((declarations*) decls->parent);
    decl *c = decls->head;
    while(c != 0) {
      printf("%s: %s;\n", c->name, c->value);
      c = (decl*) c->next;
    }
  }
}


#endif