#[=============================================================================[
# PHP/SearchLibraries

This module checks if symbol exists in given header(s) and libraries:

```cmake
include(PHP/SearchLibraries)
```

If symbol is not found in default linked libraries (for example, C library), a
given list of libraries is iterated and found library can be linked as needed.

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

## Commands

This module provides the following commands:

### `php_search_libraries()`

```cmake
php_search_libraries(
  <symbol>
  HEADERS <headers>...
  [LIBRARIES <libraries>...]
  [VARIABLE <variable>]
  [LIBRARY_VARIABLE <library-variable>]
  [TARGET <target> [<PRIVATE|PUBLIC|INTERFACE>]]
  [RECHECK_HEADERS]
)
```

Checks that the `<symbol>` is available after including the `<headers>` (or a
list of `<headers>`), or if any library from the `LIBRARIES` list needs to be
linked.

The arguments are:

* `<symbol>`

  The name of the C symbol to check.

* `HEADERS <headers>...`

  One or more headers where to look for the symbol declaration. Headers are
  checked in iteration with `check_include_files()` command and are appended
  to the list of found headers instead of a single header check. In some cases a
  header might not be self-contained (it requires additional prior headers to be
  included). For example, to be able to use `<arpa/nameser.h>` header on
  Solaris, the `<sys/types.h>` header must be included before.

* `LIBRARIES <libraries>...`

  If symbol is not found in the default libraries (C library), then the
  `LIBRARIES` list is iterated. Instead of using the `check_function_exists()`,
  the `check_symbol_exists()` is used, since it also works when symbol might be
  a macro definition. It would not be found using the other two commands because
  they don't include required headers.

* `VARIABLE <variable>`

  Optional. Name of an internal cache variable where the result of the check is
  stored. If not given, the result will be stored in an internal automatically
  defined cache variable name.

* `LIBRARY_VARIABLE <library-variable>`

  When symbol is not found in the default libraries, the resulting library that
  contains the symbol is stored in this internal cache variable name.

* `TARGET <target>`

  If specified, the resulting library is linked to a given `<target>` with the
  scope of `PRIVATE`, `PUBLIC`, or `INTERFACE`. Behavior is homogeneous to:

  ```cmake
  target_link_libraries(<target> [PRIVATE|PUBLIC|INTERFACE] <library>)
  ```

* `RECHECK_HEADERS`

  Enabling this option will recheck the headers by using automatically generated
  unique cache variable names of format
  `PHP_SEARCH_LIBRARIES_<SYMBOL>_<HEADER_NAME_H>` instead of the more common
  `HAVE_<HEADER_NAME>_H`. When checking headers in iteration, by default, the
  `HAVE_<HEADER_NAME>_H` cache variables are defined, so the entire check is
  slightly more performant if headers have already been checked elsewhere in the
  application using the `check_header_includes()`. In most cases this is not
  needed.

## Examples

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
  dlopen
  HEADERS dlfcn.h
  LIBRARIES ${CMAKE_DL_LIBS}
  VARIABLE PHP_HAS_DL
  TARGET php_config INTERFACE
)
```

The following variables may be set before calling this command to modify the
way the check is run. See
https://cmake.org/cmake/help/latest/module/CheckSymbolExists.html

* `CMAKE_REQUIRED_FLAGS`
* `CMAKE_REQUIRED_DEFINITIONS`
* `CMAKE_REQUIRED_INCLUDES`
* `CMAKE_REQUIRED_LINK_OPTIONS`
* `CMAKE_REQUIRED_LIBRARIES`
* `CMAKE_REQUIRED_LINK_DIRECTORIES`
* `CMAKE_REQUIRED_QUIET`

## Caveats

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
#]=============================================================================]

include_guard(GLOBAL)

include(CheckIncludeFiles)
include(CheckSymbolExists)
include(CMakePushCheckState)

# Populates target by linking found library to the optional target.
macro(_php_search_libraries_populate)
  if(target AND ${parsed_LIBRARY_VARIABLE})
    target_link_libraries(${target} ${targetScope} ${${parsed_LIBRARY_VARIABLE}})
  endif()
endmacro()

function(php_search_libraries)
  cmake_parse_arguments(
    PARSE_ARGV
    1
    parsed # prefix
    "RECHECK_HEADERS" # options
    "VARIABLE;LIBRARY_VARIABLE" # one-value keywords
    "HEADERS;LIBRARIES;TARGET" # multi-value keywords
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(NOT parsed_HEADERS)
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: missing HEADERS")
  endif()

  set(symbol ${ARGV0})

  if(NOT parsed_VARIABLE OR NOT parsed_LIBRARY_VARIABLE)
    string(MD5 hash "${symbol}_${parsed_HEADERS}_${parsed_LIBRARIES}")
    string(MAKE_C_IDENTIFIER "PHP_SEARCH_LIBRARIES_${symbol}_${hash}" prefix)
    string(TOUPPER "${prefix}" prefix)

    if(NOT parsed_VARIABLE)
      set(parsed_VARIABLE "${prefix}")
    endif()

    if(NOT parsed_LIBRARY_VARIABLE)
      set(parsed_LIBRARY_VARIABLE "${prefix}_LIBRARY")
    endif()
  endif()

  # Validate optional TARGET.
  if(parsed_TARGET)
    list(GET parsed_TARGET 0 target)

    if(NOT TARGET ${target})
      message(FATAL_ERROR "Bad TARGET arguments: ${target} is not a target.")
    endif()

    list(LENGTH parsed_TARGET length)
    set(targetScope "")
    if(length GREATER 1)
      list(GET parsed_TARGET 1 targetScope)
    endif()

    if(targetScope AND NOT targetScope MATCHES "^(PRIVATE|PUBLIC|INTERFACE)$")
      message(
        FATAL_ERROR
        "Bad TARGET arguments: ${targetScope} is not a target scope. Use one "
        "of PRIVATE|PUBLIC|INTERFACE."
      )
    endif()
  endif()

  # Check if there is cached value stored from any previous run.
  if(DEFINED ${parsed_VARIABLE})
    _php_search_libraries_populate()
    return()
  endif()

  # Check if given header(s) can be included.
  set(headersFound "")
  foreach(header IN LISTS parsed_HEADERS)
    if(parsed_RECHECK_HEADERS)
      string(MAKE_C_IDENTIFIER "PHP_SEARCH_LIBRARIES_${symbol}_${header}" id)
    else()
      string(MAKE_C_IDENTIFIER "HAVE_${header}" id)
    endif()
    string(TOUPPER "${id}" id)

    cmake_push_check_state()
      cmake_language(GET_MESSAGE_LOG_LEVEL level)
      if(NOT level MATCHES "^(VERBOSE|DEBUG|TRACE)$")
        set(CMAKE_REQUIRED_QUIET TRUE)
      endif()

      # Check multiple headers appended with each iteration. If a header is not
      # self-contained, it may require including prior additional headers.
      check_include_files("${headersFound};${header}" ${id})
    cmake_pop_check_state()

    if(${id})
      list(APPEND headersFound ${header})
    endif()
  endforeach()

  # Check if symbol exists without linking additional libraries.
  check_symbol_exists(${symbol} "${headersFound}" ${parsed_VARIABLE})

  if(${parsed_VARIABLE})
    return()
  endif()

  # Clear any cached library value if running consecutively and symbol result
  # variable has been unset in the code after the check.
  unset(${parsed_LIBRARY_VARIABLE} CACHE)

  # Now, check if linking any given library helps finding the symbol.
  foreach(library IN LISTS parsed_LIBRARIES)
    unset(${parsed_VARIABLE} CACHE)

    if(NOT CMAKE_REQUIRED_QUIET)
      message(CHECK_START "Looking for ${symbol} in ${library}")
    endif()

    cmake_push_check_state()
      # Make check friendlier and skip appending nonexistent IMPORTED or ALIAS
      # targets (with double-colon) to not result in a FATAL_ERROR (CMP0028).
      if(
        (NOT TARGET ${library} AND NOT ${library} MATCHES "::")
        OR TARGET ${library}
      )
        list(APPEND CMAKE_REQUIRED_LIBRARIES ${library})
      endif()

      set(CMAKE_REQUIRED_QUIET TRUE)

      check_symbol_exists(${symbol} "${headersFound}" ${parsed_VARIABLE})
    cmake_pop_check_state()

    if(${parsed_VARIABLE})
      if(NOT CMAKE_REQUIRED_QUIET)
        message(CHECK_PASS "found")
      endif()

      # Store found library in a cache variable for internal purpose.
      set(
        ${parsed_LIBRARY_VARIABLE}
        ${library}
        CACHE INTERNAL
        "Library required to use symbol '${symbol}'."
      )

      _php_search_libraries_populate()

      return()
    else()
      if(NOT CMAKE_REQUIRED_QUIET)
        message(CHECK_FAIL "not found")
      endif()
    endif()
  endforeach()
endfunction()
