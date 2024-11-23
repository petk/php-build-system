<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindACL.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindACL.cmake)

# FindACL

Find the ACL library.

Module defines the following `IMPORTED` target(s):

* `ACL::ACL` - The package library, if found.

## Result variables

* `ACL_FOUND` - Whether the package has been found.
* `ACL_INCLUDE_DIRS` - Include directories needed to use this package.
* `ACL_LIBRARIES` - Libraries needed to link to the package library.
* `ACL_VERSION` - Package version, if found.

## Cache variables

* `ACL_IS_BUILT_IN` - Whether ACL is a part of the C library (BSD-based
  systems).
* `ACL_INCLUDE_DIR` - Directory containing package library headers.
* `ACL_LIBRARY` - The path to the package library.

## Hints

* Set `ACL_USE_USER_GROUP` to `TRUE` before calling `find_package(ACL)` to also
  check if the ACL library supports `ACL_USER` and `ACL_GROUP`. For example,
  macOS doesn't have support for user/group.

## Basic usage

```cmake
# CMakeLists.txt
find_package(ACL)
```

## Customizing search locations

To customize where to look for the ACL package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `ACL_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/ACL;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DACL_ROOT=/opt/ACL \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
