
#ifndef H_COMPLEX_NUM
#define H_COMPLEX_NUM

#include <stdbool.h>

#define DELIMITER_STR ":"

typedef struct
{
    double Real;
    double Img;
} Complex;

Complex parseComplex(char *cmpString)
{
    Complex c;
    const char *delimiter = DELIMITER_STR;
    char *ptr;
    char *real;
    char *img;

    // tokenize string based on delimiter

    ptr = strtok(cmpString, delimiter);
    if (ptr != NULL)
    {
        c.Real = atof(ptr);
    }

    if (ptr != NULL)
    {
        ptr = strtok(NULL, delimiter);
        c.Img = atof(ptr);
    }

    return c;
}

Complex createComplex(double rl, double im)
{
    Complex complex;

    complex.Real = rl;
    complex.Img = im;
    return complex;
}

Complex addComplex(Complex a, Complex b)
{
    Complex c;
    c.Real = a.Real + b.Real;
    c.Img = a.Img + b.Img;

    return c;
}

Complex subtractComplex(Complex a, Complex b)
{
    Complex c;
    c.Real = a.Real - b.Real;
    c.Img = a.Img - b.Img;

    return c;
}

Complex negateComplex(Complex a)
{
    Complex c;
    c.Real = -a.Real;
    c.Img = -a.Img;

    return c;
}

Complex multiplyComplex(Complex a, Complex b)
{
    Complex c;
    c.Real = a.Real * b.Real - a.Img * b.Img;
    c.Img = a.Real * b.Img + a.Img * b.Real;

    return c;
}

Complex conjugateComplex(Complex a)
{
    Complex c;
    c.Real = a.Real;
    c.Img = -a.Img;

    return c;
}

Complex divideComplex(Complex a, Complex b, int *error)
{
    Complex c;
    double denom = b.Real * b.Real + b.Img * b.Img;

    if (denom == 0.0)
    {
        *error = 1;
        return c;
    }

    c.Real = (a.Real * b.Real + a.Img * b.Img) / (denom);
    c.Img = (b.Real * a.Img - a.Real * b.Img) / (denom);

    return c;
}

bool compareComplex(Complex a, Complex b)
{
    return (a.Real == b.Real && a.Img == b.Img);
}

bool isReal(Complex a) {
    return (a.Img == 0);
}

void printComplex(Complex c)
{
    printf("%f + %fi\n", c.Real, c.Img);
}
#endif