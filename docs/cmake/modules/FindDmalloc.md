<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindDmalloc.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindDmalloc.cmake)

# FindDmalloc

Finds the Dmalloc library:

```cmake
find_package(Dmalloc)
```

## Imported targets

This module provides the following imported targets:

* `Dmalloc::Dmalloc` - The package library, if found.

## Result variables

This module defines the following variables:

* `Dmalloc_FOUND` - Boolean indicating whether (the requested version of)
  package was found.
* `Dmalloc_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `Dmalloc_INCLUDE_DIR` - Directory containing package library headers.
* `Dmalloc_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Dmalloc)
target_link_libraries(example PRIVATE Dmalloc::Dmalloc)
```

## Customizing search locations

To customize where to look for the Dmalloc package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `DMALLOC_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/Dmalloc;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DDMALLOC_ROOT=/opt/Dmalloc \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
