<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindACL.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindACL.cmake)

# FindACL

Finds the ACL library:

```cmake
find_package(ACL [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `ACL::ACL` - The package library, if found.

## Result variables

This module defines the following variables:

* `ACL_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `ACL_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `ACL_IS_BUILT_IN` - Whether ACL is a part of the C library (for example, on
  BSD-based systems).
* `ACL_INCLUDE_DIR` - Directory containing package library headers.
* `ACL_LIBRARY` - The path to the package library.

## Hints

This module accepts the following variables before calling `find_package(ACL)`:

* `ACL_USE_USER_GROUP` - When set to boolean true a check is performed whether
  the ACL library supports `ACL_USER` and `ACL_GROUP`. For example, macOS
  doesn't have support for user/group.

## Examples

### Example: Basic usage

Finding ACL library and linking its imported target to the project target:

```cmake
# CMakeLists.txt
find_package(ACL)
target_link_libraries(example PRIVATE ACL::ACL)
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
