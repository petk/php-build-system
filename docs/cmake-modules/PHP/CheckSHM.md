# PHP/CheckSHM

Check for shared memory (SHM) operations functions and required libraries.

If no SHM support is found, a FATAL error is thrown.

Cache variables:

* `HAVE_SHM_IPC`
  Whether SysV IPC SHM support is available.
* `HAVE_SHM_MMAP_ANON`
  Whether `mmap(MAP_ANON)` SHM support is found.
* `HAVE_SHM_MMAP_POSIX`
  Whether POSIX `mmap()` SHM support is found.

IMPORTED target:

* `PHP::CheckSHMLibrary`
  If there is additional library to be linked for using SHM POSIX functions.