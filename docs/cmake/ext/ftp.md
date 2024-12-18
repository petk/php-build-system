<!-- This is auto-generated file. -->
* Source code: [ext/ftp/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/ext/ftp/CMakeLists.txt)

# The ftp extension

Configure the `ftp` extension.

This extension provides support for File Transfer Protocol (FTP).

## PHP_EXT_FTP

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_FTP_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.

## PHP_EXT_FTP_SSL

* Default: `OFF`
* Values: `ON|OFF`

Explicitly enable FTP over SSL support when building without openssl extension
(`PHP_EXT_OPENSSL=OFF`) or when using `phpize`. If the `openssl` extension is
enabled at the configure step (`PHP_EXT_OPENSSL=ON`), FTP-SSL is enabled
implicitly regardless of this option.
