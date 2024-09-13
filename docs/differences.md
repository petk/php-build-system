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

* CMake presets simplify the build configurations. The native PHP Autotools
  build system has issues with the `--enable-all` option, where certain
  configuration options are set but they also set additional variables (e.g.,
  `ext_shared`) where they shouldn't. PHP Windows build system has similar
  configure option `--enable-snapshot-build` (and `--disable-all`).

* Better cross-compiling support with CMake toolchain files and ability to set
  the cross-compiling emulator.

## Bugs fixed

* Building inside folder with spaces.
  See: https://bugs.php.net/49270

* Detecting GNU libiconv.
  See: https://github.com/php/php-src/issues/12213

* Oracle Instant Client integration in ldap extension is removed in CMake due to
  missing LDAP features causing build errors.
  See: https://github.com/php/php-src/issues/15051

* The phpdbg prompt with libedit integration is colored.
  See: https://github.com/php/php-src/pull/15722

## Behavior

* ext/readline is linked with libedit by default instead of GNU Readline.
  See: https://github.com/php/php-src/pull/13184

* sapi/phpdbg readline support works more intuitively regardless of the readline
  extension being enabled during the build.

* ext/session can be built as shared on Windows (in testing phase).

* Obsolete check whether the `dlsym()` requires a leading underscore in symbol
  name is removed in CMake.
  See: https://github.com/php/php-src/pull/13655

* Compiler shipped with Oracle Developer Studio is not supported.
  See: https://github.com/php/php-src/issues/15272

* ext/phar doesn't have native SSL support anymore in favor of SSL through the
  PHP openssl extension:
  See: https://github.com/php/php-src/pull/15574

* The _XOPEN_SOURCE compile definition to use ucontext.h on macOS when needed is
  only defined for the Zend/zend_fibers.c file. Duplicate inconsistent
  _XOPEN_SOURCE definition from the php_config.h is also removed with this.
