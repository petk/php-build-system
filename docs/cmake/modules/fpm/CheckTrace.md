<!-- This is auto-generated file. -->
# CheckTrace

* Module source code: [CheckTrace.cmake](https://github.com/petk/php-build-system/blob/master/cmake/sapi/fpm/cmake/CheckTrace.cmake)

Check FPM trace implementation.

## Cache variables:

* `HAVE_PTRACE`

  Whether `ptrace()` is present and working as expected.

* `HAVE_MACH_VM_READ`

  Whether `ptrace()` didn't work and the `mach_vm_read()` is present.

## Result variables

* `PROC_MEM_FILE`

  If neither `ptrace()` or mach_vm_read()` works, the `/proc/pid/<file>`
  interface (`mem` or `as`) is set if found and works as expected.

## Basic usage

```cmake
# CMakeLists.txt
include(cmake/CheckTrace.cmake)
```
