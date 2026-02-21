<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindPHP.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindPHP.cmake)

# FindPHP

Finds PHP, the general-purpose scripting language:

```cmake
find_package(PHP [<version>] [COMPONENTS <components>...] [...])
```

## Components

This module supports optional components which can be specified using the
find_package() command:

```cmake
find_package(PHP [COMPONENTS <components>...])
```

Supported components include:

* `Interpreter` - Finds the PHP command-line interpreter executable.

## Imported targets

This module provides the following imported targets when `CMAKE_ROLE` is
`PROJECT`:

* `PHP::Interpreter` - Imported executable target encapsulating the PHP
  command-line interpreter usage requirements.

## Result variables

This module defines the following variables:

* `PHP_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `PHP_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `PHP_EXECUTABLE` - PHP command-line tool, if available.

## Hints

* `PHP_ARTIFACTS_PREFIX` - A prefix that will be used for all result and cache
  variables.

  To comply with standard find modules, the `PHP_FOUND` result variable is also
  defined, even if prefix has been specified.

* `PHP_FORCE_AS_FOUND` - If set to a boolean true, it disables finding PHP and
  considers it as found. This module will then not provide further results or
  outputs. This is used when building PHP extensions as bundled inside the
  php-src repository, where the host PHP installation isn't required for a
  successful build as a whole.

## Examples

### Example: Finding PHP

```cmake
# CMakeLists.txt

find_package(PHP)

if(PHP_FOUND)
  message(STATUS "PHP_EXECUTABLE=${PHP_EXECUTABLE}")
  message(STATUS "PHP_VERSION=${PHP_VERSION}")
endif()
```

### Example: Using hint variables

Finding PHP on the host and prefixing the module result/cache variables:

```cmake
set(PHP_ARTIFACTS_PREFIX "_HOST")
find_package(PHP)
unset(PHP_ARTIFACTS_PREFIX)

if(PHP_HOST_FOUND)
  message(STATUS "PHP_HOST_EXECUTABLE=${PHP_HOST_EXECUTABLE}")
  message(STATUS "PHP_HOST_VERSION=${PHP_HOST_VERSION}")
  message(STATUS "Imported target: PHP_HOST::Interpreter")
endif()
```

## Customizing search locations

To customize where to look for the PHP package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `PHP_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/PHP;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DPHP_ROOT=/opt/PHP \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
