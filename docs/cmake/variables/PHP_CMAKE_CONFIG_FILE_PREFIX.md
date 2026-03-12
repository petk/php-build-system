# `PHP_CMAKE_CONFIG_FILE_PREFIX`

* Default: `PHP`

The name of the directory inside the `lib/cmake/` where to install PHP CMake
package config files (`PHPConfig.cmake`). For example, `PHP-8.6` to specify
version or other build-related characteristics and have multiple PHP versions
installed. If absolute path needs to be set, configure `CMAKE_INSTALL_LIBDIR`
instead.

With default install prefix, on *nix systems
`/usr/local/lib/cmake/${PHP_CMAKE_CONFIG_FILE_PREFIX}/`, on Windows
`C:/Program Files/PHP/lib/cmake/${PHP_CMAKE_CONFIG_FILE_PREFIX}/`.
