#[=============================================================================[
# PHP/SystemExtensions

This module enables extensions to C or POSIX on systems that by default disable
them to conform to standards or namespace issues.

Load this module in a CMake project with:

```cmake
include(PHP/SystemExtensions)
```

The feature test preprocessor macros, such as `_GNU_SOURCE`, help controlling
how the system symbols declared in system headers behave when a program is
compiled: https://man7.org/linux/man-pages/man7/feature_test_macros.7.html

Logic in this module follows the Autoconf's `AC_USE_SYSTEM_EXTENSIONS` macro:
https://www.gnu.org/software/autoconf/manual/autoconf-2.72/html_node/C-and-Posix-Variants.html
with some simplifications for the obsolete systems.

Obsolete feature test preprocessor macros that are **not** defined by this
module:

* `_HPUX_ALT_XOPEN_SOCKET_API`
* `_MINIX`
* `_POSIX_1_SOURCE`
* `_POSIX_SOURCE`
* `_XOPEN_SOURCE`

Conditionally defined feature test preprocessor macros:

* `_DARWIN_C_SOURCE`

  Defined when the target system is Apple stationary system.

* `__EXTENSIONS__`

  Defined when the target system is Solaris or illumos-based system.

  Defining `__EXTENSIONS__` and including some standard set of system headers
  may cause build failure due to some bugs on some obsolete Solaris systems.
  Autoconf also checks whether `__EXTENSIONS__` can be defined when including
  system headers, however in this module such check is considered obsolete and
  `__EXTENSIONS__` is defined on any Solaris/illumos system without checking
  system headers issues.

* `_POSIX_PTHREAD_SEMANTICS`

  Defined when the target system is Solaris or illumos-based system.

  As of Solaris 11.4, the `_POSIX_PTHREAD_SEMANTICS` is obsolete and according
  to documentation no header utilizes this anymore. For illumos-based systems,
  it is still needed at the time of writing, so it is enabled unconditionally
  for all Solaris and illumos-based systems as enabling it on Solaris 11.4
  doesn't cause issues. On other systems, this preprocessor macro is not needed.

## Result variables

Including this module defines the following variables:

* `PHP_SYSTEM_EXTENSIONS_CODE`

  The configuration header code containing all system extensions definitions.

## Imported target

Including this module provides the following imported targets:

* `PHP::SystemExtensions`

  Interface imported target with all required compile definitions (`-D`).

## Notes

Often times it might make sense to simplify the system extensions usage and
globally define the `_GNU_SOURCE` or some other feature test macro. However,
this module's philosophy is to not append compile definitions to
build-system-wide variables such as `CMAKE_C_FLAGS` for cleaner build system and
clearer understanding of the checks. For example, this is not done by this
module:

```cmake
# CMakeLists.txt
string(APPEND CMAKE_C_FLAGS " -D_GNU_SOURCE=1 ")
```

## Examples

### Example: Basic usage

Targets that require some system extensions can link to `PHP::SystemExtensions`.
For example:

```cmake
# CMakeLists.txt

include(PHP/SystemExtensions)

target_link_libraries(<target> PHP::SystemExtensions)
```

### Example: Configuration checks

When some check requires, for example, `_GNU_SOURCE` or some other extension,
link the `PHP::SystemExtensions` target:

```cmake
include(CheckSymbolExists)
include(CMakePushCheckState)
include(PHP/SystemExtensions)

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_LIBRARIES PHP::SystemExtensions)
  check_symbol_exists(<symbol> <headers> HAVE_<symbol>)
cmake_pop_check_state()
```

### Example: Configuration header

To generate a configuration header with system extensions, add a placeholder to
the template:

```c
// config.h.in
@PHP_SYSTEM_EXTENSIONS_CODE@
```

and in CMake generate the configuration header after including this module:

```cmake
# CMakeLists.txt
include(PHP/SystemExtensions)
configure_file(config.h.in config.h)
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

message(CHECK_START "Enabling C and POSIX extensions")

add_library(PHP::SystemExtensions INTERFACE IMPORTED GLOBAL)

# The following extensions are always enabled unconditionally.
block()
  set(
    definitions
      _ALL_SOURCE=1
      _COSMO_SOURCE
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

  target_compile_definitions(
    PHP::SystemExtensions
    INTERFACE $<$<COMPILE_LANGUAGE:C,CXX>:${definitions}>
  )
endblock()

# Enable _DARWIN_C_SOURCE on Apple stationary systems.
if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  target_compile_definitions(
    PHP::SystemExtensions
    INTERFACE $<$<COMPILE_LANGUAGE:C,CXX>:_DARWIN_C_SOURCE=1>
  )

  set(_DARWIN_C_SOURCE TRUE)
endif()

# Enable __EXTENSIONS__ and _POSIX_PTHREAD_SEMANTICS on Solaris/illumos.
if(CMAKE_SYSTEM_NAME STREQUAL "SunOS")
  target_compile_definitions(
    PHP::SystemExtensions
    INTERFACE $<$<COMPILE_LANGUAGE:C,CXX>:__EXTENSIONS__;_POSIX_PTHREAD_SEMANTICS>
  )

  set(__EXTENSIONS__ TRUE)
  set(_POSIX_PTHREAD_SEMANTICS TRUE)
endif()

# Configuration header code template.
string(CONFIGURE [[
/* Enable extensions on AIX, Interix, z/OS. */
#ifndef _ALL_SOURCE
# define _ALL_SOURCE 1
#endif
/* Enable extensions on Cosmopolitan Libc. */
#ifndef _COSMO_SOURCE
# define _COSMO_SOURCE
#endif
/* Enable general extensions on macOS. */
#ifndef _DARWIN_C_SOURCE
# cmakedefine _DARWIN_C_SOURCE 1
#endif
/* Enable general extensions on Solaris. */
#ifndef __EXTENSIONS__
# cmakedefine __EXTENSIONS__
#endif
/* Enable GNU extensions on systems that have them. */
#ifndef _GNU_SOURCE
# define _GNU_SOURCE
#endif
/* Enable general extensions on NetBSD.
   Enable NetBSD compatibility extensions on Minix. */
#ifndef _NETBSD_SOURCE
# define _NETBSD_SOURCE 1
#endif
/* Enable OpenBSD compatibility extensions on NetBSD.
   Oddly enough, this does nothing on OpenBSD. */
#ifndef _OPENBSD_SOURCE
# define _OPENBSD_SOURCE 1
#endif
/* Enable POSIX-compatible threading on Solaris <= 11.3 and illumos. */
#ifndef _POSIX_PTHREAD_SEMANTICS
# cmakedefine _POSIX_PTHREAD_SEMANTICS
#endif
/* Enable extensions specified by ISO/IEC TS 18661-5:2014. */
#ifndef __STDC_WANT_IEC_60559_ATTRIBS_EXT__
# define __STDC_WANT_IEC_60559_ATTRIBS_EXT__ 1
#endif
/* Enable extensions specified by ISO/IEC TS 18661-1:2014. */
#ifndef __STDC_WANT_IEC_60559_BFP_EXT__
# define __STDC_WANT_IEC_60559_BFP_EXT__ 1
#endif
/* Enable extensions specified by ISO/IEC TS 18661-2:2015. */
#ifndef __STDC_WANT_IEC_60559_DFP_EXT__
# define __STDC_WANT_IEC_60559_DFP_EXT__ 1
#endif
/* Enable extensions specified by C23 Annex F. */
#ifndef __STDC_WANT_IEC_60559_EXT__
# define __STDC_WANT_IEC_60559_EXT__ 1
#endif
/* Enable extensions specified by ISO/IEC TS 18661-4:2015. */
#ifndef __STDC_WANT_IEC_60559_FUNCS_EXT__
# define __STDC_WANT_IEC_60559_FUNCS_EXT__ 1
#endif
/* Enable extensions specified by C23 Annex H and ISO/IEC TS 18661-3:2015. */
#ifndef __STDC_WANT_IEC_60559_TYPES_EXT__
# define __STDC_WANT_IEC_60559_TYPES_EXT__ 1
#endif
/* Enable extensions specified by ISO/IEC TR 24731-2:2010. */
#ifndef __STDC_WANT_LIB_EXT2__
# define __STDC_WANT_LIB_EXT2__ 1
#endif
/* Enable extensions specified by ISO/IEC 24747:2009. */
#ifndef __STDC_WANT_MATH_SPEC_FUNCS__
# define __STDC_WANT_MATH_SPEC_FUNCS__ 1
#endif
/* Enable extensions on HP NonStop. */
#ifndef _TANDEM_SOURCE
# define _TANDEM_SOURCE 1
#endif]] PHP_SYSTEM_EXTENSIONS_CODE)

define_property(
  GLOBAL
  PROPERTY _PHP_SYSTEM_EXTENSIONS_CODE
  BRIEF_DOCS "Configuration header code with system extensions definitions"
)

set_property(
  GLOBAL
  PROPERTY _PHP_SYSTEM_EXTENSIONS_CODE "${PHP_SYSTEM_EXTENSIONS_CODE}"
)

unset(__EXTENSIONS__)
unset(_DARWIN_C_SOURCE)
unset(_POSIX_PTHREAD_SEMANTICS)

message(CHECK_PASS "done")
