# FindApache

See: [FindApache.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindApache.cmake)

## Basic usage

```cmake
find_package(Apache)
```

Find the Apache packages and tools.

The Apache development package usually contains Apache header files, the `apr`
(Apache Portable Runtime) library and its headers, `apr` config command-line
tool, and the `apxs` command-line tool.

Module defines the following `IMPORTED` target(s):

* `Apache::Apache` - The package library, if found.

Result variables:

* `Apache_FOUND` - Whether the package has been found.
* `Apache_INCLUDE_DIRS` - Include directories needed to use this package.
* `Apache_LIBRARIES` - Libraries needed to link to the package library.
* `Apache_VERSION` - Package version, if found.
* `Apache_THREADED` - Whether Apache requires thread safety.
* `Apache_LIBEXECDIR` - Path to the directory containing all Apache modules and
  `httpd.exp` file (list of exported symbols).

Cache variables:

* `Apache_APXS_EXECUTABLE` - Path to the APache eXtenSion tool command-line tool
  (`apxs`).
* `Apache_APXS_DEFINITIONS` - A list of compile definitions (`-D`) from the
  `apxs -q CFLAGS` query string.
* `Apache_APR_CONFIG_EXECUTABLE` - Path to the `apr` library command-line
  configuration tool.
* `Apache_APR_CPPFLAGS` - A list of C preprocessor flags for the `apr` library.
* `Apache_APU_CONFIG_EXECUTABLE` - Path to the Apache Portable Runtime Utilities
  config command-line tool.
* `Apache_EXECUTABLE` - Path to the Apache command-line server program.
* `Apache_INCLUDE_DIR` - Directory containing package library headers.
* `Apache_APR_INCLUDE_DIR` - Directory containing `apr` library headers.
* `Apache_APR_LIBRARY` - The path to the `apr` library.

Hints:

The `Apache_ROOT` variable adds custom search path.
