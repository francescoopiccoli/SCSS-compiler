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
  struct SYMREC *next;  // ptr to next symbol record
  enum var_type type;
} SYMREC;

typedef struct
{
  char *name;
  char *value;
  struct DECL *next;
} DECL;

typedef struct
{
  char *name;
  DECL *head;
  struct DECLARATIONS *parent;
} DECLARATIONS;

typedef struct {
    char *string;
    double number;
    enum var_type type;
} VAR_CONTENTS;



/* The symbol table: a chain of 'struct SYMREC'.  */
extern SYMREC* sym_table;
extern DECLARATIONS* parent;

/**
* Put a symbol in the specified symbol table
*
* @param sym_name   Specifies the name of symbol to insert
* @param sym_type   Specifies the type of symbol to insert
*
* @return  A pointer to next symbol table record
*/
SYMREC* symbol_put(char const *sym_name)
{
  SYMREC* ptr = (SYMREC*) malloc (sizeof (SYMREC));
  ptr->name = (char*) malloc (strlen (sym_name) + 1);
  strcpy (ptr->name, sym_name);
  ptr->next = (struct SYMREC*)sym_table;
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
SYMREC* create_variable_table(char const *sym_name)
{
  SYMREC* ptr = (SYMREC*) malloc (sizeof (SYMREC));
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
SYMREC* get_variable(char const *sym_name)
{
  SYMREC* ptr;
  for (ptr = sym_table; ptr != 0; ptr = (SYMREC*)ptr->next)
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
SYMREC* insert_variable(SYMREC* s, enum var_type t)
{
  SYMREC *symbol = get_variable(s->name);
  if(symbol == 0) {
    s->type = t;
    s->next = (struct SYMREC*)sym_table;
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
void print_variables ()
{
  SYMREC* ptr;
  int i = 1;
  
  printf("---------- ---------- ---------- ----------\n");
  printf("%-10s %-10s %-10s %-10s", "Number", "Name", "Type", "Value");
  printf("\n---------- ---------- ---------- ----------\n");
  
  for (ptr = sym_table; ptr != (SYMREC *) 0; ptr = (SYMREC *)ptr->next) 
  {
    printf("%-10i ", i);
    printf("%-12.12s ", ptr->name);
    if (ptr->type == VAR_SCALAR) {
          printf("%-10s","scalar");
          printf("%.1f%s", ptr->value.number, ptr->value.string);
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
  SYMREC* ptr;
  int i = 0;
  for (ptr = sym_table; ptr != (SYMREC *) 0; ptr = (SYMREC *)ptr->next) 
  {
    i++;
  }
  return i;
}

DECLARATIONS *create_decl_table(char *name, DECLARATIONS *parent) {
  DECLARATIONS *d = (DECLARATIONS*) malloc(sizeof(DECLARATIONS));
  d->name = name;
  d->parent = (struct DECLARATIONS*) parent;
  d->head = 0;
  return d;
}

void *insert_decl(DECLARATIONS *decls, char *name, char *value) {
  DECL *d = malloc(sizeof(DECL));
  d->name = name;
  d->value = value;

  if(decls->head > 0) {
    DECL *last = decls->head;
    while(last->next != 0)
      last = (DECL*) last->next;
    last->next = (struct DECL*) d;
  } else {
    decls->head = d; 
  }
}

void print_decls(DECLARATIONS *decls) {
  if(decls != 0) {
    // traversal w/ parent rules listed first
    print_decls((DECLARATIONS*) decls->parent);
    DECL *c = decls->head;
    while(c != 0) {
      printf("%s: %s;\n", c->name, c->value);
      c = (DECL*) c->next;
    }
  }
}

char* var_to_string(VAR_CONTENTS *v) {
  char *ret;
  switch(v->type) {
    case VAR_ATOM:
    case VAR_FUNCTION:
      ret = v->string;
      break;
    case VAR_SCALAR:
      ret = malloc(128);
      snprintf(ret, 128, "%.2f%s", v->number, strdup(v->string));
  }
  return ret;
}

#endif