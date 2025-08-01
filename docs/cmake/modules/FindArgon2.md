<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindArgon2.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindArgon2.cmake)

# FindArgon2

Finds the Argon2 library:

```cmake
find_package(Argon2)
```

## Imported targets

This module defines the following imported targets:

* `Argon2::Argon2` - The package library, if found.

## Result variables

* `Argon2_FOUND` - Whether the package has been found.
* `Argon2_INCLUDE_DIRS` - Include directories needed to use this package.
* `Argon2_LIBRARIES` - Libraries needed to link to the package library.
* `Argon2_VERSION` - Package version, if found.

## Cache variables

* `Argon2_INCLUDE_DIR` - Directory containing package library headers.
* `Argon2_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Argon2)
target_link_libraries(example PRIVATE Argon2::Argon2)
```

## Customizing search locations

To customize where to look for the Argon2 package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `ARGON2_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/Argon2;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DARGON2_ROOT=/opt/Argon2 \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
