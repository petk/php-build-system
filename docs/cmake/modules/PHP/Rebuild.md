# PHP/Rebuild

See: [Rebuild.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/Rebuild.cmake)

## Basic usage

```cmake
include(PHP/Rebuild)
```

Ensure all project targets are rebuilt as needed.

When PHP is not found on the system, the `php_cli` target is used to generate
certain files during development. This can lead to cyclic dependencies among
targets if custom commands depend on the `php_cli` target. While such automatic
rebuilding is not considered good practice, it ensures that all targets are kept
up to date.

TODO: This works only for a limited set of cases for now and will be refactored.
