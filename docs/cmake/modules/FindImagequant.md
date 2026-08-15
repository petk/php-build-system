<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindImagequant.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindImagequant.cmake)

# FindImagequant

Finds the Imagequant library (libimagequant):

```cmake
find_package(Imagequant [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `Imagequant::Imagequant` - Target encapsulating the package usage
  requirements, available if package was found.

## Result variables

This module defines the following variables:

* `Imagequant_FOUND` - Boolean indicating whether (the requested version of)
  package was found.
* `Imagequant_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `Imagequant_INCLUDE_DIR` - Directory containing package library headers.
* `Imagequant_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Imagequant)
target_link_libraries(example PRIVATE Imagequant::Imagequant)
```

## Customizing search locations

To customize where to look for the Imagequant package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `IMAGEQUANT_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/Imagequant;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DIMAGEQUANT_ROOT=/opt/Imagequant \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
