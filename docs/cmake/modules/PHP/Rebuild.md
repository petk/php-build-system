<!-- This is auto-generated file. -->
# PHP/Rebuild

* Module source code: [Rebuild.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/Rebuild.cmake)

Ensure all project targets are rebuilt as needed.

When PHP is not found on the system, the `php_cli` target is used to generate
certain files during development. This can lead to cyclic dependencies among
targets if custom commands depend on the `php_cli` target. While such automatic
rebuilding is not considered good practice, it ensures that all targets are kept
up to date.

TODO: This works only for a limited set of cases for now and will be refactored.

## Basic usage

```cmake
# CMakeLists.txt
include(PHP/Rebuild)
```
