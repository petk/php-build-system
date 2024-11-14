# FindPHPSystem

See: [FindPHPSystem.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindPHPSystem.cmake)

## Basic usage

```cmake
include(cmake/FindPHPSystem.cmake)
```

Find external PHP on the system, if installed.

Result variables:

* `PHPSystem_FOUND` - Whether the package has been found.
* `PHPSystem_VERSION` - Package version, if found.

Cache variables:

* `PHPSystem_EXECUTABLE` - PHP command-line tool, if available.

Hints:

The `PHPSystem_ROOT` variable adds custom search path.
