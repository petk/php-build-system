<!-- This is auto-generated file. -->
# FindAtomic

* Module source code: [FindAtomic.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindAtomic.cmake)

Find the atomic instructions.

Module defines the following `IMPORTED` target(s):

* `Atomic::Atomic` - The Atomic library, if found.

Result variables:

* `Atomic_FOUND` - Whether atomic instructions are available.
* `Atomic_LIBRARIES` - A list of libraries needed in order to use atomic
  functionality.

## Basic usage

```cmake
# CMakeLists.txt
find_package(Atomic)
```

## Customizing search locations

To customize where to look for the Atomic package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `ATOMIC_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> -B <build-dir> -DCMAKE_PREFIX_PATH="/opt/Atomic;/opt/some-other-package"
# or
cmake -S <source-dir> \
    -B <build-dir> \
    -DATOMIC_ROOT=/opt/Atomic \
    -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
