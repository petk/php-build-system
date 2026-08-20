<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindJXL.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindJXL.cmake)

# FindJXL

Finds the JXL library (libjxl):

```cmake
find_package(JXL [<version>] [COMPONENTS <components>...] [...])
```

## Components

This module supports optional components which can be specified using the
`find_package()` command:

```cmake
find_package(
  JXL
  [COMPONENTS <components>...]
  [OPTIONAL_COMPONENTS <components>...]
  [...]
)
```

Supported components include:

* `jxl` - Finds the main JXL library.
* `jxl_cms` - Finds the JXL CMS (Color Management System) library (available as
  of JXL version 0.9).

If no components are specified, by default, the `jxl` is searched as required
component.

## Imported targets

This module provides the following imported targets:

* `JXL::jxl` - Target encapsulating the main JXL library package usage
  requirements, available if package was found.
* `JXL::jxl_cms` - Target encapsulating the JXL CMS library usage requirements,
  available if JXL CMS library was found.

## Result variables

This module defines the following variables:

* `JXL_FOUND` - Boolean indicating whether (the requested version of)
  package was found.
* `JXL_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `JXL_INCLUDE_DIR` - Directory containing package library headers.
* `JXL_<component>_LIBRARY` - The path to the package library.

## Hints

This module accepts the following variables before calling `find_package(JXL)`:

* `JXL_USE_STATIC_LIBS` - Set this variable to boolean true to search for static
  libraries.

## Examples

### Example: Basic usage

```cmake
# CMakeLists.txt
find_package(JXL)
target_link_libraries(example PRIVATE JXL::jxl)
```

### Example: Using components

```cmake
# CMakeLists.txt
find_package(JXL COMPONENTS jxl jxl_cms)
target_link_libraries(example PRIVATE JXL::jxl JXL::jxl_cms)
```

## Customizing search locations

To customize where to look for the JXL package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `JXL_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/JXL;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DJXL_ROOT=/opt/JXL \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
