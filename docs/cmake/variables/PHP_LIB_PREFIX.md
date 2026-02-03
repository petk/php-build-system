# `PHP_LIB_PREFIX`

* Default: `php`

The relative directory inside the `CMAKE_INSTALL_LIBDIR`, where PHP build files
are installed. For example, `php/8.6` to specify version or other build-related
characteristics and have multiple PHP versions installed. Absolute paths are
treated as relative; set `CMAKE_INSTALL_LIBDIR` if absolute path needs to be
set.

With default install prefix, on *nix systems
`/usr/local/lib/${PHP_LIB_PREFIX}/`, on Windows
`C:/Program Files/PHP/lib/${PHP_LIB_PREFIX}/`.
