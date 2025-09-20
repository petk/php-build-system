<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/SystemExtensions.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/SystemExtensions.cmake)

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
