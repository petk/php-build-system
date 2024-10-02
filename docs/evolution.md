# PHP build system evolution

This document describes how the PHP build system evolved through time.

## PHP 1 (1995)

First public release of PHP 1 - Personal Home Page Tools started with a single
Makefile.

<details>
<summary>PHP tools Makefile</summary>

```Makefile
#
# Makefile for the PHP Tools
#
# By Rasmus Lerdorf
#

#
# Here are the configurable options.
#
# For BSDi systems, use: -DFLOCK
# For SVR4 systems (Solaris - SunOS 5.4), use: -DLOCKF
# For SunOS systems use: -DFLOCK -DFILEH
# For AIX systems use: -DLOCKF -DLOCKFH
# For Linux use: -DLOCKF
# For BSD 4.3 use: -DFLOCK -DFILEH -DDIRECT
#
# If you want to disable the <!--!command--> feature add this: -DNOSYSTEM

OPTIONS = -DFLOCK

# Generic compiler options
#CFLAGS = -g -O2 -Wall -DDEBUG $(OPTIONS)
CFLAGS = -O2 $(OPTIONS)
CC = gcc
# If you don't have gcc, use these instead:
#CFLAGS = -g $(OPTIONS)
#CC = cc

TSOURCE = php/phpf.c php/phpl.c php/phplview.c php/phplmon.c php/common.c \
      php/error.c php/post.c php/wm.c php/common.h php/config.h \
      php/subvar.c php/html_common.h php/post.h php/version.h php/wm.h \
      php/Makefile php/README php/License

SOURCE = phpf.c phpl.c phplview.c phplmon.c common.c \
      error.c post.c wm.c common.h config.h \
      subvar.c html_common.h post.h version.h wm.h \
      Makefile README License

ALL: phpl.cgi phplmon.cgi phplview.cgi phpf.cgi

phpl.cgi: phpl.o wm.o common.o post.o subvar.o error.o
    $(CC) -o phpl.cgi phpl.o wm.o common.o post.o error.o subvar.o

phplmon.cgi: phplmon.o common.o
    $(CC) -o phplmon.cgi phplmon.o common.o

phplview.cgi: phplview.o common.o post.o error.o
    $(CC) -o phplview.cgi phplview.o common.o post.o error.o

phpf.cgi: phpf.o post.o error.o
    $(CC) -o phpf.cgi phpf.o post.o error.o common.o

php.tar: $(SOURCE)
    cd ..;tar -cf php/php.tar $(TSOURCE);cd php

error.o:    error.c html_common.h
phpl.o:     phpl.c config.h
phplmon.o:  phplmon.c config.h
phplview.o: phplview.c
wm.o:       wm.c
common.o:   common.c version.h common.h
post.o:     post.c html_common.h
phpf.o:     phpf.c html_common.h common.h
subvar.o:   subvar.c
```
</details>

## PHP 2.0 (1998)

PHP quickly grew and a new version was created - PHP 2.0 (PHP/FI) with Autoconf
2.9 based configure script.

## PHP 4.0 (2000)

In 1999, support for building external PHP extensions using a PEAR-based tool
`phpize` was added to PHP which became available in 2000 in the PHP 4.0 release.
Autoconf minimum required version was set to `2.13`.

## PHP 4.3 (2002)

Build system gets rewritten and modernized for the Autoconf versions available
at the time. Dependency on Automake has been removed.

## PHP 5.0 (2004)

In 2003, a new additional Windows dedicated build system for building PHP on
Windows systems was developed and added to PHP 5.0 released in 2004.
Freedesktop's `pkg-config` tool was optionally used in PHP Autotools-based \*nix
build system to find the OpenSSL dependency on the system.

## 2008

Idea to rewrite PHP build system in CMake first appeared during the Google
Summer of Code in 2008 ([wiki](https://wiki.php.net/internals/cmake),
[php-cmake](https://github.com/gloob/php-cmake)).

## PHP 5.4 (2012)

Autoconf minimum required version was increased to `2.59`.

## PHP 7.0 (2013)

<details>
<summary>Changelog</summary>

### PHP 7.0 build system changes

#### Windows

* Besides Visual Studio, building with Clang or Intel Composer is now possible.
  To enable an alternative toolset, the configure option
  `--with-toolset=[vs,clang,icc]` was added to the main build system and phpize.
* The `configure.js` now produces response files which are passed to the linker
  and library manager. This solved the issues with the long command lines which
  can exceed the OS limit.
* With the Clang toolset, an option `--with-uncritical-warn-choke` was added to
  suppress the most frequent false positive warnings.
* The `--with-mp` configure option by default utilizes all the available cores.
  Enabled by default for release builds and can be disabled with the special
  `disable` keyword.

</details>

## PHP 7.1 (2014)

<details>
<summary>Changelog</summary>

### PHP 7.1 build system changes

#### Windows

* Added support for the static analysis with Clang and Cppcheck by passing the
  `clang` or `cppcheck` keyword to the `--with-analyzer` configure option.

</details>

## PHP 7.2 (2015)

The `configure.in` was renamed to `configure.ac` according to Autoconf
evolution. Autoconf minimum required version was increased to `2.64`.

<details>
<summary>Changelog</summary>

### PHP 7.2 build system changes

#### Autotools configure options

* The `--enable-gd-native-ttf`, and `--with-mcrypt=DIR` configure options have
  been removed.
* Added `--enable-phpdbg-readline`, `--with-valgrind=DIR`,
  `--with-pcre-valgrind=DIR`, `--with-lmdb=DIR`, `--with-sodium=DIR`,
  `--with-password-argon2=DIR`, `--enable-zend-test` configure options.

</details>

## PHP 7.3 (2018)

Autoconf minimum required version was increased to `2.68`.

<details>
<summary>Changelog</summary>

### PHP 7.3 build system changes

#### Autotools configure options

* The `--with-libmbfl=DIR`, `--with-ODBCRouter=DIR`, and `--with-birdstep=DIR`
  configure options have been removed.

</details>

## PHP 7.4 (2019)

In 2018, support for Freedesktop's `pkg-config` M4 macros was added in the PHP
repository to simplify finding system dependencies. In 2019, build system was
heavily cleaned up and adjusted for Autoconf versions available at the time,
including the removal of `aclocal.m4` in favor of the php related M4 macros in
`php.m4`. Minimum required Bison version is 3.0.

<details>
<summary>Changelog</summary>

### PHP 7.4 build system changes

#### Abstract

* The hash extension is now always available, meaning the `--enable-hash`
  configure argument has been removed.
* The filter extension no longer exposes the `--with-pcre-dir` configure
  argument and therefore allows shared builds with `./configure` for Unix
  builds.
* Symbols `HAVE_DATE`, `HAVE_REFLECTION`, and `HAVE_SPL` have been removed. It
  should be considered to have these extensions always available.
* Removed unused build time symbols: `PHP_ADA_INCLUDE`, `PHP_ADA_LFLAGS`,
  `PHP_ADA_LIBS`, `PHP_APACHE_INCLUDE`, `PHP_APACHE_TARGET`,
  `PHP_FHTTPD_INCLUDE`, `PHP_FHTTPD_LIB`, `PHP_FHTTPD_TARGET`, `PHP_CFLAGS`,
  `PHP_DBASE_LIB`, `PHP_BUILD_DEBUG`, `PHP_GDBM_INCLUDE`, `PHP_IBASE_INCLUDE`,
  `PHP_IBASE_LFLAGS`, `PHP_IBASE_LIBS`, `PHP_IFX_INCLUDE`, `PHP_IFX_LFLAGS`,
  `PHP_IFX_LIBS`, `PHP_INSTALL_IT`, `PHP_IODBC_INCLUDE`, `PHP_IODBC_LFLAGS`,
  `PHP_IODBC_LIBS`, `PHP_MSQL_LFLAGS`, `PHP_MSQL_INCLUDE`, `PHP_MSQL_LFLAGS`,
  `PHP_MSQL_LIBS`, `PHP_MYSQL_INCLUDE`, `PHP_MYSQL_LIBS`, `PHP_MYSQL_TYPE`,
  `PHP_OCI8_SHARED_LIBADD`, `PHP_ORACLE_SHARED_LIBADD`, `PHP_ORACLE_DIR`,
  `PHP_ORACLE_VERSION`, `PHP_PGSQL_INCLUDE`, `PHP_PGSQL_LFLAGS`,
  `PHP_PGSQL_LIBS`, `PHP_SOLID_INCLUDE`, `PHP_SOLID_LIBS`,
  `PHP_EMPRESS_INCLUDE`, `PHP_EMPRESS_LIBS`, `PHP_SYBASE_INCLUDE`,
  `PHP_SYBASE_LFLAGS`, `PHP_SYBASE_LIBS`, `PHP_DBM_TYPE`, `PHP_DBM_LIB`,
  `PHP_LDAP_LFLAGS`, `PHP_LDAP_INCLUDE`, `PHP_LDAP_LIBS`.
* Removed unused symbols: `HAVE_CURL_EASY_STRERROR`, `HAVE_CURL_MULTI_STRERROR`,
  `HAVE_MPIR`, `HAVE_MBSTR_CN`, `HAVE_MBSTR_JA`, `HAVE_MBSTR_KR`,
  `HAVE_MBSTR_RU`, `HAVE_MBSTR_TW`.

#### Autotools

* Added `--ini-path` and `--ini-dir` options to php-config.
* The `configure --help` now also outputs `--program-suffix` and
  `--program-prefix` information by using the Autoconf `AC_ARG_PROGRAM` macro.
* Minimum Bison version is 3.0+ for generating parser files.

##### Configure options

* Added new `--enable-rtld-now` configure option to switch the dlopen behavior
  from `RTLD_LAZY` to `RTLD_NOW`.
* The `--with-pcre-valgrind` and `--with-valgrind` were merged, and Valgrind
  detected by pkg-config.
* The `--enable-opcache-file` configure option has been removed.

##### Autoconf local macros

* Obsolescent macros `AC_FUNC_VPRINTF` and `AC_FUNC_UTIME_NULL` have been
  removed. Symbols `HAVE_VPRINTF` and `HAVE_UTIME_NULL` are no longer defined
  since they are not needed on the current systems.
* Local PHP Autoconf unused or obsolete macros have been removed:
  `PHP_TARGET_RDYNAMIC`, `PHP_SOLARIS_PIC_WEIRDNESS`, `PHP_SYS_LFS`,
  `PHP_AC_BROKEN_SPRINTF`, `PHP_EXTENSION`, `PHP_DECLARED_TIMEZONE`,
  `PHP_CHECK_TYPES`, `PHP_CHECK_64BIT`, `PHP_READDIR_R_TYPE`,
  `PHP_SETUP_KERBEROS`.
* Local `PHP_TM_GMTOFF` Autoconf macro was replaced with Autoconf's
  `AC_CHECK_MEMBERS`. The `HAVE_TM_GMTOFF` symbol is replaced with
  `HAVE_STRUCT_TM_TM_GMTOFF` and `HAVE_TM_ZONE` symbol is replaced with
  `HAVE_STRUCT_TM_TM_ZONE`.
* `PHP_PROG_BISON` macro now takes two optional arguments - minimum required
  version and excluded versions that aren't supported.
* `PHP_PROG_RE2C` is not called in the generated `configure.ac` for extensions
  anymore and now takes one optional argument - minimum required version.
* Removed unused `AC_PROG_CC_C_O` check and the `NO_MINUS_C_MINUS_O` symbol.
* Obsolescant checks for headers and functions that are part of C89 have
  been removed. The following symbols are therefore no longer defined by the
  PHP build system at the configure step and shouldn't be used anymore:
  `HAVE_SETLOCALE`, `HAVE_LOCALECONV`, `HAVE_STRSTR`, `HAVE_STRTOL`,
  `HAVE_STRBRK`, `HAVE_PERROR`, `HAVE_STRFTIME`, `HAVE_TZNAME`, `HAVE_STDARG_H`,
  `HAVE_STRING_H`, `HAVE_STDLIB_H`, `HAVE_SYS_VARARGS_H`, `HAVE_ASSERT_H`,
  `HAVE_SYS_DIR_H`, `TM_IN_SYS_TIME`, `HAVE_STRTOD`, `HAVE_STRCOLL`,
  `HAVE_ERRNO_H`, `HAVE_MEMCPY`, `HAVE_SNPRINTF`, `HAVE_STDIO_H`,
  `HAVE_STRPBRK`, `HAVE_TIME_H`, `HAVE_LIMITS_H`, `HAVE_STRTOUL`,
  `HAVE_SYS_NDIR_H`, `HAVE_SYS_TIMES_H`, `PHP_HAVE_STDINT_TYPES`,
  `HAVE_SIGNAL_H`, `HAVE_STRERROR`.
* Removed unused check for `dev/arandom` and the `HAVE_DEV_ARANDOM` symbol.
* Remove unused functions checks: `HAVE_MBSINIT`, `HAVE_MEMPCPY`,
  `HAVE_SETPGID`, `HAVE_STRPNCPY`, `HAVE_STRTOULL`, `HAVE_VSNPRINTF`,
  `HAVE_CUSERID`, `HAVE_LRAND48`, `HAVE_RANDOM`, `HAVE_SRAND48`, `HAVE_SRANDOM`,
  `HAVE_STRDUP`, `HAVE_GCVT`, `HAVE_ISASCII`, `HAVE_LINK`, `HAVE_LOCKF`,
  `HAVE_SOCKOPT`, `HAVE_SETVBUF`, `HAVE_SIN`, `HAVE_TEMPNAM`.
* Unused check for `struct cmsghdr` and symbol `HAVE_CMSGHDR` have been removed.
* Unused `ApplicationServices/ApplicationServices.h` headers check and
  `HAVE_APPLICATIONSERVICES_APPLICATIONSERVICES_H` symbol have been removed.
* `PHP_DEBUG_MACRO` macro has been removed.
* `PHP_CHECK_CONFIGURE_OPTIONS` macro has been removed. Default Autoconf's
  `--enable-option-checking=fatal` option can be used in the configure step
  to enable error when invalid options are used.
* Removed unused check and symbols `HAVE_SHM_MMAP_ZERO`, `HAVE_SHM_MMAP_FILE`.
* Removed unused check and symbol `MISSING_MSGHDR_MSGFLAGS`.

#### Windows

* Visual Studio 2019 is utilized for the Windows builds
* Removed unused defined symbol `HAVE_LIBBIND`.

</details>

## PHP 8.0 (2020)

PHP coding standards now use the C99 standard.

<details>
<summary>Changelog</summary>

### PHP 8.0 build system changes

#### Autotools configure options

* The `--enable/disable-json`, `--with-xmlrpc`, `--with-expat`,
  `--with-iconv-dir=DIR`, `--enable-maintainer-zts`,
  `--disable-inline-optimization`, `--with-tsrm-pth`, `--with-tsrm-st`,
  `--with-tsrm-pthreads` configure options has been removed.
* Added `--with-fpm-apparmor`, `--enable-fuzzer`, `--enable-fuzzer-msan`,
  `--enable-debug-assertions`, `--enable-zts`, `--enable-memory-sanitizer`,
  `--disable-opcache-jit` configure options.
</details>

## PHP 8.1 (2021)

<details>
<summary>Changelog</summary>

### PHP 8.1 build system changes

#### Autotools configure options

* The `--enable-phpdbg-webhelper` configure option has been removed.
* The `--with-password-argon2` doesn't accept the argument anymore.
* Added the `--enable-address-sanitizer`, `--enable-undefined-sanitizer`,
  `--enable-dl-test`, `--with-avif`, `--with-external-libcrypt`,
  `--disable-fiber-asm`, `--enable-zend-max-execution-timers` configure options.
</details>

## 2021

Idea to move CMake forward and additionally use Conan was started on the
[PHP internals mailing list](https://externals.io/message/116655).

## PHP 8.2 (2022)

Added support for ARM64 on Windows.

<details>
<summary>Changelog</summary>

### PHP 8.2 build system changes

* The build system now requires PHP 7.4.0 at least. Previously PHP 7.1 was
  required.
* Unsupported libxml2 2.10.0 symbols are no longer exported on Windows.
* Identifier names for namespaced functions generated from stub files through
  `gen_stub.php` have been changed. This requires that namespaced functions
  should be declared via the `PHP_FUNCTION` macro by using the fully qualified
  function name (whereas each part is separated by `_`) instead of just the
  function name itself.

#### Autotools

* The `--enable-fuzzer-msan` configure option has been removed.
* The `--with-mysqli` doesn't accept the DIR argument anymore.
* Added the `--with-fpm-selinux` configure option.

#### Windows

* Added support for ARM64.
* The `--with-oci8` configure option has been removed.
* The zip extension is now built as shared library (DLL) by default.

</details>

## PHP 8.3 (2023)

Windows 8 and Windows Server 2012 became the minimum supported versions by the
PHP Windows build system.

<details>
<summary>Changelog</summary>

### PHP 8.3 build system changes

#### Autotools

* `PHP_EXTRA_VERSION` can be passed to configure script to control custom PHP
  build versions: `./configure PHP_EXTRA_VERSION="-acme"`
* `LDFLAGS` are not unset anymore allowing them to be adjusted e.g.
  `LDFLAGS="..." ./configure`
* Removed the `HAVE_DEV_URANDOM` compile time check.
* Added new configure option `--with-capstone`.

</details>

## PHP 8.4 (2024)

Autotools-based build system was cleaned-up, updated, and refactored using the
current Autoconf syntax for the current systems at the time. Cross-compiling was
improved one step forward with cache variables synced enabling the manual
overrides on many places. C preprocessor macros inconsistencies between Windows
and Autotools configuration headers were synced to a nearly identical behavior.

<details>
<summary>Changelog</summary>

### PHP 8.4 build system changes

#### Abstract

* The configure options `--with-imap`, `--with-pdo-oci`, and `--with-pspell`
  have been removed.
* The configure option `--with-mhash` emits deprecation warning.
* New configure option `--with-openssl-legacy-provider` to enable OpenSSL legacy
  provider.
* New configure option `--with-openssl-argon2` to enable `PASSWORD_ARGON2` from
  OpenSSL 3.2.
* Symbol `SIZEOF_SHORT` removed (size of 2 on 32-bit and 64-bit platforms).
* Symbol `DBA_CDB_MAKE` removed in ext/dba.
* Symbols `HAVE_LIBM`, `HAVE_INET_ATON`, `HAVE_SIGSETJMP` have been removed.

#### Autotools

* Added php-config `--lib-dir` and `--lib-embed` options for PHP embed SAPI.
* Removed linking with obsolete dnet_stub library in ext/pdo_dblib.
* Removed checking and linking with obsolete libbind for some functions.

##### Autotools configure options

* The `--with-imap-ssl`, `--with-oci8`, `--with-zlib-dir`, and `--with-kerberos`
  have been removed.
* The `--with-openssl-dir` has been removed. SSL support in ext/ftp and
  ext/mysqlnd is enabled implicitly, when building with ext/openssl
  (`--with-openssl`), or explicitly by using new configure options
  `--with-ftp-ssl` and `--with-mysqlnd-ssl`.

##### Changes to main/php_config.h

* `COOKIE_IO_FUNCTIONS_T` symbol has been removed in favor of
  `cookie_io_functions_t`.
* `HAVE_SOCKADDR_UN_SUN_LEN` symbol renamed to `HAVE_STRUCT_SOCKADDR_UN_SUN_LEN`.
* `HAVE_UTSNAME_DOMAINNAME` symbol renamed to `HAVE_STRUCT_UTSNAME_DOMAINNAME`.
* `PHP_CHECK_IN_ADDR_T` Autoconf macro and `in_addr_t` fallback definition to
  `u_int` removed in favor of `AC_CHECK_TYPES` Autoconf macro.
* `HAVE_ODBC2` symbol has been removed in ext/odbc.
* Symbol `HAVE_JSON` has been removed (ext/json is always available since PHP
  8.0).
* Symbol `DARWIN` has been removed in favor of `__APPLE__` to target Darwin
  systems.
* Symbol `MISSING_FCLOSE_DECL` and Autoconf macro `PHP_MISSING_FCLOSE_DECL` were
  removed.
* Symbol `HAVE_BSD_ICONV` has been removed.
* Symbol `ZEND_FIBER_ASM` has been removed.
* Symbols `HAVE_DLOPEN` and `HAVE_DLSYM` have been removed.
* Symbol `HAVE_MYSQL` has been removed.
* Symbol `HAVE_PDO_SQLITELIB` has been removed.
* Symbol `HAVE_WAITPID` has been removed.
* Symbol `HAVE_LIBPQ` has been removed.
* Symbols `HAVE_LIBRT` and `HAVE_TIMER_CREATE` removed.
* Symbols `PHP_FPM_SYSTEMD`, `PHP_FPM_USER`, and `PHP_FPM_GROUP` removed.
* Symbol `PTHREADS` has been removed.
* Symbol `HAVE_STRPTIME_DECL_FAILS` has been removed in favor of
  `HAVE_DECL_STRPTIME`.
* Symbol `HAVE_PHPDBG` has been removed.
* Symbols `PHP_HAVE_AVX512_SUPPORTS` and `PHP_HAVE_AVX512_VBMI_SUPPORTS` are now
  either defined to 1 or undefined.
* Symbol `HAVE_LIBCRYPT` has been removed.

##### Autoconf local macros

* Autoconf macro `PHP_DEFINE` (atomic includes) removed in favor of `AC_DEFINE`
  and extensions's config.h.
* Autoconf macro `PHP_WITH_SHARED` has been removed in favor of `PHP_ARG_WITH`.
* Autoconf macro `PHP_STRUCT_FLOCK` has been removed in favor of
  `AC_CHECK_TYPES`.
* Autoconf macro `PHP_SOCKADDR_CHECKS` has been removed in favor of
  `AC_CHECK_TYPES` and `AC_CHECK_MEMBERS`.
* Autoconf macro `PHP_CHECK_GCC_ARG` has been removed since PHP 8.0 in favor
  of `AX_CHECK_COMPILE_FLAG`.
* Autoconf macro `PHP_PROG_RE2C` got a new 2nd argument to define common
  default re2c command-line options substituted to the Makefile `RE2C_FLAGS`
  variable.
* Autoconf macros `PHP_CHECK_BUILTIN_*` have been removed in favor of
  `PHP_CHECK_BUILTIN` and all `PHP_HAVE_BUILTIN_*` symbols changed to be either
  undefined or defined to 1 whether compiler supports the builtin.
* Autoconf macro `PHP_SETUP_OPENSSL` doesn't accept the 3rd argument anymore.
* Autoconf macro `PHP_EVAL_LIBLINE` got a new 3rd argument to override the
  ext_shared checks.
* Autoconf macro `PHP_SETUP_LIBXML` doesn't define the redundant `HAVE_LIBXML`
  symbol anymore and requires at least libxml2 2.9.4.
* Autoconf macro `PHP_SETUP_ICONV` doesn't define the `HAVE_ICONV` symbol
  anymore.
* Autoconf macro `PHP_AP_EXTRACT_VERSION` is obsolete in favor of the
  `apxs -q HTTPD_VERSION`.
* Autoconf macro `PHP_OUTPUT` is obsolete in favor of `AC_CONFIG_FILES`.
* Autoconf macro `PHP_TEST_BUILD` is obsolete in favor of `AC_*` macros.
* Autoconf macro `PHP_BUILD_THREAD_SAFE` is obsolete in favor of setting the
  enable_zts variable manually.
* Autoconf macro `PHP_DEF_HAVE` is obsolete in favor of `AC_DEFINE`.
* Autoconf macro `PHP_PROG_SETUP` now accepts an argument to set the minimum
  required PHP version during the build.
* Autoconf macro `PHP_INSTALL_HEADERS` arguments can now be also
  blank-or-newline-separated lists instead of only separated with whitespace or
  backslash-then-newline.
* Autoconf macro `PHP_ADD_BUILD_DIR` now also accepts 1st argument as a
  blank-or-newline-separated separated list.
* Autoconf macros `PHP_NEW_EXTENSION`, `PHP_ADD_SOURCES`, `PHP_ADD_SOURCES_X`,
  `PHP_SELECT_SAPI` now have the source files and flags arguments normalized
  so the list of items can be passed as a blank-or-newline-separated list.
* Autoconf macro `PHP_ADD_INCLUDE` now takes also a blank-or-newline-separated
  list of include directories instead of a single directory. The "prepend"
  argument is validated at Autoconf compile time.
* TSRM/tsrm.m4 file and its `TSRM_CHECK_PTHREADS` macro have been removed.
* Added pkg-config support to find libpq for the pdo_pgsql and pgsql
  extensions. The libpq paths can be customized with the `PGSQL_CFLAGS` and
  PGSQL_LIBS environment variables. When a directory argument is provided to
  configure options (`--with-pgsql=DIR` or `--with-pdo-pgsql=DIR`), it will
  be used instead of the pkg-config search.
* Added pkg-config support to find unixODBC and iODBC for the pdo_odbc
  extension.
* Added pkg-config support to find GNU MP library. As a fallback default
  system paths are searched. When a directory argument is provided
  (`--with-gmp=DIR`), it will be used instead of the pkg-config.
* Added optional pkg-config support to find NET-SNMP library. As a fallback
  net-snmp-config utility is used like before.
* Cache variables synced to php_cv_\* naming scheme. When used for
  advanced cross-compilation, these were renamed:
  * ac_cv_copy_file_range             -> php_cv_func_copy_file_range
  * ac_cv_flush_io                    -> php_cv_have_flush_io
  * ac_cv_func_getaddrinfo            -> php_cv_func_getaddrinfo
  * ac_cv_have_broken_gcc_strlen_opt  -> php_cv_have_broken_gcc_strlen_opt
  * ac_cv_have_pcre2_jit              -> php_cv_have_pcre2_jit
  * ac_cv_pread                       -> php_cv_func_pread
  * ac_cv_pwrite                      -> php_cv_func_pwrite
  * ac_cv_syscall_shadow_stack_exists -> php_cv_have_shadow_stack_syscall
  * ac_cv_time_r_type                 -> php_cv_time_r_type
  * ac_cv_write_stdout                -> php_cv_have_write_stdout
  and all other checks wrapped with their belonging cache variables.
* Backticks command substitutions in Autoconf code have been replaced with
  `$(...)`. Passing double escaped Makefile variables `\\$(VAR)` to some
  Autoconf macros should be now done with `\$(VAR)` or by using regular shell
  variables.

#### Windows

* Building with Visual Studio requires at least Visual Studio 2019.
* Added Bison flag `-Wall` when generating lexer files as done in \*nix
  build system.
* `FIBER_ASSEMBLER` and `FIBER_ASM_ARCH` Makefile variables removed in favor of
  `PHP_ASSEMBLER` and `FIBER_ASM_ABI`.
* The `win32/build/libs_version.txt` file has been removed.
* MSVC builds use the new preprocessor (`/Zc:preprocessor`).
* The `CHECK_HEADER_ADD_INCLUDE` function consistently defines preprocessor
  macros `HAVE_<header>_H` either to value 1 or leaves them undefined to
  match the Autotools headers checks.

##### Windows configure options

* The configure options `--with-oci8-11g`, `--with-oci8-12c`,
  `--with-oci8-19`, and `--enable-apache2-2handler` have been removed.
* The configure option `--enable-apache2-4handler` became an alias for the
  preferred `--enable-apache2handler`.
* Added new configure option `--enable-phpdbg-debug` to build phpdbg in
  debug mode.
* Added support for native AVX-512 builds with
  `--enable-native-intrinsics=avx512` configure option.

##### Changes to main/config.w32.h

* `HAVE_WIN32_NATIVE_THREAD`, `USE_WIN32_NATIVE_THREAD`, `ENABLE_THREADS`
  symbols in ext/mbstring/libmbfl removed.
* `HAVE_PHP_SOAP` symbol renamed to `HAVE_SOAP`.
* Unused symbols `CONFIGURATION_FILE_PATH`, `DISCARD_PATH`, `HAVE_ERRMSG_H`,
  `HAVE_REGCOMP`, `HAVE_RINT`, `NEED_ISBLANK`, `PHP_URL_FOPEN`, `REGEX`,
  `HSREGEX`, and `USE_CONFIG_FILE` have been removed.
* The `HAVE_OPENSSL` symbol has been removed.
* The `HAVE_OPENSSL_EXT` symbol consistently defined to value 1 whether the
  openssl extension is available either as shared or built statically.
</details>

## PHP 8.5 (2025)

PHP coding standards now use the C11 standard.

<details>
<summary>Changelog</summary>

### PHP 8.5 build system changes

#### Abstract

* ext/phar/php_phar.h is not installed anymore

</details>
