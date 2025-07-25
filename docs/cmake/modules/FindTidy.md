<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindTidy.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindTidy.cmake)

# FindTidy

Finds the Tidy library (tidy-html5, legacy htmltidy library, or the tidyp -
obsolete fork):

```cmake
find_package(Tidy)
```

## Imported targets

This module defines the following imported targets:

* `Tidy::Tidy` - The package library, if found.

## Result variables

* `Tidy_FOUND` - Whether the package has been found.
* `Tidy_INCLUDE_DIRS` - Include directories needed to use this package.
* `Tidy_LIBRARIES` - Libraries needed to link to the package library.
* `Tidy_VERSION` - Package version, if found.

## Cache variables

* `Tidy_INCLUDE_DIR` - Directory containing package library headers.
* `Tidy_LIBRARY` - The path to the package library.
* `HAVE_TIDYBUFFIO_H` - Whether tidybuffio.h is available.
* `HAVE_TIDY_H` - Whether `tidy.h` is available.
* `HAVE_TIDYP_H` - If `tidy.h` is not available and whether the `tidyp.h` is
  available (tidy fork).

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Tidy)
target_link_libraries(example PRIVATE Tidy::Tidy)
```

## Customizing search locations

To customize where to look for the Tidy package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `TIDY_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/Tidy;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DTIDY_ROOT=/opt/Tidy \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
