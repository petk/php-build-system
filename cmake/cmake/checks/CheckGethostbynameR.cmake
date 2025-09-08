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
#]=============================================================================]

include(CheckPrototypeDefinition)
include(CMakePushCheckState)
include(PHP/SearchLibraries)

function(_php_check_gethostbyname_r)
  # Check whether gethostname_r() is available. On systems that have it, it is
  # mostly in the default libraries (C library) - Linux, Solaris 11.4...
  php_search_libraries(
    SYMBOL gethostbyname_r
    HEADERS netdb.h
    LIBRARIES
      nsl # Solaris <= 11.3, illumos
    RESULT_VARIABLE PHP_HAS_GETHOSTBYNAME_R
    LIBRARY_VARIABLE PHP_HAS_GETHOSTBYNAME_R_LIBRARY
  )
  if(NOT PHP_HAS_GETHOSTBYNAME_R)
    return()
  endif()

  if(
    DEFINED PHP_HAS_GETHOSTBYNAME_R_6
    OR DEFINED PHP_HAS_GETHOSTBYNAME_R_5
    OR DEFINED PHP_HAS_GETHOSTBYNAME_R_3
  )
    return()
  endif()

  message(CHECK_START "Checking number of gethostbyname_r() arguments")

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)

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
      cmake_pop_check_state()
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
      cmake_pop_check_state()
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
      cmake_pop_check_state()
      message(CHECK_PASS "three")
      return()
    endif()
  cmake_pop_check_state()

  message(CHECK_FAIL "unknown")
endfunction()

_php_check_gethostbyname_r()

set(HAVE_FUNC_GETHOSTBYNAME_R_6 "${PHP_HAS_GETHOSTBYNAME_R_6}")
set(HAVE_FUNC_GETHOSTBYNAME_R_5 "${PHP_HAS_GETHOSTBYNAME_R_5}")
set(HAVE_FUNC_GETHOSTBYNAME_R_3 "${PHP_HAS_GETHOSTBYNAME_R_3}")

if(
  HAVE_FUNC_GETHOSTBYNAME_R_6
  OR HAVE_FUNC_GETHOSTBYNAME_R_5
  OR HAVE_FUNC_GETHOSTBYNAME_R_3
)
  set(HAVE_GETHOSTBYNAME_R TRUE)
  if(PHP_HAS_GETHOSTBYNAME_R_LIBRARY)
    target_link_libraries(php_config INTERFACE ${PHP_HAS_GETHOSTBYNAME_R_LIBRARY})
  endif()
else()
  set(HAVE_GETHOSTBYNAME_R FALSE)
endif()
