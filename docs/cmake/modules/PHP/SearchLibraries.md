<!-- This is auto-generated file. -->
# PHP/SearchLibraries

* Module source code: [SearchLibraries.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/SearchLibraries.cmake)

Check if symbol exists in given header(s). If not found in default linked
libraries (for example, C library), a given list of libraries is iterated and
found library can be linked as needed.

Depending on the system, C functions can be located in one of the default linked
libraries when using the compiler, or they can be in separate system libraries
that need to be manually passed to the linker. The usual `check_symbol_exists()`
doesn't find them unless `CMAKE_REQUIRED_LIBRARIES` is specified.

For example, math functions (`math.h`) can be in the math library (`m`);
however, some systems, like macOS, Windows, and Haiku, have them in the C
library. Linking the math library (`-lm`) there isn't necessary. Additionally,
some systems might be in the process of moving functions from their dedicated
libraries to the C library. For example, illumos-based systems (`-lnsl`...), and
similar.

The logic in this module is somehow following the Autoconf's `AC_SEARCH_LIBS`.

Module exposes the following function:

```cmake
php_search_libraries(
  <symbol>
  <symbol_variable>
  HEADERS <header>...
  [LIBRARIES <library>...]
  [LIBRARY_VARIABLE <library_variable>]
  [TARGET <target> <PRIVATE|PUBLIC|INTERFACE>]
  [RECHECK_HEADERS]
)
```

Check that the `<symbol>` is available after including the `<header>` (or a list
of `<headers>`) and store the result in an internal cache variable
`<symbol_variable>`.

* `HEADERS`

  A header (or a list of headers) where to look for the symbol declaration.
  Headers are checked in iteration with `check_include_files()` and are appended
  to the list of found headers instead of a single header check. In some cases a
  header might not be self-contained (it requires including prior additional
  headers). For example, to be able to use `arpa/nameser.h` on Solaris, the
  `<sys/types.h>` header must be included before.

* `LIBRARIES`

  If symbol is not found in the default libraries (C library), then the
  `LIBRARIES` list is iterated. Instead of using the `check_library_exists()` or
  `check_function_exists()`, the `check_symbol_exists()` is used, since it also
  works when symbol might be a macro definition. It would not be found using the
  other two commands because they don't include required headers.

* `LIBRARY_VARIABLE`

  When symbol is not found in the default libraries, the resulting library that
  contains the symbol is stored in this local variable name.

* `TARGET`

  If the `TARGET` is given, the resulting library is linked to a given
  `<target>` with the scope of `PRIVATE`, `PUBLIC`, or `INTERFACE`. It is
  homogeneous to:

  ```cmake
  target_link_libraries(<target> PRIVATE|PUBLIC|INTERFACE <library>)
  ```

* `RECHECK_HEADERS`

  Enabling this option will recheck the header(s) by using specific
  `_PHP_SEARCH_LIBRARIES_HEADER_<HEADER_NAMES_H...>` cache variable names
  instead of the more common `HAVE_<HEADER_NAME>_H`. When checking headers in
  iteration, by default, the `HAVE_<HEADER_NAME>_H` cache variables are defined,
  so the entire check is slightly more performant if header(s) have already been
  checked elsewhere in the application using the `check_header_include()`. In
  most cases this won't be needed.

For example:

```cmake
include(PHP/SearchLibraries)

php_search_libraries(
  dlopen
  HAVE_LIBDL
  HEADERS dlfcn.h
  LIBRARIES
    ${CMAKE_DL_LIBS}
  TARGET php_configuration INTERFACE
)
```

The following variables may be set before calling this function to modify the
way the check is run. See
https://cmake.org/cmake/help/latest/module/CheckSymbolExists.html

* `CMAKE_REQUIRED_FLAGS`
* `CMAKE_REQUIRED_DEFINITIONS`
* `CMAKE_REQUIRED_INCLUDES`
* `CMAKE_REQUIRED_LINK_OPTIONS`
* `CMAKE_REQUIRED_LIBRARIES`
* `CMAKE_REQUIRED_QUIET`

Caveats:

* If symbol declaration is missing in its belonging headers, it won't be found
  with this module. There are still rare cases of such functions on some systems
  (for example, `fdatasync()` on macOS). In such cases it is better to use other
  approaches, such as CMake's `check_function_exists()`.

* If symbol is defined as a macro to a function that requires additional
  libraries linked, this module will find the symbol but won't find the required
  library. For example, the `dn_skipname()` on macOS is defined as a macro in
  `<resolv.h>` and resolves to a function `res_9_dn_skipname()` that requires
  the `resolv` library linked to work:

  ```c
  #define dn_skipname res9_dn_skipname
  ```

  As this is considered an architectural bug from this module point of view, in
  such cases it is better to use additional library check.

## Basic usage

```cmake
# CMakeLists.txt
include(PHP/SearchLibraries)
```
