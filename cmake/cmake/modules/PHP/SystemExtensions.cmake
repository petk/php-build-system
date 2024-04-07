#[=============================================================================[
Enable extensions to C or Posix on systems that by default disable them to
conform to standards or namespace issues.

Usage:

  - Include the module: "include(PHP/SystemExtensions)"
  - Add @PHP_SYSTEM_EXTENSIONS@ placeholder to configuration header template,
    which will be replaced with required system extensions definitions.

INTERFACE library:

  PHP::SystemExtensions
    Interface library target with all required compile defintions for usage in
    CMake checks where needed.

Logic here closely follows the Autoconf's AC_USE_SYSTEM_EXTENSIONS macro with
some simplifications for the obsolete systems. See:
https://www.gnu.org/software/autoconf/manual/autoconf-2.72/html_node/C-and-Posix-Variants.html

Obsolete preprocessor macros that are not defined by this module:

  _MINIX
  _POSIX_SOURCE
  _POSIX_1_SOURCE
]=============================================================================]#

include_guard(GLOBAL)

include(CheckIncludeFile)
include(CheckSourceCompiles)
include(CMakePushCheckState)

################################################################################
# The following variables are always defined unconditionally.
################################################################################

set(
  extensions
    _GNU_SOURCE
    _DARWIN_C_SOURCE
    _NETBSD_SOURCE
    _OPENBSD_SOURCE
    _ALL_SOURCE
    _TANDEM_SOURCE
    _POSIX_PTHREAD_SEMANTICS
    __STDC_WANT_IEC_60559_ATTRIBS_EXT__
    __STDC_WANT_IEC_60559_BFP_EXT__
    __STDC_WANT_IEC_60559_EXT__
    __STDC_WANT_IEC_60559_FUNCS_EXT__
    __STDC_WANT_IEC_60559_DFP_EXT__
    __STDC_WANT_IEC_60559_TYPES_EXT__
    __STDC_WANT_LIB_EXT2__
    __STDC_WANT_MATH_SPEC_FUNCS__
    _HPUX_ALT_XOPEN_SOCKET_API
)

################################################################################
# The following variables are defined based on platform and other checks.
################################################################################

check_include_file(strings.h HAVE_STRINGS_H)
check_include_file(sys/types.h HAVE_SYS_TYPES_H)
check_include_file(sys/stat.h HAVE_SYS_STAT_H)
check_include_file(unistd.h HAVE_UNISTD_H)

cmake_push_check_state(RESET)
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
  list(APPEND extensions __EXTENSIONS__)
endif()

################################################################################
# Configuration header template.
################################################################################

set(PHP_SYSTEM_EXTENSIONS [[
/* Enable extensions on AIX, Interix, z/OS.  */
#ifndef _ALL_SOURCE
# cmakedefine _ALL_SOURCE 1
#endif
/* Enable general extensions on macOS.  */
#ifndef _DARWIN_C_SOURCE
# cmakedefine _DARWIN_C_SOURCE 1
#endif
/* Enable general extensions on Solaris.  */
#ifndef __EXTENSIONS__
# cmakedefine __EXTENSIONS__ 1
#endif
/* Enable GNU extensions on systems that have them.  */
#ifndef _GNU_SOURCE
# cmakedefine _GNU_SOURCE 1
#endif
/* Enable X/Open compliant socket functions that do not require linking
   with -lxnet on HP-UX 11.11.  */
#ifndef _HPUX_ALT_XOPEN_SOCKET_API
# cmakedefine _HPUX_ALT_XOPEN_SOCKET_API 1
#endif
/* Enable general extensions on NetBSD.
   Enable NetBSD compatibility extensions on Minix.  */
#ifndef _NETBSD_SOURCE
# cmakedefine _NETBSD_SOURCE 1
#endif
/* Enable OpenBSD compatibility extensions on NetBSD.
   Oddly enough, this does nothing on OpenBSD.  */
#ifndef _OPENBSD_SOURCE
# cmakedefine _OPENBSD_SOURCE 1
#endif
/* Enable POSIX-compatible threading on Solaris.  */
#ifndef _POSIX_PTHREAD_SEMANTICS
# cmakedefine _POSIX_PTHREAD_SEMANTICS 1
#endif
/* Enable extensions specified by ISO/IEC TS 18661-5:2014.  */
#ifndef __STDC_WANT_IEC_60559_ATTRIBS_EXT__
# cmakedefine __STDC_WANT_IEC_60559_ATTRIBS_EXT__ 1
#endif
/* Enable extensions specified by ISO/IEC TS 18661-1:2014.  */
#ifndef __STDC_WANT_IEC_60559_BFP_EXT__
# cmakedefine __STDC_WANT_IEC_60559_BFP_EXT__ 1
#endif
/* Enable extensions specified by ISO/IEC TS 18661-2:2015.  */
#ifndef __STDC_WANT_IEC_60559_DFP_EXT__
# cmakedefine __STDC_WANT_IEC_60559_DFP_EXT__ 1
#endif
/* Enable extensions specified by C23 Annex F.  */
#ifndef __STDC_WANT_IEC_60559_EXT__
# cmakedefine __STDC_WANT_IEC_60559_EXT__ 1
#endif
/* Enable extensions specified by ISO/IEC TS 18661-4:2015.  */
#ifndef __STDC_WANT_IEC_60559_FUNCS_EXT__
# cmakedefine __STDC_WANT_IEC_60559_FUNCS_EXT__ 1
#endif
/* Enable extensions specified by C23 Annex H and ISO/IEC TS 18661-3:2015.  */
#ifndef __STDC_WANT_IEC_60559_TYPES_EXT__
# cmakedefine __STDC_WANT_IEC_60559_TYPES_EXT__ 1
#endif
/* Enable extensions specified by ISO/IEC TR 24731-2:2010.  */
#ifndef __STDC_WANT_LIB_EXT2__
# cmakedefine __STDC_WANT_LIB_EXT2__ 1
#endif
/* Enable extensions specified by ISO/IEC 24747:2009.  */
#ifndef __STDC_WANT_MATH_SPEC_FUNCS__
# cmakedefine __STDC_WANT_MATH_SPEC_FUNCS__ 1
#endif
/* Enable extensions on HP NonStop.  */
#ifndef _TANDEM_SOURCE
# cmakedefine _TANDEM_SOURCE 1
#endif
/* Enable X/Open extensions.  Define to 500 only if necessary
   to make mbstate_t available.  */
#ifndef _XOPEN_SOURCE
# cmakedefine _XOPEN_SOURCE 1
#endif
]])

add_library(php_system_extensions INTERFACE IMPORTED)
add_library(PHP::SystemExtensions ALIAS php_system_extensions)

block(PROPAGATE PHP_SYSTEM_EXTENSIONS)
  foreach(extension ${extensions})
    set(${extension} 1)
    # TODO: Appending compile definitions to CMAKE_C_FLAGS is disabled for now:
    #string(APPEND CMAKE_C_FLAGS " -D${extension}=1 ")
    target_compile_definitions(
      php_system_extensions
      INTERFACE
        ${extension}=1
    )
  endforeach()

  string(CONFIGURE "${PHP_SYSTEM_EXTENSIONS}" PHP_SYSTEM_EXTENSIONS)
endblock()

unset(extensions)
