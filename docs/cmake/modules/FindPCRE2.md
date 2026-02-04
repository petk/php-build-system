<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindPCRE2.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindPCRE2.cmake)

# FindPCRE2

Finds the PCRE library:

```cmake
find_package(PCRE2 [<version>] [...])
```

This module checks if PCRE library can be found in *config mode*. If PCRE
installation provides its CMake config file, this module returns the results
without further action. If the upstream config file is not found, this module
falls back to *module mode* and searches standard locations.

## Imported targets

This module provides the following imported targets:

* `PCRE2::8BIT` - The package library, if found.

## Result variables

This module defines the following variables:

* `PCRE2_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `PCRE2_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `PCRE2_INCLUDE_DIR` - Directory containing package library headers.
* `PCRE2_LIBRARY` - The path to the package library.

## Hints

This module accepts the following variables before calling
`find_package(PCRE2)`:

* `PCRE2_USE_STATIC_LIBS` - Set this variable to boolean true to search for
  static libraries.

* `PCRE2_NO_PCRE2_CMAKE` - Set this variable to boolean true to disable
  searching for PCRE via *config mode*.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(PCRE2)
target_link_libraries(example PRIVATE PCRE2::8BIT)
```

## Customizing search locations

To customize where to look for the PCRE2 package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `PCRE2_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/PCRE2;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DPCRE2_ROOT=/opt/PCRE2 \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
