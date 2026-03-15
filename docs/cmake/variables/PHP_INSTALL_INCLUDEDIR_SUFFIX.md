# `PHP_INSTALL_INCLUDEDIR_SUFFIX`

* Default: `php`

The relative directory inside the `CMAKE_INSTALL_INCLUDEDIR`, where to install
PHP headers. For example, `php/8.6` to specify version or other build-related
characteristics and have multiple PHP versions installed. Absolute paths are
treated as relative. Set `CMAKE_INSTALL_INCLUDEDIR` if absolute path needs to be
set.

With default install prefix, on *nix systems
`/usr/local/include/${PHP_INSTALL_INCLUDEDIR_SUFFIX}/`, on Windows
`C:/Program Files/PHP/include/${PHP_INSTALL_INCLUDEDIR_SUFFIX}/`.
