#[=============================================================================[
# PHP/SearchLibraries

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
  HEADERS <header>...
  [LIBRARIES <library>...]
  [VARIABLE <variable>]
  [LIBRARY_VARIABLE <library_variable>]
  [TARGET <target> [<PRIVATE|PUBLIC|INTERFACE>]]
  [RECHECK_HEADERS]
)
```

Check that the `<symbol>` is available after including the `<header>` (or a list
of `<headers>`), or if any library from the `LIBRARY` list needs to be linked.
If `<variable>` is given, check result is stored in an internal cache variable.

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

* `VARIABLE`

  Name of a cache variable where the check result will be stored. Optional. If
  not given, the result will be stored in an internal automatically defined
  cache variable name.

* `LIBRARY_VARIABLE`

  When symbol is not found in the default libraries, the resulting library that
  contains the symbol is stored in this local variable name.

* `TARGET`

  If the `TARGET` is given, the resulting library is linked to a given
  `<target>` with the scope of `PRIVATE`, `PUBLIC`, or `INTERFACE`. Behavior is
  homogeneous to:

  ```cmake
  target_link_libraries(<target> [PRIVATE|PUBLIC|INTERFACE] <library>)
  ```

* `RECHECK_HEADERS`

  Enabling this option will recheck the header(s) by using specific
  `_PHP_SEARCH_LIBRARIES_HEADER_<HEADER_NAMES_H...>` cache variable names
  instead of the more common `HAVE_<HEADER_NAME>_H`. When checking headers in
  iteration, by default, the `HAVE_<HEADER_NAME>_H` cache variables are defined,
  so the entire check is slightly more performant if header(s) have already been
  checked elsewhere in the application using the `check_header_include()`. In
  most cases this won't be needed.

## Basic usage

In the following example, the library containing `dlopen` is linked to
`php_config` target with the `INTERFACE` scope when needed to use the `dlopen`
symbol. Cache variable `HAVE_LIBDL` is set if `dlopen` is found either in the
default system libraries or in one of the libraries set in the `CMAKE_DL_LIBS`
variable.

```cmake
# CMakeLists.txt

# Include the module
include(PHP/SearchLibraries)

# Search and link library containing dlopen and dlclose .
php_search_libraries(
  dlopen
  HEADERS dlfcn.h
  LIBRARIES ${CMAKE_DL_LIBS}
  VARIABLE HAVE_LIBDL
  TARGET php_config INTERFACE
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

# Helper macro that populates target and user passed library variable.
macro(_php_search_libraries_populate)
  if(${libraryInternalVariable})
    # Link found library to the optionally given target.
    if(target)
      target_link_libraries(
        ${target}
        ${targetScope}
        ${${libraryInternalVariable}}
      )
    endif()

    # Store found library in a local variable with name provided by the user.
    if(libraryResultVariable)
      set(
        ${libraryResultVariable}
        ${${libraryInternalVariable}}
        PARENT_SCOPE
      )
    endif()
  endif()
endmacro()

function(php_search_libraries)
  cmake_parse_arguments(
    PARSE_ARGV
    1
    parsed                      # prefix
    "RECHECK_HEADERS"           # options
    "VARIABLE;LIBRARY_VARIABLE" # one-value keywords
    "HEADERS;LIBRARIES;TARGET"  # multi-value keywords
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(NOT parsed_HEADERS)
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: missing HEADERS")
  endif()

  set(symbol ${ARGV0})
  set(headers ${parsed_HEADERS})
  set(recheckHeaders ${parsed_RECHECK_HEADERS})
  set(libraries ${parsed_LIBRARIES})

  if(NOT parsed_VARIABLE)
    string(
      MAKE_C_IDENTIFIER
      "HAVE_${symbol}_${parsed_HEADERS}_${parsed_LIBRARIES}"
      variableSuffix
    )
    string(TOUPPER "${variableSuffix}" variableSuffix)
    set(parsed_VARIABLE _PHP_SEARCH_LIBRARIES_${variableSuffix})
  else()
    set(variableSuffix ${parsed_VARIABLE})
  endif()

  set(symbolResultVariable ${parsed_VARIABLE})
  set(libraryResultVariable ${parsed_LIBRARY_VARIABLE})
  set(libraryInternalVariable _PHP_SEARCH_LIBRARIES_LIBRARY_${variableSuffix})

  # Clear LIBRARY_VARIABLE of any existing value if set in the parent scope.
  if(${libraryResultVariable})
    unset(${libraryResultVariable} PARENT_SCOPE)
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

  # Check if there are cached values stored from any previous run.
  if(DEFINED ${symbolResultVariable})
    _php_search_libraries_populate()

    return()
  endif()

  # Check if given header(s) can be included.
  set(headersFound "")
  foreach(header IN LISTS headers)
    if(recheckHeaders)
      set(id _PHP_SEARCH_LIBRARIES_HEADER_${headersFound}_${header})
    else()
      set(id HAVE_${header})
    endif()
    string(
      MAKE_C_IDENTIFIER
      "${id}"
      const
    )
    string(TOUPPER "${const}" const)

    cmake_push_check_state()
      cmake_language(GET_MESSAGE_LOG_LEVEL level)
      if(NOT level MATCHES "^(VERBOSE|DEBUG|TRACE)$")
        set(CMAKE_REQUIRED_QUIET TRUE)
      endif()

      # Check multiple headers appended with each iteration. If a header is not
      # self-contained, it may require including prior additional headers.
      check_include_files("${headersFound};${header}" ${const})
    cmake_pop_check_state()

    if(${const})
      list(APPEND headersFound ${header})
    endif()
  endforeach()

  # Check if symbol exists without linking additional libraries.
  check_symbol_exists(
    ${symbol}
    "${headersFound}"
    ${symbolResultVariable}
  )

  if(${symbolResultVariable})
    return()
  endif()

  # Clear any cached library value if running consecutively and symbol result
  # variable has been unset in the code after the check.
  unset(${libraryInternalVariable} CACHE)

  # Now, check if linking any given library helps finding the symbol.
  foreach(library IN LISTS libraries)
    unset(${symbolResultVariable} CACHE)

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

      check_symbol_exists(
        ${symbol}
        "${headersFound}"
        ${symbolResultVariable}
      )
    cmake_pop_check_state()

    if(${symbolResultVariable})
      if(NOT CMAKE_REQUIRED_QUIET)
        message(CHECK_PASS "found")
      endif()

      # Store found library in a cache variable for internal purpose.
      set(
        ${libraryInternalVariable} ${library}
        CACHE INTERNAL "Library required to use '${symbol}'."
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
