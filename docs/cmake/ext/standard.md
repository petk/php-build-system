<!-- This is auto-generated file. -->
* Source code: [ext/standard/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/ext/standard/CMakeLists.txt)

# The standard extension

This is an always enabled core PHP extension that provides common functionality
to PHP extensions and SAPIs.

## Configuration options

### PHP_EXT_STANDARD_ARGON2

* Default: `OFF`
* Values: `ON|OFF`

Includes the Argon2 support in `password_*()` functions.

### PHP_EXT_STANDARD_CRYPT_EXTERNAL

* Default: `OFF`
* Values: `ON|OFF`

Uses external crypt library, such as libcrypt or libxcrypt, instead of the
bundled PHP crypt.
