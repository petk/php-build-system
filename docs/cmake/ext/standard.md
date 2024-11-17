<!-- This is auto-generated file. -->
* Source code: [ext/standard/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/ext/standard/CMakeLists.txt)

# The standard extension

Configure the `standard` extension.

This is an always enabled core PHP extension that provides common functionality
to PHP extensions and SAPIs.

## EXT_STANDARD_ARGON2

* Default: `OFF`
* Values: `ON|OFF`

Include the Argon2 support in `password_*()` functions.

## EXT_STANDARD_EXTERNAL_LIBCRYPT

* Default: `OFF`
* Values: `ON|OFF`

Use external libcrypt or libxcrypt.
