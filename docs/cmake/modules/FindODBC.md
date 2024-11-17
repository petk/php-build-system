<!-- This is auto-generated file. -->
# FindODBC

* Module source code: [FindODBC.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindODBC.cmake)

Find the ODBC library.

This module is based on the upstream
[FindODBC](https://cmake.org/cmake/help/latest/module/FindODBC.html) with some
enhancements and adjustments for the PHP build workflow.

Modifications from upstream:

* Additional result variables:

  * `ODBC_DRIVER`

    Name of the found driver, if any. For example, `unixODBC`, `iODBC`. On
    Windows in MinGW environment it is set to `unixODBC`, and to `Windows` for
    the rest of the Windows system.

  * `ODBC_VERSION`

    Version of the found ODBC library if it was retrieved from config utilities.

* Additional cache variables:

  * `ODBC_COMPILE_DEFINITIONS`

    A `;`-list of compile definitions.

  * `ODBC_COMPILE_OPTIONS`

    A `;`-list of compile options.

  * `ODBC_LINK_OPTIONS`

    A `;`-list of linker options.

  * `ODBC_LIBRARY_DIR`

    The path to the ODBC library directory that contains the ODBC library.

* Additional hints:

  * `ODBC_USE_DRIVER`

    Set to `unixODBC` or `iODBC` to limit searching for specific ODBC driver
    instead of any driver. On Windows, the searched driver will be the core ODBC
    Windows implementation only. On Windows in MinGW environment, there is at
    the time of writing `unixODBC` implementation available in the default
    MinGW installation and as a standalone package. The driver name is
    case-insensitive and if supported it will be adjusted to the expected case.

* Added pkg-config integration.

* Fixed limitation where the upstream module can't (yet) select which specific
  ODBC driver to use.

* Added package meta-data for FeatureSummary.

* Fixed finding ODBC on Windows and MinGW.

## Basic usage

```cmake
# CMakeLists.txt
find_package(ODBC)
```

## Customizing search locations

To customize where to look for the ODBC package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `ODBC_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> -B <build-dir> -DCMAKE_PREFIX_PATH="/opt/ODBC;/opt/some-other-package"
# or
cmake -S <source-dir> \
    -B <build-dir> \
    -DODBC_ROOT=/opt/ODBC \
    -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
