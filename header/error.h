#ifndef ERROR_M_H
#define ERROR_M_H
#include "scssFunctions.h"
#include "symtable.h"


bool areSymbolsInitialized(char* a, char* b)
{
    symrec* s1 = getSymbol(a);
    symrec* s2 = getSymbol(b);

}

bool isSymbolInitialized(char* a)
{
    symrec* s1 = getSymbol(a);
    
}

bool isSymbolDefined(char* a){
    symrec* s1 = getSymbol(a);
    
}


bool areSymbolsCompatibleType(char* a, char* b)
{
    symrec* s1 = getSymbol(a);
    symrec* s2 = getSymbol(b);
}
#endif