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

## Behavior

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

* The `_XOPEN_SOURCE` compile definition to use ucontext.h on macOS when needed
  is only defined for the Zend/zend_fibers.c file. Duplicate inconsistent
  `_XOPEN_SOURCE` definition in the php_config.h is also removed with this.

* In CMake the install prefix can be also changed during the installation phase
  using the `cmake --install <build-dir> --prefix <install-prefix>`. In PHP
  native Autotools-based build system, installation prefix can be only set at
  the configure phase using the `./configure --prefix=<installl-prefix>`, which
  is a regression for the `main/build-defs.h` and `main/php_config.h` files,
  where the installation prefix in PHP is hardcoded during the build phase and
  cannot be changed during the installation phase. For the generated files
  (php-config, pkg-config .pc, etc.) workaround is already done in CMake but not
  yet for the header files.
  See: https://github.com/petk/php-build-system/issues/4

* CMake configuration mostly follows Autotools defaults aiming to be consistent.
  In native PHP build system there are various extensions by default
  inconsistently enabled or disabled between Autotools and Windows.

  For example:

    * ext/bcmath (Windows: enabled, Autotools: disabled, CMake: disabled)
    * ext/calendar (Windows: enabled, Autotools: disabled, CMake: disabled)

* Installation

  * The installation include directory (`/usr/local/include/php`) can be
    adjusted with the `PHP_INCLUDE_PREFIX` CMake cache variable to support
    multiple PHP versions. For example, `/usr/local/include/php/8.4`.

  * The PHP Autotools layout configuration option `--with-layout=[PHP|GNU]` is
    in CMake removed and not implemented in favor of the GNU standard directory
    layout.

  * PEAR installation writes less dot and temporary files outside of the staging
    installation directory (INSTALL_ROOT/DESTDIR). PEAR temporary directory can
    be adjusted with the `PHP_PEAR_TEMP_DIR` CMake cache variable.

* Parser and lexer files

  * When generating parser (Bison) and lexer (re2c) files with command-line
    script `cmake/scripts/GenerateGrammar.cmake`, Bison report files
    (`*.output`) are not generated.

  * For the `Release` and `MinSizeRel` CMake build types, the Bison `--no-lines`
    (`-l`) and re2c `--no-debug-info` (`-i`) options are added.

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

* GPL 3 licensed dependencies are removed as they are not compatible with PHP
  license. When such dependencies are linked statically or dynamically, PHP
  should be relicensed as GPL 3 (which is unrealistic), or it shouldn't be
  distributed (which makes it unusable in server environments or package
  repositories). As this is a gray area, removal of these dependencies improves
  user experience and prevents misconfiguration.

  * GDBM (GNU dbm) handler removed in ext/dba.
    See: https://github.com/php/php-src/issues/16826

  * ext/readline is linked with libedit and GNU Readline removed.
    See: https://github.com/php/php-src/issues/15882

* Build with Clang on 32-bit systems.
  See: https://github.com/php/php-src/issues/14467

* Zend/zend_vm_gen.php deprecation warnings on 32-bit systems.
  See: https://github.com/php/php-src/issues/15899

* The `chroot()` PHP function is enabled/disabled based on the SAPI type.
  See: https://github.com/php/php-src/issues/11984

* The libmbfl configuration header (`config.h`).
  See: https://github.com/php/php-src/pull/13713
