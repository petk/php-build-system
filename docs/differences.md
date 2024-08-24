# PHP native and CMake-based build system differences

How CMake-based PHP build system differs compared to its Autotools and Windows
build system:

## Enhancements

* `re2c` tool can be automatically downloaded, when not found on the system

* Added pkg-config .pc files

  Once installed, there are two .pc files available in system `pkgconfig`
  directory:

  * php.pc - for building PHP extensions
  * php-embed.pc - for embedding PHP into application

    These can be then used with the pkg-config (pkgconf) tool:

    ```sh
    pkg-config --cflags php
    pkg-config --cflags-only-I php
    pkg-config --libs php
    pkg-config --mod-version php
    pkg-config --print-variables php
    pkg-config --variable=php_vernum php
    ```

    Upstream Autotools-based draft: https://github.com/php/php-src/pull/13755

## Bugs fixed

* Building inside folder with spaces.
  See: https://bugs.php.net/49270

* Detecting GNU libiconv.
  See: https://github.com/php/php-src/issues/12213

* Oracle Instant Client integration in ldap extension is removed in CMake due to
  missing LDAP features causing build errors.
  See: https://github.com/php/php-src/issues/15051

## Behavior

* ext/readline uses the libedit (EditLine) library by default.
  See: https://github.com/php/php-src/pull/13184

* ext/session can be built as shared on Windows (in testing phase).

* Obsolete check whether the `dlsym()` requires a leading underscore in symbol
  name is removed in CMake.
  See: https://github.com/php/php-src/pull/13655

* Compiler shipped with Oracle Developer Studio is not supported.
  See: https://github.com/php/php-src/issues/15272

* ext/phar doesn't have native SSL support anymore as of PHP 8.4 in favor of SSL
  through the PHP openssl extension:
  See: https://github.com/php/php-src/pull/14578
  See: https://github.com/php/php-src/pull/15574
