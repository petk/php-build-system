#[=============================================================================[
Find the IMAP c-client library.

Also called UW-IMAP library was once maintained by the Washington University.
Today it is obsolete and its usage is discouraged. The c-client is a component
of the IMAP library that can be found as a standalone package on systems.

Module defines the following IMPORTED target(s):

  Cclient::Cclient
    The package library, if found.

Result variables:

  Cclient_FOUND
    Whether the package has been found.
  Cclient_INCLUDE_DIRS
    Include directories needed to use this package.
  Cclient_LIBRARIES
    Libraries needed to link to the package library.

Cache variables:

  Cclient_INCLUDE_DIR
    Directory containing package library headers.
  Cclient_LIBRARY
    The path to the package library.

Hints:

  The Cclient_ROOT variable adds custom search path.

The UW-IMAP c-client library was not originally designed to be a shared library.
The mm_<name> functions are callbacks, and are required to be implemented by the
program that is linking to c-client. Therefore this module also exposes function
cclient_check_symbol(), which does the work of defining them all to no-ops for
you. Note that this is a link test. The undefined symbols will only cause
problems if you actually try to link with c-client. For example, if your test is
trivial enough to be optimized out, and if you link with --as-needed, the
test/library may be omitted entirely from the final executable. In that case
linking will of course succeed, but your luck won't necessarily apply at lower
optimization levels or systems where --as-needed is not used.

  cclient_check_symbol(<symbol> <result>)

    <symbol>
      Symbol name to check if it is available in the c-client.

    <result>
      Cache variable name for storing the check result.
#]=============================================================================]

include(CheckSourceCompiles)
include(CMakePushCheckState)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

function(cclient_check_symbol symbol result)
  message(CHECK_START "Looking for ${symbol}")

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES ${Cclient_LIBRARY})
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

      void ${symbol}(void);
      void (*f)(void);
      char foobar(void) {
        f = ${symbol};
      }

      int main(void) {
          foobar();

          return 0;
      }
    " ${result})
  cmake_pop_check_state()

  if(${${result}})
    message(CHECK_PASS "found")
  else()
    message(CHECK_PASS "not found")
  endif()
endfunction()

set_package_properties(
  Cclient
  PROPERTIES
    URL "https://en.wikipedia.org/wiki/UW_IMAP"
    DESCRIPTION "The IMAP c-client library"
)

set(_reason "")

find_path(
  Cclient_INCLUDE_DIR
  NAMES c-client.h rfc822.h
  PATH_SUFFIXES c-client imap
  DOC "Directory containing c-client library headers"
)

if(NOT Cclient_INCLUDE_DIR)
  string(APPEND _reason "c-client.h or rfc822.h not found. ")
endif()

find_library(
  Cclient_LIBRARY
  NAMES c-client c-client4 imap
  DOC "The path to the c-client library"
)

if(NOT Cclient_LIBRARY)
  string(APPEND _reason "IMAP c-client library not found. ")
endif()

mark_as_advanced(Cclient_INCLUDE_DIR Cclient_LIBRARY)

# Sanity check.
cclient_check_symbol(mail_newbody _cclient_sanity_check)

if(NOT _cclient_sanity_check)
  string(APPEND _reason "Sanity check failed: mail_newbody() not found. ")
endif()

find_package_handle_standard_args(
  Cclient
  REQUIRED_VARS
    Cclient_LIBRARY
    Cclient_INCLUDE_DIR
    _cclient_sanity_check
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Cclient_FOUND)
  return()
endif()

set(Cclient_INCLUDE_DIRS ${Cclient_INCLUDE_DIR})
set(Cclient_LIBRARIES ${Cclient_LIBRARY})

if(NOT TARGET Cclient::Cclient)
  add_library(Cclient::Cclient UNKNOWN IMPORTED)

  set_target_properties(
    Cclient::Cclient
    PROPERTIES
      IMPORTED_LOCATION "${Cclient_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${Cclient_INCLUDE_DIR}"
  )
endif()
