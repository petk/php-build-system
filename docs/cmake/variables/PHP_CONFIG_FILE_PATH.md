# `PHP_CONFIG_FILE_PATH`

* Default: `${CMAKE_INSTALL_SYSCONFDIR}`

The path in which to look for `php.ini`. By default, it is set to the
`CMAKE_INSTALL_SYSCONFDIR` (`etc` directory). Relative path gets the
`CMAKE_INSTALL_PREFIX` automatically prepended. If given as an absolute path,
install prefix is not appended.

> [!NOTE]
> This option is not available when the target system is Windows. On Windows the
> C preprocessor macro isn't utilized in the C code.
