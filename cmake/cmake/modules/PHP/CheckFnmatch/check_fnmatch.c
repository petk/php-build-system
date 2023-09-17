#include <fnmatch.h>
#define y(a, b, c) (fnmatch (a, b, c) == 0)
#define n(a, b, c) (fnmatch (a, b, c) == FNM_NOMATCH)

int main(void) {
	return
		(!(y ("a*", "abc", 0)
			&& n ("d*/*1", "d/s/1", FNM_PATHNAME)
			&& y ("a\\\\bc", "abc", 0)
			&& n ("a\\\\bc", "abc", FNM_NOESCAPE)
			&& y ("*x", ".x", 0)
			&& n ("*x", ".x", FNM_PERIOD)));
}
