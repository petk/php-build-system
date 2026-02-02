<!-- This is auto-generated file. -->
* Source code: [ext/mysqlnd/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/ext/mysqlnd/CMakeLists.txt)

# The mysqlnd extension

This extension contains MySQL Native Driver for using MySQL-compatible databases
in PHP extensions.

## Configuration options

### PHP_EXT_MYSQLND

* Default: `OFF`
* Values: `ON|OFF`

Enables the PHP `mysqlnd` extension.

### PHP_EXT_MYSQLND_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Builds extension as shared library.

### PHP_EXT_MYSQLND_COMPRESSION

* Default: `ON`
* Values: `ON|OFF`

Enables compressed protocol support in mysqlnd.

### PHP_EXT_MYSQLND_SSL

* Default: `ON`
* Values: `ON|OFF`

Explicitly enables or disables extended SSL support in the `mysqlnd` extension.
On Unix-like systems, the extended SSL works through the OpenSSL library and on
Windows through the Windows Crypt32 library.

For example, `mysqlnd` extension with disabled extended SSL support, would
require in MySQL Server 8.0 and later versions to have the
`default_authentication_plugin` configuration set to `mysql_native_password` in
`my.cnf` (`caching_sha2_password` therefore wouldn't be supported).

This option is only provided to explicitly avoid requiring the OpenSSL
dependency, otherwise the recommended setting is `ON`.
