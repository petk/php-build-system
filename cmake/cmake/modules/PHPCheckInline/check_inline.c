#ifndef __cplusplus
	typedef int foo_t;
	static inline foo_t static_foo (void) {return 0;}
	inline foo_t foo (void) {return 0;}
#endif

int main(void) {
	return 0;
}
