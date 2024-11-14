# FindAtomic

See: [FindAtomic.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindAtomic.cmake)

## Basic usage

```cmake
find_package(Atomic)
```

Find the atomic instructions.

Module defines the following `IMPORTED` target(s):

* `Atomic::Atomic` - The Atomic library, if found.

Result variables:

* `Atomic_FOUND` - Whether atomic instructions are available.
* `Atomic_LIBRARIES` - A list of libraries needed in order to use atomic
  functionality.
