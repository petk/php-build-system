<!-- This is auto-generated file. -->
* Source code: [cmake/modules/Findcmocka.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/Findcmocka.cmake)

# Findcmocka

Finds the cmocka library:

```cmake
find_package(cmocka [<version>] [...])
```

This module checks if cmocka library can be found in *config mode*. If cmocka
installation provides its CMake config file, this module returns the results
without further action. If the upstream config file is not found, this module
falls back to *module mode* and searches standard locations.

## Imported targets

This module provides the following imported targets:

* `cmocka::cmocka` - Target encapsulating the package usage requirements,
  available if package was found.

## Result variables

This module defines the following variables:

* `cmocka_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `cmocka_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `cmocka_INCLUDE_DIR` - Directory containing package library headers. This
  variable is only available when cmocka is found in *module mode*.
* `cmocka_LIBRARY` - The path to the package library. This
  variable is only available when cmocka is found in *module mode*.

# Hints

This module accepts the following variables before calling
`find_package(cmocka)`:

* `cmocka_NO_CMOCKA_CMAKE` - Set this variable to boolean true to disable
  searching for cmocka via *config mode*.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(cmocka)
target_link_libraries(example PRIVATE cmocka::cmocka)
```

## Customizing search locations

To customize where to look for the cmocka package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `CMOCKA_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/cmocka;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMOCKA_ROOT=/opt/cmocka \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
