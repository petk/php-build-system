<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindNdbm.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindNdbm.cmake)

# FindNdbm

Find the ndbm library.

Depending on the system, the nbdm ("new" dbm) can be part of other libraries as
an interface.

* GNU dbm library (GDBM) has compatibility interface via gdbm_compatibility that
  provides ndbm.h header but it is licensed as GPL 3, which is incompatible with
  PHP.
* Built into default libraries (C): BSD-based systems, macOS, Solaris.

Module defines the following `IMPORTED` target(s):

* `Ndbm::Ndbm` - The package library, if found.

## Result variables

* `Ndbm_FOUND` - Whether the package has been found.
* `Ndbm_IS_BUILT_IN` - Whether ndbm is a part of the C library.
* `Ndbm_INCLUDE_DIRS` - Include directories needed to use this package.
* `Ndbm_LIBRARIES` - Libraries needed to link to the package library.

## Cache variables

* `Ndbm_INCLUDE_DIR` - Directory containing package library headers.
* `Ndbm_LIBRARY` - The path to the package library.

## Usage

```cmake
# CMakeLists.txt
find_package(Ndbm)
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
