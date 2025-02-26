<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindPCRE.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindPCRE.cmake)

# FindPCRE

Find the PCRE library.

Module defines the following `IMPORTED` target(s):

* `PCRE::PCRE` - The package library, if found.

## Result variables

* `PCRE_FOUND` - Whether the package has been found.
* `PCRE_INCLUDE_DIRS` - Include directories needed to use this package.
* `PCRE_LIBRARIES` - Libraries needed to link to the package library.
* `PCRE_VERSION` - Package version, if found.

## Cache variables

* `PCRE_INCLUDE_DIR` - Directory containing package library headers.
* `PCRE_LIBRARY` - The path to the package library.

## Usage

```cmake
# CMakeLists.txt
find_package(PCRE)
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
