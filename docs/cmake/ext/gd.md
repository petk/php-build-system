<!-- This is auto-generated file. -->
* Source code: [ext/gd/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/ext/gd/CMakeLists.txt)

# The gd extension

This extension provides image processing and graphics draw (GD) support.

## Configuration options

### PHP_EXT_GD

* Default: `OFF`
* Values: `ON|OFF`

Enables the extension.

### PHP_EXT_GD_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Builds extension as shared.

### PHP_EXT_GD_EXTERNAL

* Default: `OFF`
* Values: `ON|OFF`

Uses an external (system) GD library instead of the bundled libgd from PHP
sources.

### PHP_EXT_GD_AVIF

* Default: `OFF`
* Values: `ON|OFF`

Enables the AVIF support (only for bundled libgd).

### PHP_EXT_GD_WEBP

* Default: `OFF`
* Values: `ON|OFF`

Enables the WebP support (only for bundled libgd).

### PHP_EXT_GD_JPEG

* Default: `OFF`
* Values: `ON|OFF`

Enables the JPEG support (only for bundled libgd).

### PHP_EXT_GD_XPM

* Default: `OFF`
* Values: `ON|OFF`

Enables the XPM support (only for bundled libgd).

### PHP_EXT_GD_FREETYPE

* Default: `OFF`
* Values: `ON|OFF`

Enables the FreeType 2 support (only for bundled libgd).

### PHP_EXT_GD_JIS

* Default: `OFF`
* Values: `ON|OFF`

Enables the JIS-mapped (Japanese Industrial Standards) Japanese font support
(only for bundled libgd).

## Examples

Enabling gd extension:

```sh
cmake -B <build-dir> -DPHP_EXT_GD=ON
```

Customizing where to find dependencies can be done by setting the
`CMAKE_PREFIX_PATH` variable or by setting the individual `<PackageName>_ROOT`
variables.

For example, to specify custom installations of libpng and webp libraries:

```sh
cmake \
  -B <build-dir> \
  -DPHP_EXT_GD=ON \
  -DCMAKE_PREFIX_PATH="/path/to/libpng-installation;/path/to/webp-installation"
```

Or:

```sh
cmake \
  -B <build-dir> \
  -DPHP_EXT_GD=ON \
  -DPNG_ROOT="/path/to/libpng-installation \
  -DWebP_ROOT=/path/to/webp-installation
```

Similarly, other dependencies can be customized with:

```sh
cmake \
  -B <build-dir> \
  -DPHP_EXT_GD=ON \
  -DCMAKE_PREFIX_PATH="/path/to/libpng-installation;/path/to/..."
```

or:

```sh
cmake \
  -B <build-dir> \
  -DPHP_EXT_GD=ON \
  -DFreetype_ROOT=... \
  -DJPEG_ROOT=... \
  -Dlibavif_ROOT=... \
  -DPNG_ROOT=/path/to/libpng-installation \
  -DWebP_ROOT=/path/to/webp-installation \
  -DXPM_ROOT=... \
  -DZLIB_ROOT=...
```

Customizing where to find external GD library installation:

```sh
cmake \
  -B <build-dir> \
  -DPHP_EXT_GD=ON \
  -DPHP_EXT_GD_EXTERNAL=ON \
  -DCMAKE_PREFIX_PATH=/path/to/libgd/installation
```

or:

```sh
cmake \
  -B <build-dir> \
  -DPHP_EXT_GD=ON \
  -DPHP_EXT_GD_EXTERNAL=ON \
  -DGD_ROOT=/path/to/libgd/installation
```
