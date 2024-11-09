# FindODBC

See: [FindODBC.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/FindODBC.cmake)

Find the ODBC library.

This module is based on the upstream
[FindODBC](https://cmake.org/cmake/help/latest/module/FindODBC.html) with some
enhancements and adjustments for the PHP build workflow.

Modifications from upstream:

* Additional result variables:

  * `ODBC_DRIVER`

    Name of the found driver, if any. For example, `unixODBC`, `iODBC`.

  * `ODBC_VERSION`

    Version of the found ODBC library if it was retrieved from config utilities.

* Additional cache variables:

  * `ODBC_COMPILE_DEFINITIONS` - a `;`-list of compile definitions.
  * `ODBC_COMPILE_OPTIONS` - a `;`-list of compile options.
  * `ODBC_LINK_OPTIONS` - a `;`-list of linker options.

* Additional hints:

  * `ODBC_USE_DRIVER`

    Set to `unixODBC` or `iODBC` to limit searching for specific ODBC driver
    instead of any driver.

* Added pkg-config integration.

* Fixed limitation where the upstream module can't (yet) select which specific
  ODBC driver to use. Except on Windows, where the driver searching is the same
  as upstream.

* Added package meta-data for FeatureSummary.
