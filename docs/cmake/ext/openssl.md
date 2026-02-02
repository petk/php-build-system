<!-- This is auto-generated file. -->
* Source code: [ext/openssl/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/ext/openssl/CMakeLists.txt)

# The openssl extension

This extension enables encryption and decryption support using the OpenSSL
library.

## Configuration options

### PHP_EXT_OPENSSL

* Default: `OFF`
* Values: `ON|OFF`

Enables the PHP `openssl` extension.

Where to find OpenSSL installation on the system, can be customized with the
`OPENSSL_ROOT_DIR` variable.

### PHP_EXT_OPENSSL_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Builds extension as shared library.

### PHP_EXT_OPENSSL_SYSTEM_CIPHERS

* Default: `OFF`
* Values: `ON|OFF`

Uses system default cipher list instead of the hardcoded value for OpenSSL.

### PHP_EXT_OPENSSL_ARGON2

:green_circle: *New in PHP 8.4.*

* Default: `OFF`
* Values: `ON|OFF`

Enables OpenSSL Argon2 password hashing. Requires OpenSSL >= 3.2.

### PHP_EXT_OPENSSL_LEGACY_PROVIDER

:green_circle: *New in PHP 8.4.*

* Default: `OFF`
* Values: `ON|OFF`

Loads OpenSSL legacy algorithm provider in addition to the default provider.
Requires OpenSSL >= 3. Legacy algorithms are by OpenSSL library considered those
that are either insecure, or have fallen out of use.

### PHP_EXT_OPENSSL_KERBEROS

:red_circle: *Removed as of PHP 8.4.*

* Default: `OFF`
* Values: `ON|OFF`

Includes Kerberos support for OpenSSL.

Where to find Kerberos installation on the system, can be customized with the
`KERBEROS_ROOT` variable.

> [!NOTE]
> Note, that Kerberos support has been removed as of OpenSSL 1.1.0, which makes
> this option deprecated.
