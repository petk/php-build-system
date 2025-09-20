<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindPCRE.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindPCRE.cmake)

# FindPCRE

Finds the PCRE library:

```cmake
find_package(PCRE [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `PCRE::PCRE` - The package library, if found.

## Result variables

* `PCRE_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `PCRE_VERSION` - The version of package found.

## Cache variables

* `PCRE_INCLUDE_DIR` - Directory containing package library headers.
* `PCRE_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(PCRE)
target_link_libraries(example PRIVATE PCRE::PCRE)
```

## Customizing search locations

To customize where to look for the PCRE package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `PCRE_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/PCRE;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DPCRE_ROOT=/opt/PCRE \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
