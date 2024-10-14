# PHP/Rebuild

See: [Rebuild.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/PHP/Rebuild.cmake)

Rebuild all project targets.

When PHP is not found on the system, PHP generates some files during development
using the php_cli target itself, which can bring cyclic dependencies among
targets if custom commands would depend on the php_cli target. Although not a
good practice, this helps bringing all targets to updated state.
