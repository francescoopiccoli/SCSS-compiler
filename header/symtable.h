#ifndef H_SYMTABLE
#define H_SYMTABLE

#include <stdlib.h>       // needed for malloc. 
#include <string.h>       // needed for strlen.
#include "scssFunctions.h"  // needed for complex.


// structure of a symbol record 
typedef struct {
      
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
symrec* putSymbol(char const *sym_name)
{

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
}



/**
* Print the entire symbol table in human readable form
*
*/
void showSymTable ()
{
  
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

/**
* forse ci serve per operazinei del tipo 5px + 5px ??
*/
symrec* mixedOperation(symrec* a,symrec* b, char op){
}


#endif
