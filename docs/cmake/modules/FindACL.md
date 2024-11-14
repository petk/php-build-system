# FindACL

See: [FindACL.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindACL.cmake)

## Basic usage

```cmake
include(cmake/FindACL.cmake)
```

Find the ACL library.

Module defines the following `IMPORTED` target(s):

* `ACL::ACL` - The package library, if found.

Result variables:

* `ACL_FOUND` - Whether the package has been found.
* `ACL_INCLUDE_DIRS` - Include directories needed to use this package.
* `ACL_LIBRARIES` - Libraries needed to link to the package library.
* `ACL_VERSION` - Package version, if found.

Cache variables:

* `ACL_IS_BUILT_IN` - Whether ACL is a part of the C library (BSD-based
  systems).
* `ACL_INCLUDE_DIR` - Directory containing package library headers.
* `ACL_LIBRARY` - The path to the package library.

Hints:

The `ACL_ROOT` variable adds custom search path.

Set `ACL_USE_USER_GROUP` to `TRUE` before calling `find_package(ACL)` to also
check if the ACL library supports `ACL_USER` and `ACL_GROUP`. For example, macOS
doesn't have support for user/group.
