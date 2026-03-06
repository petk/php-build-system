#[=============================================================================[
# The zlib extension

This extension provides support for reading and writing gzip (.gz) compressed
files.

## Configuration options

### PHP_EXT_ZLIB

* Default: `OFF`
* Values: `ON|OFF`

Enables the extension.

### PHP_EXT_ZLIB_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Builds extension as shared.

## Examples

Enabling the zlib extension:

```sh
cmake -B <build-dir> -DPHP_EXT_ZLIB=ON
```

Customizing where to find dependencies can be done by setting the
`CMAKE_PREFIX_PATH` variable or by setting the individual `<PackageName>_ROOT`
variables.

For example, to specify custom installations of zlib library:

```sh
cmake \
  -B <build-dir> \
  -DPHP_EXT_ZLIB=ON \
  -DCMAKE_PREFIX_PATH="/path/to/zlib-installation"
```

Or:

```sh
cmake \
  -B <build-dir> \
  -DPHP_EXT_ZLIB=ON \
  -DZLIB_ROOT="/path/to/zlib-installation
```
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

project(
  PHP_EXT_ZLIB
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_ZLIB "Enable the zlib extension")

add_feature_info(
  "ext/zlib"
  PHP_EXT_ZLIB
  "gzip (.gz) compressed archives support"
)

cmake_dependent_option(
  PHP_EXT_ZLIB_SHARED
  "Build the zlib extension as a shared library"
  OFF
  PHP_EXT_ZLIB
  OFF
)

if(NOT PHP_EXT_ZLIB)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(zlib)

if(PHP_EXT_ZLIB_SHARED)
  add_library(php_ext_zlib MODULE)
else()
  add_library(php_ext_zlib OBJECT)
endif()

target_sources(
  php_ext_zlib
  PRIVATE
    zlib_filter.c
    zlib_fopen_wrapper.c
    zlib.c
    zlib.stub.php
)

get_target_property(type php_ext_zlib TYPE)
if(TARGET php_windows AND type MATCHES "^(OBJECT|STATIC)_LIBRARY$")
  target_sources(php_windows PRIVATE php_zlib.def)
endif()

target_compile_definitions(php_ext_zlib PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

find_package(ZLIB ${PHP_ZLIB_MIN_VERSION})
set_package_properties(
  ZLIB
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the zlib extension."
)

# Link publicly for internal_functions files.
target_link_libraries(php_ext_zlib PUBLIC ZLIB::ZLIB)

set(HAVE_ZLIB TRUE)

configure_file(cmake/config.h.in config.h)
