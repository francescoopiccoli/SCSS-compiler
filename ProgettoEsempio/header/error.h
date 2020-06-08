#ifndef ERROR_M_H
#define ERROR_M_H
#include "complex_num.h"  // needed for complex.
#include "symtable.h"

bool areSymbolsValidComplex(char* a, char* b)
{
    symrec* s1 = get_variable(a);
    symrec* s2 = get_variable(b);
    if(s1 == 0 || s2 == 0) {
        printf("One component of the complex is not defined.\n");
        return false;
    } else if (s1->init == 0 || s2->init == 0) {
        printf("One component of the complex is not initialized.\n");
        return false;
    } else if (s1->type == CMP || s2->type == CMP) {
        printf("Complex numbers can only be composed of doubles.\n");
        return false;
    }
    return true;
}

bool areSymbolsInitialized(char* a, char* b)
{
    symrec* s1 = get_variable(a);
    symrec* s2 = get_variable(b);
    if(s1 == 0 || s2 == 0) {
        printf("One component of the operation is not defined.\n");
        return false;
    } else if (s1->init == 0 || s2->init == 0) {
        printf("Operation with an unitialized variable.\n");
        return false;
    }


    return true;
}

bool isSymbolInitialized(char* a)
{
    symrec* s1 = get_variable(a);
    if(s1 == 0) {
        printf("The component of the operation is not defined.\n");
        return false;
    } else if (s1->init == 0 ) {
        printf("The component of the operation is an unitialized variable.\n");
        return false;
    }
    return true;
}
bool isSymbolDefined(char* a){
    symrec* s1 = get_variable(a);
    if(s1 == 0) {
        printf("The component of the operation is not defined.\n");
        return false;
    }
    return true;
}


bool areSymbolsCompatibleType(char* a, char* b)
{
    symrec* s1 = get_variable(a);
    symrec* s2 = get_variable(b);
    if(s1 == 0 || s2 == 0) {
        printf("One component of the assignment is not defined.\n");
        return false;
    } else if (s2->init == 0) {
        printf("Assignment of an unitialized variable.\n");
        return false;
    } else if (s1->type == DBL && s2->type == CMP) {
        printf("A complex cannot be assigned to a double.\n");
        return false;
    }
    return true;
}
#endif