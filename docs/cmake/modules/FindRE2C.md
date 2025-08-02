<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindRE2C.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindRE2C.cmake)

# FindRE2C

Finds the `re2c` command-line lexer generator:

```cmake
find_package(RE2C [<version>] [...])
```

## Result variables

* `RE2C_FOUND` - Whether the `re2c` was found.
* `RE2C_VERSION` - The `re2c` version.

## Cache variables

* `RE2C_EXECUTABLE` - Path to the `re2c` executable.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(RE2C)
```

## Customizing search locations

To customize where to look for the RE2C package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `RE2C_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/RE2C;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DRE2C_ROOT=/opt/RE2C \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
