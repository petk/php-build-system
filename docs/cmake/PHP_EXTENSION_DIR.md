# `PHP_EXTENSION_DIR`

Default: `${CMAKE_INSTALL_LIBDIR}/php/<ZEND_MODULE_API_NO>(-zts)-${CMAKE_BUILD_TYPE}`

Default directory for dynamically loadable PHP extensions. If left empty, it is
determined automatically. Can be overridden at runtime using the PHP
`extension_dir` INI directive. By default, it is a relative path inside the
installation prefix (`CMAKE_INSTALL_PREFIX`) path. The `ZEND_MODULE_API_NO` is a
value from the `Zend/zend_modules.h`.

For example, default value for the `Release` build type with thread safety
enabled would be `lib/php/20230901-zts-Release`. After the default installation
prefix is prepended, it is `/usr/local/lib/php/202309-zts-Release` (on *nix
systems) and `C:/Program Files/PHP/lib/php/202309-zts-Release` on Windows.
