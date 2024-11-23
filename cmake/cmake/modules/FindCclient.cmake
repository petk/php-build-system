#[=============================================================================[
# FindCclient

Find the IMAP c-client library.

Also called UW-IMAP library was once maintained by the Washington University.
Today it is obsolete and its usage is discouraged. The c-client is a component
of the IMAP library that can be found as a standalone package on systems.

Module defines the following `IMPORTED` target(s):

* `Cclient::Cclient` - The package library, if found.

## Result variables

* `Cclient_FOUND` - Whether the package has been found.
* `Cclient_INCLUDE_DIRS` - Include directories needed to use this package.
* `Cclient_LIBRARIES` - Libraries needed to link to the package library.

## Cache variables

* `Cclient_INCLUDE_DIR` - Directory containing package library headers.
* `Cclient_LIBRARY` - The path to the package library.
* `HAVE_IMAP2000` - Whether c-client version is 2000 or newer. If true,
  c-client.h should be included instead of only rfc822.h on prior versions.
* `HAVE_IMAP2001` - Whether c-client version is 2001 to 2004.
* `HAVE_IMAP2004` - Whether c-client version is 2004 or newer.
* `HAVE_NEW_MIME2TEXT` - Whether utf8_mime2text() has new signature.
* `HAVE_RFC822_OUTPUT_ADDRESS_LIST` - Whether function
  `rfc822_output_address_list()` exists.
* `HAVE_IMAP_AUTH_GSS` - Whether `auth_gss` exists.
* HAVE_IMAP_MUTF7 - Whether `utf8_to_mutf7()` function exists.

## Functions provided by this module

The UW-IMAP c-client library was not originally designed to be a shared library.
The `mm_<name>` functions are callbacks, and are required to be implemented by
the program that is linking to c-client. Therefore this module also exposes
`cclient_check_function_exists()` and cclient_check_symbol_exists() functions,
which define them no-ops for doing additional checks during the configuration
phase. Note that cclient_check_function_exists() is a link test. The undefined
symbols will only cause problems if you actually try to link with c-client. For
example, if your test is trivial enough to be optimized out, and if you link
with --as-needed, the test/library may be omitted entirely from the final
executable. In that case linking will of course succeed, but your luck won't
necessarily apply at lower optimization levels or systems where `--as-needed` is
not used. The `cclient_check_symbol_exists()` provides a basic solution over
this issue.

```cmake
cclient_check_function_exists(<function> <result>)
```

* `<function>` - Function name to check if it is available in the c-client.
* `<result>` - Cache variable name for storing the check result.

```cmake
cclient_check_symbol_exists(<symbol> <header> <result>)
```

* `<symbol>` - Symbol name to check if it is available in the c-client.
* `<header>` - Header file to include.
* `<result>` - Cache variable name for storing the check result.
#]=============================================================================]

include(CheckSourceCompiles)
include(CMakePushCheckState)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

################################################################################
# Helpers.
################################################################################

set(_CCLIENT_DEFINITIONS [[
#if defined(__GNUC__) && __GNUC__ >= 4
# define IMAP_CCLIENT_EXPORT __attribute__ ((visibility("default")))
#else
# define IMAP_CCLIENT_EXPORT
#endif

IMAP_CCLIENT_EXPORT void mm_critical(MAILSTREAM *stream){}
IMAP_CCLIENT_EXPORT long mm_diskerror(MAILSTREAM *stream, long errcode, long serious) { return 1; }
IMAP_CCLIENT_EXPORT void mm_dlog(char *str){}
IMAP_CCLIENT_EXPORT void mm_exists(MAILSTREAM *stream, unsigned long number){}
IMAP_CCLIENT_EXPORT void mm_expunged(MAILSTREAM *stream, unsigned long number){}
IMAP_CCLIENT_EXPORT void mm_fatal(char *str){}
IMAP_CCLIENT_EXPORT void mm_flags(MAILSTREAM *stream, unsigned long number){}
#define DTYPE int
IMAP_CCLIENT_EXPORT void mm_list(MAILSTREAM *stream, DTYPE delimiter, char *mailbox, long attributes){}
IMAP_CCLIENT_EXPORT void mm_log(char *str, long errflg){}
IMAP_CCLIENT_EXPORT void mm_login(NETMBX *mb, char *user, char *pwd, long trial){}
IMAP_CCLIENT_EXPORT void mm_lsub(MAILSTREAM *stream, DTYPE delimiter, char *mailbox, long attributes){}
IMAP_CCLIENT_EXPORT void mm_nocritical(MAILSTREAM *stream){}
IMAP_CCLIENT_EXPORT void mm_notify(MAILSTREAM *stream, char *str, long errflg){}
IMAP_CCLIENT_EXPORT void mm_searched(MAILSTREAM *stream, unsigned long number){}
IMAP_CCLIENT_EXPORT void mm_status(MAILSTREAM *stream, char *mailbox, MAILSTATUS *status){}
]])

function(cclient_check_function_exists function result)
  message(CHECK_START "Looking for ${function}")

  cmake_push_check_state()
    if(TARGET Cclient::Cclient)
      list(APPEND CMAKE_REQUIRED_LIBRARIES Cclient::Cclient)
    else()
      if(Cclient_INCLUDE_DIR)
        list(APPEND CMAKE_REQUIRED_INCLUDES ${Cclient_INCLUDE_DIR})
      endif()

      if(Cclient_LIBRARY)
        list(APPEND CMAKE_REQUIRED_LIBRARIES ${Cclient_LIBRARY})
      endif()
    endif()
    set(CMAKE_REQUIRED_QUIET TRUE)

    check_source_compiles(C "
      #if defined(__GNUC__) && __GNUC__ >= 4
      # define IMAP_CCLIENT_EXPORT __attribute__ ((visibility(\"default\")))
      #else
      # define IMAP_CCLIENT_EXPORT
      #endif

      IMAP_CCLIENT_EXPORT void mm_critical(void){}
      IMAP_CCLIENT_EXPORT void mm_diskerror(void){}
      IMAP_CCLIENT_EXPORT void mm_dlog(void){}
      IMAP_CCLIENT_EXPORT void mm_exists(void){}
      IMAP_CCLIENT_EXPORT void mm_expunged(void){}
      IMAP_CCLIENT_EXPORT void mm_fatal(void){}
      IMAP_CCLIENT_EXPORT void mm_flags(void){}
      IMAP_CCLIENT_EXPORT void mm_list(void){}
      IMAP_CCLIENT_EXPORT void mm_log(void){}
      IMAP_CCLIENT_EXPORT void mm_login(void){}
      IMAP_CCLIENT_EXPORT void mm_lsub(void){}
      IMAP_CCLIENT_EXPORT void mm_nocritical(void){}
      IMAP_CCLIENT_EXPORT void mm_notify(void){}
      IMAP_CCLIENT_EXPORT void mm_searched(void){}
      IMAP_CCLIENT_EXPORT void mm_status(void){}

      char ${function}(void);

      int main(int argc, char* argv[])
      {
        ${function}();
        if (argc > 1000) {
          return *argv[0];
        }
        return 0;
      }
    " ${result})
  cmake_pop_check_state()

  if(${result})
    message(CHECK_PASS "found")
  else()
    message(CHECK_PASS "not found")
  endif()
endfunction()

function(cclient_check_symbol_exists symbol header result)
  message(CHECK_START "Looking for ${symbol}")

  cmake_push_check_state()
    if(TARGET Cclient::Cclient)
      list(APPEND CMAKE_REQUIRED_LIBRARIES Cclient::Cclient)
    else()
      if(Cclient_INCLUDE_DIR)
        list(APPEND CMAKE_REQUIRED_INCLUDES ${Cclient_INCLUDE_DIR})
      endif()

      if(Cclient_LIBRARY)
        list(APPEND CMAKE_REQUIRED_LIBRARIES ${Cclient_LIBRARY})
      endif()
    endif()

    # The c-client/c-client.h includes headers that define deprecated
    # _BSD_SOURCE, which emits a warning when including system's features.h.
    # When building with Clang, such warning results in an error. This can be
    # bypassed with defining the _DEFAULT_SOURCE to indicate that the source is
    # being transitioned to use the new macro, or in this case imap extension
    # being unbunbled in the PHP-8.4.
    list(APPEND CMAKE_REQUIRED_DEFINITIONS -D_DEFAULT_SOURCE)

    set(CMAKE_REQUIRED_QUIET TRUE)

    check_source_compiles(C "
      #include <${header}>

      ${_CCLIENT_DEFINITIONS}

      int main(int argc, char** argv)
      {
        (void)argv;
        #ifndef ${symbol}
          return ((int*)(&${symbol}))[argc];
        #else
          (void)argc;
          return 0;
        #endif
      }
    " ${result})
  cmake_pop_check_state()

  if(${result})
    message(CHECK_PASS "found")
  else()
    message(CHECK_PASS "not found")
  endif()
endfunction()

################################################################################
# Package properties.
################################################################################

set_package_properties(
  Cclient
  PROPERTIES
    URL "https://en.wikipedia.org/wiki/UW_IMAP"
    DESCRIPTION "The IMAP c-client library"
)

set(_reason "")

################################################################################
# Find headers.
################################################################################

find_path(
  Cclient_INCLUDE_DIR
  NAMES c-client.h rfc822.h
  PATH_SUFFIXES c-client imap
  DOC "Directory containing c-client library headers"
)

if(NOT Cclient_INCLUDE_DIR)
  string(APPEND _reason "c-client.h or rfc822.h not found. ")
endif()

################################################################################
# Find library.
################################################################################

find_library(
  Cclient_LIBRARY
  NAMES c-client c-client4 imap
  DOC "The path to the c-client library"
)

if(NOT Cclient_LIBRARY)
  string(APPEND _reason "IMAP c-client library not found. ")
endif()

mark_as_advanced(Cclient_INCLUDE_DIR Cclient_LIBRARY)

################################################################################
# Sanity checks.
################################################################################

if(Cclient_INCLUDE_DIR AND Cclient_LIBRARY)
  cclient_check_function_exists(mail_newbody _cclient_sanity_check_1)

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_INCLUDES ${Cclient_INCLUDE_DIR})
    set(CMAKE_REQUIRED_LIBRARIES ${Cclient_LIBRARY})
    set(CMAKE_REQUIRED_QUIET TRUE)

    # See explanation above.
    set(CMAKE_REQUIRED_DEFINITIONS -D_DEFAULT_SOURCE)

    message(CHECK_START "Checking for new utf8_mime2text signature")
    check_source_compiles(C "
      #include <c-client.h>
      ${_CCLIENT_DEFINITIONS}
      int main(void)
      {
        SIZEDTEXT *src, *dst;
        long flags;
        utf8_mime2text(src, dst, flags);
        return 0;
      }
    " HAVE_NEW_MIME2TEXT)
    if(HAVE_NEW_MIME2TEXT)
      message(CHECK_PASS "yes")
    else()
      message(CHECK_FAIL "no")
    endif()

    cclient_check_symbol_exists(
      U8T_DECOMPOSE
      c-client.h
      _HAVE_U8T_DECOMPOSE
    )
  cmake_pop_check_state()

  if(HAVE_NEW_MIME2TEXT AND NOT _HAVE_U8T_DECOMPOSE)
    string(
      APPEND
      _reason
      "Sanity check failed: utf8_mime2text() has new signature, but "
      "U8T_CANONICAL is missing. This should not happen. Check CMake logs for "
      "additional information. "
    )
  elseif(NOT HAVE_NEW_MIME2TEXT AND _HAVE_U8T_DECOMPOSE)
    string(
      APPEND
      _reason
      "Sanity check failed: utf8_mime2text() has old signature, but "
      "U8T_CANONICAL is present. This should not happen. Check CMake logs for "
      "additional information."
    )
  else()
    set(_cclient_sanity_check_2 TRUE)
  endif()
endif()

if(NOT _cclient_sanity_check_2)
  string(APPEND _reason "Sanity check failed: mail_newbody() not found. ")
endif()

################################################################################
# Handle package arguments.
################################################################################

find_package_handle_standard_args(
  Cclient
  REQUIRED_VARS
    Cclient_LIBRARY
    Cclient_INCLUDE_DIR
    _cclient_sanity_check_1
    _cclient_sanity_check_2
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Cclient_FOUND)
  return()
endif()

################################################################################
# Post-find configuration.
################################################################################

set(Cclient_INCLUDE_DIRS ${Cclient_INCLUDE_DIR})
set(Cclient_LIBRARIES ${Cclient_LIBRARY})

if(NOT TARGET Cclient::Cclient)
  add_library(Cclient::Cclient UNKNOWN IMPORTED)

  set_target_properties(
    Cclient::Cclient
    PROPERTIES
      IMPORTED_LOCATION "${Cclient_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${Cclient_INCLUDE_DIRS}"
  )
endif()

# Check whether c-client version is 2000 or newer.
if(EXISTS ${Cclient_INCLUDE_DIR}/c-client.h)
  set(
    HAVE_IMAP2000 1
    CACHE INTERNAL "Whether c-client version is 2000 or newer"
  )
endif()

block()
  message(CHECK_START "Checking for c-client version 2001")

  if(EXISTS ${Cclient_INCLUDE_DIR}/imap4r1.h)
    file(
      STRINGS
      ${Cclient_INCLUDE_DIR}/imap4r1.h
      imapsslport_results
      REGEX
      [[^[ \t]*#[ \t]*define[ \t]*IMAPSSLPORT[ \t]*\(.+\)]]
    )
  endif()

  if(imapsslport_results)
    message(CHECK_PASS "yes")
    set(
      HAVE_IMAP2001 1
      CACHE INTERNAL "Whether c-client version is 2001 to 2004"
    )
  else()
    message(CHECK_FAIL "no")
  endif()
endblock()

message(CHECK_START "Checking for c-client version 2004")
cclient_check_symbol_exists(
  mail_fetch_overview_sequence
  c-client.h
  HAVE_IMAP2004
)
if(HAVE_IMAP2004)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

cclient_check_symbol_exists(
  rfc822_output_address_list
  c-client.h
  HAVE_RFC822_OUTPUT_ADDRESS_LIST
)
cclient_check_function_exists(auth_gssapi_valid HAVE_IMAP_AUTH_GSS)
cclient_check_symbol_exists(utf8_to_mutf7 c-client.h HAVE_IMAP_MUTF7)
