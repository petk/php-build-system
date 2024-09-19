# FindDbm

Find the dbm library.

Depending on the system, the dbm library can be part of other libraries as an
interface.

Module defines the following IMPORTED target(s):

  Dbm::Dbm
    The package library, if found.

Result variables:

  Dbm_FOUND
    Whether the package has been found.
  Dbm_INCLUDE_DIRS
    Include directories needed to use this package.
  Dbm_LIBRARIES
    Libraries needed to link to the package library.
  Dbm_IMPLEMENTATION
    String of the library name that implements the dbm library.

Cache variables:

  Dbm_INCLUDE_DIR
    Directory containing package library headers.
  Dbm_LIBRARY
    The path to the package library.

Hints:

  The Dbm_ROOT variable adds custom search path.
