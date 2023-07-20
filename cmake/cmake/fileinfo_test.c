#include <string.h>
#include <strings.h>
#include <stdlib.h>

int main(void)
{
    char *s0, *s1, *ret;

    s0 = (char *) malloc(42);
    s1 = (char *) malloc(8);

    memset(s0, 'X', 42);
    s0[24] = 'Y';
    s0[26] = 'Z';
    s0[41] = '\0';
    memset(s1, 'x', 8);
    s1[0] = 'y';
    s1[2] = 'Z';
    s1[7] = '\0';

    ret = strcasestr(s0, s1);

    return !(NULL != ret);
}
