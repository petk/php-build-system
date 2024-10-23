# `PHP_INCLUDE_PREFIX`

Default: `php`

The relative directory inside the `CMAKE_INSTALL_INCLUDEDIR`, where to install
PHP headers. For example, `php/8.5` to specify version or other build-related
characteristics and have multiple PHP versions installed. Absolute paths are
treated as relative. Set `CMAKE_INSTALL_INCLUDEDIR` if absolute path needs to be
set.

With default install prefix, on *nix systems
`/usr/local/include/${PHP_INCLUDE_PREFIX}/`, on Windows
`C:/Program Files/PHP/include/${PHP_INCLUDE_PREFIX}/`.
