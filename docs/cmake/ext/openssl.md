<!-- This is auto-generated file. -->
* Source code: [ext/openssl/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/ext/openssl/CMakeLists.txt)

# The openssl extension

Configure the `openssl` extension.

This extension enables encryption and decryption support using the OpenSSL
library.

## EXT_OPENSSL

* Default: `OFF`
* Values: `ON|OFF`

Enable the PHP `openssl` extension.

Where to find OpenSSL installation on the system, can be customized with the
`OPENSSL_ROOT_DIR` variable.

## EXT_OPENSSL_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared library.

## EXT_OPENSSL_SYSTEM_CIPHERS

* Default: `OFF`
* Values: `ON|OFF`

Use system default cipher list instead of the hardcoded value for OpenSSL.

## EXT_OPENSSL_ARGON2

:green_circle: *New in PHP 8.4.*

* Default: `OFF`
* Values: `ON|OFF`

Enable OpenSSL Argon2 password hashing. Requires OpenSSL >= 3.2.

## EXT_OPENSSL_LEGACY_PROVIDER

:green_circle: *New in PHP 8.4.*

* Default: `OFF`
* Values: `ON|OFF`

Load OpenSSL legacy algorithm provider in addition to the default provider.
Requires OpenSSL >= 3. Legacy algorithms are by OpenSSL library considered those
that are either insecure, or have fallen out of use.

## EXT_OPENSSL_KERBEROS

:red_circle: *Removed as of PHP 8.4.*

* Default: `OFF`
* Values: `ON|OFF`

Include Kerberos support for OpenSSL.

Where to find Kerberos installation on the system, can be customized with the
`KERBEROS_ROOT` variable.

Note, that Kerberos support has been removed from the OpenSSL library as of
OpenSSL 1.1.0.
