<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindAppArmor.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindAppArmor.cmake)

# FindAppArmor

Finds the AppArmor library:

```cmake
find_package(AppArmor [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `AppArmor::AppArmor` - The package library, if found.

## Result variables

* `AppArmor_FOUND` - Boolean indicating whether (the requested version of)
  package was found.
* `AppArmor_VERSION` - The version of package found.

## Cache variables

* `AppArmor_INCLUDE_DIR` - Directory containing package library headers.
* `AppArmor_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(AppArmor)
target_link_libraries(example PRIVATE AppArmor::AppArmor)
```

## Customizing search locations

To customize where to look for the AppArmor package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `APPARMOR_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/AppArmor;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DAPPARMOR_ROOT=/opt/AppArmor \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
