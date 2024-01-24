#[=============================================================================[
Find the IMAP C-client library.

Also called UW-IMAP library was once maintained by the Washington University but
is today obsolete and its usage is discouraged.

Module defines the following IMPORTED targets:

  CClient::CClient
    The C-client library if found.

Result variables:

  CClient_FOUND
    Whether C-client library has been found.
  CClient_INCLUDE_DIRS
    A list of include directories for using C-client library.
  CClient_LIBRARIES
    A list of libraries for linking when using C-client library.

Cache variables:

  HAVE_IMAP2000
    Whether c-client version is 2000 or newer and c-client.h should be included
    instead of previous rfc822.h.

Hints:

  The CClient_ROOT variable adds custom search path.

The UW-IMAP c-client library was not originally designed to be a shared library.
The mm_foo functions are callbacks, and are required to be implemented by the
program that is linking to c-client. Therefore this module also exposes function
cclient_check_symbol(), which does the work of defining them all to no-ops for
you. Note that this is a link test. The undefined symbols will only cause
problems if you actually try to link with c-client. For example, if your test is
trivial enough to be optimized out, and if you link with --as-needed, the
test/library may be omitted entirely from the final executable. In that case
linking will of course succeed, but your luck won't necessarily apply at lower
optimization levels or systems where --as-needed is not used.

  function cclient_check_symbol(<symbol> <result>)

    <symbol>
      Symbol name to check if available.

    <result>
      Cache variable name for storing the check result.
#]=============================================================================]

include(CheckSourceCompiles)
include(CMakePushCheckState)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

################################################################################
# Helpers.
################################################################################

function(cclient_check_symbol symbol result)
  message(CHECK_START "Looking for ${symbol}")

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES ${CClient_LIBRARIES})
    set(CMAKE_REQUIRED_QUIET TRUE)

    check_source_compiles(C "
      #if defined(__GNUC__) && __GNUC__ >= 4
      # define PHP_IMAP_EXPORT __attribute__ ((visibility(\"default\")))
      #else
      # define PHP_IMAP_EXPORT
      #endif

      PHP_IMAP_EXPORT void mm_log(void){}
      PHP_IMAP_EXPORT void mm_dlog(void){}
      PHP_IMAP_EXPORT void mm_flags(void){}
      PHP_IMAP_EXPORT void mm_fatal(void){}
      PHP_IMAP_EXPORT void mm_critical(void){}
      PHP_IMAP_EXPORT void mm_nocritical(void){}
      PHP_IMAP_EXPORT void mm_notify(void){}
      PHP_IMAP_EXPORT void mm_login(void){}
      PHP_IMAP_EXPORT void mm_diskerror(void){}
      PHP_IMAP_EXPORT void mm_status(void){}
      PHP_IMAP_EXPORT void mm_lsub(void){}
      PHP_IMAP_EXPORT void mm_list(void){}
      PHP_IMAP_EXPORT void mm_exists(void){}
      PHP_IMAP_EXPORT void mm_searched(void){}
      PHP_IMAP_EXPORT void mm_expunged(void){}

      void ${symbol}(void);
      void (*f)(void);
      char foobar() {f = ${symbol};}

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

################################################################################
# Find package.
################################################################################

set_package_properties(CClient PROPERTIES
  URL "https://en.wikipedia.org/wiki/UW_IMAP"
  DESCRIPTION "The IMAP C-client library"
)

set(_reason_failure_message)

find_path(
  CClient_INCLUDE_DIRS
  c-client.h
  PATH_SUFFIXES
    c-client
    imap
)

if(CClient_INCLUDE_DIRS)
  set(HAVE_IMAP2000 1 CACHE INTERNAL "Whether c-client version is 2000 or newer")
else()
  find_path(
    CClient_INCLUDE_DIRS
    rfc822.h
    PATH_SUFFIXES
      c-client
      imap
  )
endif()

if(NOT CClient_INCLUDE_DIRS)
  string(
    APPEND _reason_failure_message
    "\n    c-client.h or rfc822.h not found."
  )
endif()

find_library(
  CClient_LIBRARIES
  NAMES c-client c-client4 imap
  DOC "The C-client library"
)

if(NOT CClient_LIBRARIES)
  string(
    APPEND _reason_failure_message
    "\n    C-client library not found. Please install IMAP C-client library."
  )
endif()

mark_as_advanced(CClient_LIBRARIES CClient_INCLUDE_DIRS)

# Sanity check.
cclient_check_symbol(mail_newbody _cclient_sanity_check)

if(NOT _cclient_sanity_check)
  string(
    APPEND _reason_failure_message
    "\n    Sanity check failed. The mail_newbody() could not be found in the "
    "C-client library. Please check CMake logs."
  )
endif()

################################################################################
# Handle package arguments.
################################################################################

find_package_handle_standard_args(
  CClient
  REQUIRED_VARS CClient_LIBRARIES CClient_INCLUDE_DIRS _cclient_sanity_check
  ${_cclient_version_argument}
  REASON_FAILURE_MESSAGE "${_reason_failure_message}"
)

unset(_reason_failure_message)
unset(_cclient_version_argument)

################################################################################
# Imported target.
################################################################################

if(CClient_FOUND AND NOT TARGET CClient::CClient)
  add_library(CClient::CClient INTERFACE IMPORTED)

  set_target_properties(CClient::CClient PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${CClient_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${CClient_LIBRARIES}"
  )
endif()
