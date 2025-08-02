<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindApache.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindApache.cmake)

# FindApache

Finds the Apache packages and tools:

```cmake
find_package(Apache [<version>] [...])
```

The Apache development package usually contains Apache header files, the `apr`
(Apache Portable Runtime) library and its headers, `apr` config command-line
tool, and the `apxs` command-line tool.

## Imported targets

This module defines the following imported targets:

* `Apache::Apache` - The package library, if found.

## Result variables

* `Apache_FOUND` - Boolean indicating whether the package is found.
* `Apache_VERSION` - The version of package found.
* `Apache_THREADED` - Whether Apache requires thread safety.
* `Apache_LIBEXECDIR` - Path to the directory containing all Apache modules and
  `httpd.exp` file (list of exported symbols).

## Cache variables

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

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Apache)
target_link_libraries(example PRIVATE Apache::Apache)
```

## Customizing search locations

To customize where to look for the Apache package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `APACHE_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/Apache;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DAPACHE_ROOT=/opt/Apache \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
