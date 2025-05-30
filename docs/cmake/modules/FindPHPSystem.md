<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindPHPSystem.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindPHPSystem.cmake)

# FindPHPSystem

Find external PHP on the system, if installed.

## Result variables

* `PHPSystem_FOUND` - Whether the package has been found.
* `PHPSystem_VERSION` - Package version, if found.

## Cache variables

* `PHPSystem_EXECUTABLE` - PHP command-line tool, if available.

## Customizing search locations

To customize where to look for the PHPSystem package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `PHPSYSTEM_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/PHPSystem;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DPHPSYSTEM_ROOT=/opt/PHPSystem \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
