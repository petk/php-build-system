# FindTidy

Find the Tidy library (tidy-html5, legacy htmltidy library, or the tidyp -
obsolete fork).

Module defines the following IMPORTED target(s):

  Tidy::Tidy
    The package library, if found.

Result variables:

  Tidy_FOUND
    Whether the package has been found.
  Tidy_INCLUDE_DIRS
    Include directories needed to use this package.
  Tidy_LIBRARIES
    Libraries needed to link to the package library.
  Tidy_VERSION
    Package version, if found.

Cache variables:

  Tidy_INCLUDE_DIR
    Directory containing package library headers.
  Tidy_LIBRARY
    The path to the package library.
  HAVE_TIDYBUFFIO_H
    Whether tidybuffio.h is available.
  HAVE_TIDY_H
    Whether tidy.h is available.
  HAVE_TIDYP_H
    If tidy.h is not available and whether the tidyp.h is available (tidy fork).

Hints:

  The Tidy_ROOT variable adds custom search path.
