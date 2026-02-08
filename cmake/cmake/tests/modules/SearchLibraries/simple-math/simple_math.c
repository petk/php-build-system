/**
 * Simple Math library intended for testing.
 */

#include "simple_math.h"

int sm_max(int a, int b)
{
    return (a > b) ? a : b;
}

int sm_min(int a, int b)
{
    return (a < b) ? a : b;
}

int sm_abs(int x)
{
    return (x < 0) ? -x : x;
}

int sm_pow(int base, int exp)
{
    int result = 1;
    for (int i = 0; i < exp; i++) {
        result *= base;
    }
    return result;
}
