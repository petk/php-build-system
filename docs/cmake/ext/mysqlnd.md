<!-- This is auto-generated file. -->
* Source code: [ext/mysqlnd/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/ext/mysqlnd/CMakeLists.txt)

# The mysqlnd extension

Configure the `mysqlnd` extension.

This extension contains MySQL Native Driver for using MySQL-compatible databases
in PHP extensions.

## PHP_EXT_MYSQLND

* Default: `OFF`
* Values: `ON|OFF`

Enable the PHP `mysqlnd` extension.

## PHP_EXT_MYSQLND_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared library.

## PHP_EXT_MYSQLND_COMPRESSION

* Default: `ON`
* Values: `ON|OFF`

Enable compressed protocol support in mysqlnd.

## PHP_EXT_MYSQLND_SSL

* Default: `OFF`
* Values: `ON|OFF`

Explicitly enable extended SSL support in the `mysqlnd` extension. On \*nix
systems, extended SSL works through the OpenSSL library and on Windows through
the Windows Crypt32 library. Beneficial when building without the `openssl`
extension or when building with phpize.

\*nix systems: when building with the `openssl` extension (`PHP_EXT_OPENSSL=ON`)
in the php-src tree, the extended SSL is enabled implicitly regardless of this
option.

Windows systems: extended SSL is enabled implicitly based on the Crypt32
library regardless of this option.
