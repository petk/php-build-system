# PHP/Install

See: [Install.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/PHP/Install.cmake)

Set the `CMAKE_INSTALL_*` variables inside the `install(CODE|SCRIPT)`.

This is built on top of the CMake's
[`GNUInstallDirs`](https://cmake.org/cmake/help/latest/module/GNUInstallDirs.html)
module and the
[`install()`](https://cmake.org/cmake/help/latest/command/install.html) command.
At the time of writing, CMake documentation mentions special cases where, for
example, the `CMAKE_INSTALL_FULL_SYSCONFDIR` variable becomes the `/etc`, when
the install prefix is `/usr`, and similar.

However, some of these special cases aren't taken into account when using the
`install()` commands. See: https://gitlab.kitware.com/cmake/cmake/-/issues/25852

This module exposes the following function:

```cmake
php_install(CODE <code> ...)
```

It acts the same as `install(CODE <code> ...)`, except that also the
`CMAKE_INSTALL_*` variables are available inside the <code> argument, like in
the rest of the CMake code.

```cmake
php_install(CODE "
  message(STATUS \"CMAKE_INSTALL_SYSCONFDIR=\${CMAKE_INSTALL_SYSCONFDIR}\")
")
```
