#include <stdio.h>
#include <stdlib.h>

typedef union _mm_align_test {
	void *ptr;
	double dbl;
	long lng;
} mm_align_test;

#if (defined (__GNUC__) && __GNUC__ >= 2)
# define ZEND_MM_ALIGNMENT (__alignof__ (mm_align_test))
#else
# define ZEND_MM_ALIGNMENT (sizeof(mm_align_test))
#endif

int main(void)
{
	size_t i = ZEND_MM_ALIGNMENT;
	int zeros = 0;

	while (i & ~0x1) {
		zeros++;
		i = i >> 1;
	}

	printf("(size_t)%zu (size_t)%d %d\n", ZEND_MM_ALIGNMENT, zeros, ZEND_MM_ALIGNMENT < 4);

	return 0;
}
