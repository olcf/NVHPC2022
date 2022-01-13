#include <stdio.h>
#include <math.h>
#include <omp.h>
#include <string.h>

#define SZ 512

int same (float a, float b, float error)
{
    float x;

    if (a == 0)
    {
        x = b;
    }
    else if (b == 0)
    {
        x = a;
    }
    else
    {
        x = (a-b) / a;
    }

    return fabs(x) < error;
}

int main()
{
    int iter = 0;
    int iter_max = 1000;
    const float pi  = 2.0f * asinf(1.0f);
    const float tol1 = 1.0e-5f;
    const float tol2 = 1.0e-3f;
    float error     = 1.0f;

    float A[SZ][SZ] = {0};
    float Anew[SZ][SZ] = {0};
    float y0[SZ] = {0};

    for (int i = 0; i < SZ; ++i)
    {
        A[0][i]   = 0.f;
        A[SZ-1][i] = 0.f;
    }

    for (int j = 0; j < SZ; ++j)
    {
        y0[j] = sinf(pi * j / (SZ-1));
        A[j][0] = y0[j];
        A[j][SZ-1] = y0[j]*expf(-pi);
    }

    printf("Jacobi relaxation Calculation: %d x %d mesh\n", SZ, SZ);

    for (int i = 1; i < SZ; ++i)
    {
       Anew[0][i]   = 0.f;
       Anew[SZ-1][i] = 0.f;
    }

    for (int j = 1; j < SZ; ++j)
    {
        Anew[j][0]   = y0[j];
        Anew[j][SZ-1] = y0[j]*expf(-pi);
    }

    while ((error > tol1) && (iter < iter_max))
    {
        error = 0.f;

        for (int j = 1; j < SZ-1; ++j)
        {
            for (int i = 1; i < SZ-1; ++i)
            {
                Anew[j][i] = 0.25f * ( A[j][i+1] + A[j][i-1]
                                     + A[j-1][i] + A[j+1][i]);
                error = fmaxf( error, fabsf(Anew[j][i]-A[j][i]));
            }
        }

        for (int j = 1; j < SZ-1; ++j)
        {
            for (int i = 1; i < SZ-1; ++i)
            {
                A[j][i] = Anew[j][i];
            }
        }

        if (iter % 100 == 0) printf("%5d, %0.6f\n", iter, error);
        iter++;
    }

    printf("Final error, iter: %f, %d\n", error, iter);
    if (same(error, 0.0002397f, tol2))
    {
        printf(" PASS \n");
    }
    else
    {
        printf(" FAIL \n");
    }

    return 0;
}
