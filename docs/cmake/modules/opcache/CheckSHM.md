<!-- This is auto-generated file. -->
* Source code: [ext/opcache/cmake/CheckSHM.cmake](https://github.com/petk/php-build-system/blob/master/cmake/ext/opcache/cmake/CheckSHM.cmake)

Check for shared memory (SHM) operations functions and required libraries.

If no SHM support is found, a FATAL error is thrown.

## Cache variables

* `HAVE_SHM_IPC`
  Whether SysV IPC SHM support is available.
* `HAVE_SHM_MMAP_ANON`
  Whether `mmap(MAP_ANON)` SHM support is found.
* `HAVE_SHM_MMAP_POSIX`
  Whether POSIX `mmap()` SHM support is found.

IMPORTED target:

* `PHP::CheckSHMLibrary`
  If there is additional library to be linked for using SHM POSIX functions.

## Basic usage

```cmake
# CMakeLists.txt
include(cmake/CheckSHM.cmake)
```
