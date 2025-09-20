<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindNdbm.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindNdbm.cmake)

# FindNdbm

Finds the ndbm library:

```cmake
find_package(Ndbm)
```

Depending on the system, the nbdm ("new" dbm) can be part of other libraries as
an interface.

* GNU dbm library (GDBM) has compatibility interface via gdbm_compatibility that
  provides ndbm.h header but it is licensed as GPL 3, which is incompatible with
  PHP.
* Built into default libraries (C): BSD-based systems, macOS, Solaris.

## Imported targets

This module provides the following imported targets:

* `Ndbm::Ndbm` - The package library, if found.

## Result variables

* `Ndbm_FOUND` - Boolean indicating whether the package was found.
* `Ndbm_IS_BUILT_IN` - Whether ndbm is a part of the C library.

## Cache variables

* `Ndbm_INCLUDE_DIR` - Directory containing package library headers.
* `Ndbm_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Ndbm)
target_link_libraries(example PRIVATE Ndbm::Ndbm)
```

## Customizing search locations

To customize where to look for the Ndbm package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `NDBM_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/Ndbm;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DNDBM_ROOT=/opt/Ndbm \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
