# PHP/SAPIs

See: [SAPIs.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/PHP/SAPIs.cmake)

Add subdirectories of PHP SAPIs via `add_subdirectory()`.

This module is responsible for traversing `CMakeLists.txt` files of PHP SAPIs
and adding them via `add_subdirectory()`.

## Exposed macro

```cmake
php_sapis_add(subdirectory)
```

## Custom CMake properties

* `PHP_ALL_SAPIS`

  Global property with a list of all PHP SAPIs in the sapi directory.

* `PHP_SAPIS`

  This global property contains a list of all enabled PHP SAPIs for the current
  configuration.
