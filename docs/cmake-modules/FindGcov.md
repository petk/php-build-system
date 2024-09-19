# FindGcov

Find the Gcov coverage programs and features.

Module defines the following IMPORTED target(s):

  Gcov::Gcov
    The package library, if found.

Result variables:

  Gcov_FOUND
    Whether the package has been found.

Cache variables:

  Gcov_GCOVR_EXECUTABLE
  Gcov_GENHTML_EXECUTABLE
  Gcov_LCOV_EXECUTABLE

  HAVE_GCOV
    Whether the Gcov is available.

Hints:

  The Gcov_ROOT variable adds custom search path.

Module exposes the following macro that generates HTML coverage report:

  gcov_generate_report()
