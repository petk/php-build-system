# PHP/CheckPtrace

See: [CheckPtrace.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/PHP/CheckPtrace.cmake)

Check for ptrace().

Result variables:

* `PHP_TRACE_TYPE`
  Name of the trace type that should be used in FPM.

Cache variables:

* `HAVE_PTRACE`
  Whether `ptrace()` is present and working as expected.
* `HAVE_MACH_VM_READ`
  Whether `ptrace()` didn't work and the `mach_vm_read()` is present.
* `PROC_MEM_FILE`
  String of the `/proc/pid/mem` interface.
