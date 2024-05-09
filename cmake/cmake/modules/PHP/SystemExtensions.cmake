#[=============================================================================[
Enable extensions to C or Posix on systems that by default disable them to
conform to standards or namespace issues.

Usage:

  - Include the module: "include(PHP/SystemExtensions)"
  - Add @PHP_SYSTEM_EXTENSIONS@ placeholder to configuration header template,
    which will be replaced with required system extensions definitions.

IMPORTED target:

  PHP::SystemExtensions
    Interface library target with all required compile definitions (-D).

    When check requires _GNU_SOURCE or other extensions:
      cmake_push_check_state(RESET)
        set(CMAKE_REQUIRED_LIBRARIES PHP::SystemExtensions)
        check_symbol_exists(<symbol> <headers> HAVE_<symbol>)
      cmake_pop_check_state()

    Linking to targets that require system extensions:
      target_link_libraries(<target> ... PHP::SystemExtensions)

Logic here closely follows the Autoconf's AC_USE_SYSTEM_EXTENSIONS macro with
some simplifications for the obsolete systems. See:
https://www.gnu.org/software/autoconf/manual/autoconf-2.72/html_node/C-and-Posix-Variants.html

Obsolete preprocessor macros that are not defined by this module:

  _MINIX
  _POSIX_SOURCE
  _POSIX_1_SOURCE

Compile definitions are not appended to CMAKE_C_FLAGS for cleaner build system:
  string(APPEND CMAKE_C_FLAGS " -D<extension>=1 ")
]=============================================================================]#

include_guard(GLOBAL)

include(CheckIncludeFile)
include(CheckSourceCompiles)
include(CMakePushCheckState)

message(CHECK_START "Enabling C and POSIX extensions")

add_library(PHP::SystemExtensions INTERFACE IMPORTED)

################################################################################
# The following extensions are always enabled unconditionally.
################################################################################

target_compile_definitions(
  PHP::SystemExtensions
  INTERFACE
    _ALL_SOURCE=1
    _DARWIN_C_SOURCE=1
    _GNU_SOURCE=1
    _HPUX_ALT_XOPEN_SOCKET_API=1
    _NETBSD_SOURCE=1
    _OPENBSD_SOURCE=1
    _POSIX_PTHREAD_SEMANTICS=1
    _TANDEM_SOURCE=1
    __STDC_WANT_IEC_60559_ATTRIBS_EXT__=1
    __STDC_WANT_IEC_60559_BFP_EXT__=1
    __STDC_WANT_IEC_60559_DFP_EXT__=1
    __STDC_WANT_IEC_60559_EXT__=1
    __STDC_WANT_IEC_60559_FUNCS_EXT__=1
    __STDC_WANT_IEC_60559_TYPES_EXT__=1
    __STDC_WANT_LIB_EXT2__=1
    __STDC_WANT_MATH_SPEC_FUNCS__=1
)

################################################################################
# Check whether to enable __EXTENSIONS__.
################################################################################

cmake_push_check_state(RESET)
  cmake_language(GET_MESSAGE_LOG_LEVEL log_level)
  if(NOT log_level MATCHES "^(VERBOSE|DEBUG|TRACE)$")
    set(CMAKE_REQUIRED_QUIET TRUE)
  endif()

  check_include_file(strings.h HAVE_STRINGS_H)
  check_include_file(sys/types.h HAVE_SYS_TYPES_H)
  check_include_file(sys/stat.h HAVE_SYS_STAT_H)
  check_include_file(unistd.h HAVE_UNISTD_H)

  if(HAVE_STRINGS_H)
    list(APPEND CMAKE_REQUIRED_DEFINITIONS -DHAVE_STRINGS_H)
  endif()

  if(HAVE_SYS_TYPES_H)
    list(APPEND CMAKE_REQUIRED_DEFINITIONS -DHAVE_SYS_TYPES_H)
  endif()

  if(HAVE_SYS_STAT_H)
    list(APPEND CMAKE_REQUIRED_DEFINITIONS -DHAVE_SYS_STAT_H)
  endif()

  if(HAVE_UNISTD_H)
    list(APPEND CMAKE_REQUIRED_DEFINITIONS -DHAVE_UNISTD_H)
  endif()

  # Defining __EXTENSIONS__ may break the system headers on some old systems.
  # This check is mostly obsolete and is left here only for compliance with
  # Autotools build system logic in Autoconf 2.72.
  check_source_compiles(C [[
    #define __EXTENSIONS__ 1
    #include <stddef.h>
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <inttypes.h>
    #include <stdint.h>
    #ifdef HAVE_STRINGS_H
    # include <strings.h>
    #endif
    #ifdef HAVE_SYS_TYPES_H
    # include <sys/types.h>
    #endif
    #ifdef HAVE_SYS_STAT_H
    # include <sys/stat.h>
    #endif
    #ifdef HAVE_UNISTD_H
    # include <unistd.h>
    #endif
    int main(void) { return 0; }
  ]] __EXTENSIONS__)
cmake_pop_check_state()

if(__EXTENSIONS__)
  target_compile_definitions(
    PHP::SystemExtensions
    INTERFACE
      __EXTENSIONS__=1
  )
endif()

################################################################################
# Check whether to enable _XOPEN_SOURCE.
################################################################################

# HP-UX 11.11 didn't define mbstate_t without setting _XOPEN_SOURCE. This is
# set conditionally, because BSD-based systems might have issues with this.
if(CMAKE_SYSTEM_NAME STREQUAL "HP-UX")
  # Reset any possible previous value.
  unset(_XOPEN_SOURCE)

  cmake_push_check_state(RESET)
    cmake_language(GET_MESSAGE_LOG_LEVEL log_level)
    if(NOT log_level MATCHES "^(VERBOSE|DEBUG|TRACE)$")
      set(CMAKE_REQUIRED_QUIET TRUE)
    endif()

    check_source_compiles(C [[
      #include <wchar.h>
      mbstate_t x;
      int main(void) { return 0; }
    ]] _HAVE_MBSTATE_T)

    if(NOT _HAVE_MBSTATE_T)
      check_source_compiles(C [[
        #define _XOPEN_SOURCE 500
        #include <wchar.h>
        mbstate_t x;
        int main(void) { return 0; }
      ]] _HAVE_MBSTATE_T_WITH_XOPEN_SOURCE)

      if(_HAVE_MBSTATE_T_WITH_XOPEN_SOURCE)
        set(_XOPEN_SOURCE 500)

        target_compile_definitions(
          PHP::SystemExtensions
          INTERFACE
            _XOPEN_SOURCE=${_XOPEN_SOURCE}
        )
      endif()
    endif()
  cmake_pop_check_state()
endif()

################################################################################
# Configuration header template.
################################################################################

set(PHP_SYSTEM_EXTENSIONS [[
/* Enable extensions on AIX, Interix, z/OS.  */
#ifndef _ALL_SOURCE
# define _ALL_SOURCE 1
#endif
/* Enable general extensions on macOS.  */
#ifndef _DARWIN_C_SOURCE
# define _DARWIN_C_SOURCE 1
#endif
/* Enable general extensions on Solaris.  */
#ifndef __EXTENSIONS__
# cmakedefine __EXTENSIONS__ 1
#endif
/* Enable GNU extensions on systems that have them.  */
#ifndef _GNU_SOURCE
# define _GNU_SOURCE 1
#endif
/* Enable X/Open compliant socket functions that do not require linking
   with -lxnet on HP-UX 11.11.  */
#ifndef _HPUX_ALT_XOPEN_SOCKET_API
# define _HPUX_ALT_XOPEN_SOCKET_API 1
#endif
/* Enable general extensions on NetBSD.
   Enable NetBSD compatibility extensions on Minix.  */
#ifndef _NETBSD_SOURCE
# define _NETBSD_SOURCE 1
#endif
/* Enable OpenBSD compatibility extensions on NetBSD.
   Oddly enough, this does nothing on OpenBSD.  */
#ifndef _OPENBSD_SOURCE
# define _OPENBSD_SOURCE 1
#endif
/* Enable POSIX-compatible threading on Solaris.  */
#ifndef _POSIX_PTHREAD_SEMANTICS
# define _POSIX_PTHREAD_SEMANTICS 1
#endif
/* Enable extensions specified by ISO/IEC TS 18661-5:2014.  */
#ifndef __STDC_WANT_IEC_60559_ATTRIBS_EXT__
# define __STDC_WANT_IEC_60559_ATTRIBS_EXT__ 1
#endif
/* Enable extensions specified by ISO/IEC TS 18661-1:2014.  */
#ifndef __STDC_WANT_IEC_60559_BFP_EXT__
# define __STDC_WANT_IEC_60559_BFP_EXT__ 1
#endif
/* Enable extensions specified by ISO/IEC TS 18661-2:2015.  */
#ifndef __STDC_WANT_IEC_60559_DFP_EXT__
# define __STDC_WANT_IEC_60559_DFP_EXT__ 1
#endif
/* Enable extensions specified by C23 Annex F.  */
#ifndef __STDC_WANT_IEC_60559_EXT__
# define __STDC_WANT_IEC_60559_EXT__ 1
#endif
/* Enable extensions specified by ISO/IEC TS 18661-4:2015.  */
#ifndef __STDC_WANT_IEC_60559_FUNCS_EXT__
# define __STDC_WANT_IEC_60559_FUNCS_EXT__ 1
#endif
/* Enable extensions specified by C23 Annex H and ISO/IEC TS 18661-3:2015.  */
#ifndef __STDC_WANT_IEC_60559_TYPES_EXT__
# define __STDC_WANT_IEC_60559_TYPES_EXT__ 1
#endif
/* Enable extensions specified by ISO/IEC TR 24731-2:2010.  */
#ifndef __STDC_WANT_LIB_EXT2__
# define __STDC_WANT_LIB_EXT2__ 1
#endif
/* Enable extensions specified by ISO/IEC 24747:2009.  */
#ifndef __STDC_WANT_MATH_SPEC_FUNCS__
# define __STDC_WANT_MATH_SPEC_FUNCS__ 1
#endif
/* Enable extensions on HP NonStop.  */
#ifndef _TANDEM_SOURCE
# define _TANDEM_SOURCE 1
#endif
/* Enable X/Open extensions.  Define to 500 only if necessary
   to make mbstate_t available.  */
#ifndef _XOPEN_SOURCE
# cmakedefine _XOPEN_SOURCE @_XOPEN_SOURCE@
#endif]])

string(CONFIGURE "${PHP_SYSTEM_EXTENSIONS}" PHP_SYSTEM_EXTENSIONS)

unset(_XOPEN_SOURCE)

message(CHECK_PASS "done")
