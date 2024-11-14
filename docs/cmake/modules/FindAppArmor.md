# FindAppArmor

See: [FindAppArmor.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindAppArmor.cmake)

## Basic usage

```cmake
find_package(AppArmor)
```

Find the AppArmor library.

Module defines the following `IMPORTED` target(s):

* `AppArmor::AppArmor` - The package library, if found.

Result variables:

* `AppArmor_FOUND` - Whether the package has been found.
* `AppArmor_INCLUDE_DIRS` - Include directories needed to use this package.
* `AppArmor_LIBRARIES` - Libraries needed to link to the package library.
* `AppArmor_VERSION` - Package version, if found.

Cache variables:

* `AppArmor_INCLUDE_DIR` - Directory containing package library headers.
* `AppArmor_LIBRARY` - The path to the package library.

Hints:

The `AppArmor_ROOT` variable adds custom search path.
