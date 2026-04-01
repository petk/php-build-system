<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindMPIR.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindMPIR.cmake)

# FindMPIR

Finds the MPIR library with GMP compatibility:

```cmake
find_package(MPIR [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `MPIR::MPIR` - The package library, if found.

## Result variables

This module defines the following variables:

* `MPIR_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `MPIR_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `MPIR_INCLUDE_DIR` - Directory containing package library headers.
* `MPIR_LIBRARY` - The path to the package library.

## Hints

This module accepts the following variables before calling
`find_package(MPIR)`:

* `MPIR_USE_STATIC_LIBS` - Set this variable to boolean true to search for
  static libraries.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(MPIR)
target_link_libraries(example PRIVATE MPIR::MPIR)
```

## Customizing search locations

To customize where to look for the MPIR package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `MPIR_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/MPIR;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DMPIR_ROOT=/opt/MPIR \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
