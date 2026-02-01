<!-- This is auto-generated file. -->
* Source code: [ext/zlib/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/ext/zlib/CMakeLists.txt)

# The zlib extension

The PHP `zlib` extension provides support for reading and writing gzip (.gz)
compressed files.

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
