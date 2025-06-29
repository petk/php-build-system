#[=============================================================================[
Check 'gethostbyname_r()'.

The non-standard 'gethostbyname_r()' function has different signatures across
systems:

* Linux, BSD: 6 arguments
* Solaris, illumos: 5 arguments
* AIX, HP-UX: 3 arguments
* Haiku: network library has it for internal purposes, not intended for usage
  from the system headers.

See also:
https://www.gnu.org/software/autoconf-archive/ax_func_which_gethostbyname_r.html

Result variables:

* HAVE_FUNC_GETHOSTBYNAME_R_6 - Whether 'gethostbyname_r()' has 6 arguments.
* HAVE_FUNC_GETHOSTBYNAME_R_5 - Whether 'gethostbyname_r()' has 5 arguments.
* HAVE_FUNC_GETHOSTBYNAME_R_3 - Whether 'gethostbyname_r()' has 3 arguments.
* HAVE_GETHOSTBYNAME_R - Whether 'gethostbyname_r()' is available.
#]=============================================================================]

include_guard(GLOBAL)

include(CheckPrototypeDefinition)
include(CMakePushCheckState)
include(PHP/SearchLibraries)

set(HAVE_FUNC_GETHOSTBYNAME_R_6 FALSE)
set(HAVE_FUNC_GETHOSTBYNAME_R_5 FALSE)
set(HAVE_FUNC_GETHOSTBYNAME_R_3 FALSE)
set(HAVE_GETHOSTBYNAME_R FALSE)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

function(_php_check_gethostbyname_r)
  message(CHECK_START "Checking number of gethostbyname_r() arguments")

  # Check whether gethostname_r() is available. On systems that have it, it is
  # mostly in the default libraries (C library) - Linux, Solaris 11.4...
  php_search_libraries(
    gethostbyname_r
    HEADERS netdb.h
    LIBRARIES
      nsl # Solaris <= 11.3, illumos
    VARIABLE PHP_HAS_GETHOSTBYNAME_R
    LIBRARY_VARIABLE library
  )
  if(NOT PHP_HAS_GETHOSTBYNAME_R)
    message(CHECK_FAIL "not found")
    return()
  endif()

  if(library)
    target_link_libraries(php_config INTERFACE ${library})
  endif()

  # Check for 6 arguments signature.
  check_prototype_definition(
    gethostbyname_r
    "int gethostbyname_r(const char *name, struct hostent *ret, char *buf, \
      size_t buflen, struct hostent **result, int *h_errnop)"
    "0"
    netdb.h
    PHP_HAS_GETHOSTBYNAME_R_6
  )
  if(PHP_HAS_GETHOSTBYNAME_R_6)
    message(CHECK_PASS "six")
    return()
  endif()

  # Check for 5 arguments signature.
  check_prototype_definition(
    gethostbyname_r
    "struct hostent *gethostbyname_r(const char *name, struct hostent *result, \
      char *buffer, int buflen, int *h_errnop)"
    "0"
    netdb.h
    PHP_HAS_GETHOSTBYNAME_R_5
  )
  if(PHP_HAS_GETHOSTBYNAME_R_5)
    message(CHECK_PASS "five")
    return()
  endif()

  # Check for 3 arguments signature.
  check_prototype_definition(
    gethostbyname_r
    "int gethostbyname_r(const char *name, struct hostent *htent, \
      struct hostent_data *data)"
    "0"
    netdb.h
    PHP_HAS_GETHOSTBYNAME_R_3
  )
  if(PHP_HAS_GETHOSTBYNAME_R_3)
    message(CHECK_PASS "three")
    return()
  endif()

  message(CHECK_FAIL "unknown")
endfunction()

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  _php_check_gethostbyname_r()
cmake_pop_check_state()

if(PHP_HAS_GETHOSTBYNAME_R_6)
  set(HAVE_FUNC_GETHOSTBYNAME_R_6 TRUE)
endif()

if(PHP_HAS_GETHOSTBYNAME_R_5)
  set(HAVE_FUNC_GETHOSTBYNAME_R_5 TRUE)
endif()

if(PHP_HAS_GETHOSTBYNAME_R_3)
  set(HAVE_FUNC_GETHOSTBYNAME_R_3 TRUE)
endif()

if(
  HAVE_FUNC_GETHOSTBYNAME_R_6
  OR HAVE_FUNC_GETHOSTBYNAME_R_5
  OR HAVE_FUNC_GETHOSTBYNAME_R_3
)
  set(HAVE_GETHOSTBYNAME_R TRUE)
endif()
