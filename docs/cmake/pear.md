<!-- This is auto-generated file. -->
* Source code: [pear/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/pear/CMakeLists.txt)

# PEAR

Configure PEAR as part of the PHP installation.

> [!WARNING]
> PEAR installation as part of PHP is deprecated as of PHP 7.4 and will be
> removed in future PHP versions. PEAR can also be installed manually from the
> pear.php.net website.

## PHP_PEAR

:orange_circle: *Deprecated as of PHP 7.4.*

* Default: `OFF`
* Values: `ON|OFF`

Install PEAR, PHP Extension and Application Repository package manager.

## PHP_PEAR_DIR

:orange_circle: *Deprecated as of PHP 7.4.*

* Default: `DATADIR/pear`

The path where PEAR will be installed to. `CMAKE_INSTALL_PREFIX` is
automatically prepended when given as a relative path.

## PHP_PEAR_TEMP_DIR

:orange_circle: *Deprecated as of PHP 7.4.*

* Default: `tmp/pear` on \*nix and `temp/pear` on Windows

The PEAR temporary directory where PEAR writes temporary files, such as cache,
downloaded packages artifacts and similar. Pass it as a relative path inside the
top level system directory, which will be automatically prepended. If given as
an absolute path, top level directory is not prepended. Relative path is added
to the top root system directory (`/` on \*nix, or `C:/` on Windows).

For example, default PEAR temporary directory after the top level system
directory is prepended becomes `/tmp/pear` on \*nix and `C:/temp/pear` on
Windows.
