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

* Default: `ON`
* Values: `ON|OFF`

Explicitly enable or disable extended SSL support in the `mysqlnd` extension. On
\*nix systems, the extended SSL works through the OpenSSL library and on Windows
through the Windows Crypt32 library.

For example, `mysqlnd` extension with disabled extended SSL support, would
require in MySQL Server 8.0 and later versions to have the
`default_authentication_plugin` configuration set to `mysql_native_password` in
`my.cnf` (`caching_sha2_password` therefore wouldn't be supported).

This option is only provided to explicitly avoid requiring the OpenSSL
dependency, otherwise recommended setting is `ON`.
