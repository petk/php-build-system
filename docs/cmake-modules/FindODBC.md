# FindODBC

Find the ODBC library.

Module defines the following `IMPORTED` target(s):

* `ODBC::ODBC` - The package library, if found.

Result variables:

* `ODBC_FOUND` - Whether the package has been found.
* `ODBC_INCLUDE_DIRS` - Include directories needed to use this package.
* `ODBC_LIBRARIES` - Libraries needed to link to the package library.
* `ODBC_VERSION` - Package version, if found.

Cache variables:

* `ODBC_INCLUDE_DIR` - Directory containing package library headers.
* `ODBC_LIBRARY` - The path to the package library.

Hints:

* The `ODBC_ROOT` variable adds custom search path.
* The `ODBC_TYPE` variable adds ODBC library name to look for.
