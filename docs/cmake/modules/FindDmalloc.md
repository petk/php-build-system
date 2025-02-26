<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindDmalloc.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindDmalloc.cmake)

# FindDmalloc

Find the Dmalloc library.

Module defines the following `IMPORTED` target(s):

* `Dmalloc::Dmalloc` - The package library, if found.

## Result variables

* `Dmalloc_FOUND` - Whether the package has been found.
* `Dmalloc_INCLUDE_DIRS` - Include directories needed to use this package.
* `Dmalloc_LIBRARIES` - Libraries needed to link to the package library.
* `Dmalloc_VERSION` - Package version, if found.

## Cache variables

* `Dmalloc_INCLUDE_DIR` - Directory containing package library headers.
* `Dmalloc_LIBRARY` - The path to the package library.

## Usage

```cmake
# CMakeLists.txt
find_package(Dmalloc)
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
