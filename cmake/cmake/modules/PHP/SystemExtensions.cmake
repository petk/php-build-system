#[=============================================================================[
# PHP/SystemExtensions

Enable extensions to C or POSIX on systems that by default disable them to
conform to standards or namespace issues.

Logic follows the Autoconf's `AC_USE_SYSTEM_EXTENSIONS` macro:
https://www.gnu.org/software/autoconf/manual/autoconf-2.72/html_node/C-and-Posix-Variants.html
with some simplifications for the obsolete systems.

Obsolete preprocessor macros that are not defined by this module:

* `_HPUX_ALT_XOPEN_SOCKET_API`
* `_MINIX`
* `_POSIX_1_SOURCE`
* `_POSIX_SOURCE`
* `_XOPEN_SOURCE`

Conditionally defined preprocessor macros:

* `__EXTENSIONS__`

  Defined on Solaris and illumos-based systems.

* `_POSIX_PTHREAD_SEMANTICS`

  Defined on Solaris and illumos-based systems.

  As of Solaris 11.4, the `_POSIX_PTHREAD_SEMANTICS` is obsolete and according
  to documentation no header utilizes this anymore. For illumos-based systems,
  it's unclear where it is still needed, so at the time of writing, this is
  enabled unconditionally for all Solaris and illumos-based systems as enabling
  it doesn't cause issues. For other systems, this is irrelevant.

## Result variables

* `PHP_SYSTEM_EXTENSIONS_CODE`

  The configuration header code containing all system extensions definitions.

## IMPORTED target

* `PHP::SystemExtensions`

  Interface library target with all required compile definitions (`-D`).

## Usage

Targets that require some system extensions can link to `PHP::SystemExtensions`:

```cmake
# CMakeLists.txt
include(PHP/SystemExtensions)
target_link_libraries(<target> PHP::SystemExtensions)
```

When some check requires, for example, `_GNU_SOURCE` or some other extensions,
link the `PHP::SystemExtensions` target:

```cmake
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_LIBRARIES PHP::SystemExtensions)
  check_symbol_exists(<symbol> <headers> HAVE_<symbol>)
cmake_pop_check_state()
```

## Configuration header code

To configure header file, add a placeholder to template, for example:

```c
# config.h.in
@PHP_SYSTEM_EXTENSIONS_CODE@
```

And include module:

```cmake
# CMakeLists.txt
include(PHP/SystemExtensions)
configure_file(config.h.in config.h)
```

## Notes

Compile definitions are not appended to `CMAKE_C_FLAGS` for cleaner build
system. For example, this is not done by this module:

```cmake
string(APPEND CMAKE_C_FLAGS " -D<extension>=1 ")`
```
#]=============================================================================]

# Set configuration header code for consecutive module inclusions, if needed.
if(NOT PHP_SYSTEM_EXTENSIONS_CODE)
  get_property(
    PHP_SYSTEM_EXTENSIONS_CODE
    GLOBAL
    PROPERTY _PHP_SYSTEM_EXTENSIONS_CODE
  )
endif()

include_guard(GLOBAL)

include(CheckIncludeFiles)
include(CheckSourceCompiles)
include(CMakePushCheckState)

message(CHECK_START "Enabling C and POSIX extensions")

add_library(PHP::SystemExtensions INTERFACE IMPORTED GLOBAL)

################################################################################
# The following extensions are always enabled unconditionally.
################################################################################

target_compile_definitions(
  PHP::SystemExtensions
  INTERFACE
    _ALL_SOURCE=1
    _DARWIN_C_SOURCE=1
    _GNU_SOURCE
    _NETBSD_SOURCE=1
    _OPENBSD_SOURCE=1
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
# Check whether to enable __EXTENSIONS__ on Solaris and illumos-based systems.
#
# Defining __EXTENSIONS__ may break the system headers on some obsolete systems.
# Conditional check is obsolete and is left here for compliance with logic in
# Autoconf 2.72+. On current Solaris and illumos-based systems the
# __EXTENSIONS__ can be enabled unconditionally without checking default headers
# compilation.
################################################################################

if(CMAKE_SYSTEM_NAME STREQUAL "SunOS")
  cmake_push_check_state(RESET)
    cmake_language(GET_MESSAGE_LOG_LEVEL log_level)
    if(NOT log_level MATCHES "^(VERBOSE|DEBUG|TRACE)$")
      set(CMAKE_REQUIRED_QUIET TRUE)
    endif()

    check_include_files(strings.h HAVE_STRINGS_H)
    check_include_files(sys/types.h HAVE_SYS_TYPES_H)
    check_include_files(sys/stat.h HAVE_SYS_STAT_H)
    check_include_files(unistd.h HAVE_UNISTD_H)

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

    check_source_compiles(C [[
      #define __EXTENSIONS__
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
    target_compile_definitions(PHP::SystemExtensions INTERFACE __EXTENSIONS__)
  else()
    message(
      WARNING
      "__EXTENSIONS__ could not be enabled because system headers failed to "
      "compile. Please see the CMake configure logs."
    )
  endif()
endif()

################################################################################
# Check whether to enable _POSIX_PTHREAD_SEMANTICS.
################################################################################

if(CMAKE_SYSTEM_NAME STREQUAL "SunOS")
  target_compile_definitions(
    PHP::SystemExtensions
    INTERFACE $<$<COMPILE_LANGUAGE:ASM,C,CXX>:_POSIX_PTHREAD_SEMANTICS>
  )

  set(_POSIX_PTHREAD_SEMANTICS TRUE)
endif()

################################################################################
# Configuration header template.
################################################################################

set(PHP_SYSTEM_EXTENSIONS_CODE [[
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
# cmakedefine __EXTENSIONS__
#endif
/* Enable GNU extensions on systems that have them.  */
#ifndef _GNU_SOURCE
# define _GNU_SOURCE
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
# cmakedefine _POSIX_PTHREAD_SEMANTICS
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
#endif]])

string(CONFIGURE "${PHP_SYSTEM_EXTENSIONS_CODE}" PHP_SYSTEM_EXTENSIONS_CODE)

define_property(
  GLOBAL
  PROPERTY _PHP_SYSTEM_EXTENSIONS_CODE
  BRIEF_DOCS "Configuration header code with system extensions definitions"
)

set_property(
  GLOBAL
  PROPERTY _PHP_SYSTEM_EXTENSIONS_CODE "${PHP_SYSTEM_EXTENSIONS_CODE}"
)

message(CHECK_PASS "done")
