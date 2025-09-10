<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/SearchLibraries.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/SearchLibraries.cmake)

# PHP/SearchLibraries

This module provides a command for detecting C symbols in specified headers and
for testing whether C source snippet can be compiled. It also determines whether
additional libraries are required.

Load this module in a CMake project with:

```cmake
include(PHP/SearchLibraries)
```

Depending on the system, C functions and variables may reside in the default
libraries linked by the compiler, or they may be located in separate system
libraries that need to be passed to the linker manually. The standard CMake
`check_symbol_exists()` and `check_source_compiles()` commands don't find them
unless the `CMAKE_REQUIRED_LIBRARIES` variable is set.

For example, C standard math functions (`<math.h>`) are provided by the math
library (`m`) on many systems. However, on others, such as macOS, Windows, and
Haiku, they are part of the C library (or the math library is already linked by
default). In those cases, linking the math library (`-lm`) is unnecessary.
Similarly, some systems are in the process of moving functions from dedicated
libraries into the C library. For instance, illumos-based systems have been
consolidating functionality previously provided by libraries, such as `-lnsl`.

The logic in this module loosely follows the Autoconf's macro `AC_SEARCH_LIBS`.

## Commands

This module provides the following command:

### `php_search_libraries()`

Checks whether a specified C symbol or source snippet can be compiled with the
given headers, and determines if additional libraries need to be linked:

```cmake
php_search_libraries(
  SYMBOL <symbol> | SOURCE <code>
  [HEADERS <headers>...]
  [LIBRARIES <libraries>...]
  [RESULT_VARIABLE <var>]
  [LIBRARY_VARIABLE <library-var>]
  [TARGET <target> [<PRIVATE|PUBLIC|INTERFACE>]]
  [RECHECK_HEADERS]
)
```

This command first checks whether the symbol exists in the given headers, or
whether the source code can be compiled and linked with the default libraries
(for example, the C library). If not, it iterates over the specified list of
libraries and links the first one in which the symbol is found.

#### The arguments are:

* `SYMBOL <symbol>`

  The name of the C symbol to check.

* `SOURCE <code>`

  This argument can be used to check whether the specified C source `<code>` can
  be compiled and linked, instead of a `SYMBOL <symbol>` argument.

* `HEADERS <headers>...`

  A list of one or more headers where to look for the symbol declaration.
  Headers are checked in iteration and are appended to the list of found headers
  instead of a single header check. In some cases a header might not be
  self-contained (it requires additional prior headers to be included). For
  example, to be able to use `<arpa/nameser.h>` header on Solaris, the
  `<sys/types.h>` header must be included before.

  When using `SOURCE <code>` argument, `<headers>` are prepended to the C source
  `<code>` using `#include <header>...`.

* `LIBRARIES <libraries>...`

  If symbol is not found in the default libraries (C library), then the
  `LIBRARIES` list is iterated. Command also supports symbols that might be
  macro definitions.

  Any `-l` strings prepended to the provided libraries are removed in the
  results. For example, `-ldl` will be interpreted as `dl`.

* `RESULT_VARIABLE <var>`

  The name of an internal cache variable where the result of the check is
  stored. If this argument is not given, the result will be stored in an
  internal cache variable with automatically defined name.

* `LIBRARY_VARIABLE <library-var>`

  When symbol is not found in the default libraries, the resulting library name
  that contains the symbol is stored in this internal cache variable name. If
  this argument is not given, the resulting library name (if any), will be
  stored in the internal cache variable named `<var>_LIBRARY`.

* `TARGET <target> [<PRIVATE|PUBLIC|INTERFACE>]`

  If specified, the resulting library is linked to a given `<target>` with the
  scope of `PRIVATE`, `PUBLIC`, or `INTERFACE`. Behavior is homogeneous to:

  ```cmake
  target_link_libraries(<target> [PRIVATE|PUBLIC|INTERFACE] <library>)
  ```

* `RECHECK_HEADERS`

  Enabling this option will recheck the headers by using automatically generated
  unique cache variable names of format `PHP_SEARCH_LIBRARIES_<HEADER_NAME_H>`
  instead of the `PHP_HAVE_<HEADER_NAME>_H`. When checking headers in iteration,
  by default, the `PHP_HAVE_<HEADER_NAME>_H` cache variables are defined by this
  command, so the entire check is slightly more performant if headers have
  already been checked elsewhere in the application with PHP build system using
  the `check_header_includes()` command. In most cases this is not needed.

#### Variables affecting the check

The following variables may be set before calling this command to modify the way
the check is run:

* `CMAKE_REQUIRED_FLAGS`
* `CMAKE_REQUIRED_DEFINITIONS`
* `CMAKE_REQUIRED_INCLUDES`
* `CMAKE_REQUIRED_LINK_OPTIONS`
* `CMAKE_REQUIRED_LIBRARIES`
* `CMAKE_REQUIRED_LINK_DIRECTORIES`
* `CMAKE_REQUIRED_QUIET`

See https://cmake.org/cmake/help/latest/module/CheckSymbolExists.html for more
info about these variables.

## Caveats

* When checking for symbol and if symbol declaration is missing in its belonging
  headers, it won't be found with this module. There are still rare cases of
  such functions on some systems (for example, `fdatasync()` on macOS). In such
  cases it is better to use other approaches, such as CMake's
  `check_function_exists()`.

* When checking for symbol and if symbol is defined as a macro to a function
  that requires additional libraries linked, this module will find the symbol
  but won't find the required library. For example, the `dn_skipname()` on macOS
  is defined as a macro in `<resolv.h>` and resolves to a function
  `res_9_dn_skipname()` that requires the `resolv` library linked to work:

  ```c
  #define dn_skipname res9_dn_skipname
  ```

  As this is considered an architectural bug from this module point of view, in
  such cases it is better to use additional library check.

## Examples

### Example: Basic usage

In the following example, the library containing `dlopen()` is linked to
`php_config` target with the `INTERFACE` scope when needed to use the `dlopen()`
symbol. Cache variable `PHP_HAS_DL` is set if `dlopen()` is found either in the
default system libraries or in one of the libraries set in the `CMAKE_DL_LIBS`
variable.

```cmake
# CMakeLists.txt

# Include the module.
include(PHP/SearchLibraries)

# Search and link library containing dlopen() and dlclose().
php_search_libraries(
  SYMBOL dlopen
  HEADERS dlfcn.h
  LIBRARIES ${CMAKE_DL_LIBS}
  RESULT_VARIABLE PHP_HAS_DL
  TARGET php_config INTERFACE
)
```

### Example: Checking source code

In the following example, this module is used to check whether the source code
can be compiled and linked, and if additional library is required to use the
`in6addr_any` variable from `<netinet/in.h>`. The boolean result of the check
is stored in the `PHP_HAVE_IPV6` internal cache variable, and the name of the
additional required library, if any, is stored in the `PHP_HAVE_IPV6_LIBRARY`
internal cache variable.

```cmake
include(PHP/SearchLibraries)

php_search_libraries(
  SOURCE [[
    #include <sys/types.h>
    #include <sys/socket.h>
    #include <netinet/in.h>

    int main(void)
    {
      struct sockaddr_in6 s;
      struct in6_addr t = in6addr_any;
      int i = AF_INET6;
      t.s6_addr[0] = 0;
      (void)s;
      (void)t;
      (void)i;

      return 0;
    }
  ]]
  LIBRARIES
    socket  # Solaris <= 11.3, illumos
    network # Haiku
  RESULT_VARIABLE PHP_HAVE_IPV6
  LIBRARY_VARIABLE PHP_HAVE_IPV6_LIBRARY
)
```
