# PHP/CheckPreadPwrite

Check whether `pread()` and `pwrite()` work.

Module first checks whether functions are available on the system, and then
checks if they work as expected. The last checks are for some obsolete systems,
where function declaration with `off64_t` type in the 3rd argument was missing
in the system headers. On modern systems this module is obsolescent in favor of
a simpler:

```cmake
check_symbol_exists(<symbol> unistd.h HAVE_<SYMBOL>)
```

Cache variables:

* `HAVE_PREAD`
    Whether `pread()` is available.
* `PHP_PREAD_64`
    Whether pread64 is default.
* `HAVE_PWRITE`
    Whether `pwrite()` is available.
* `PHP_PWRITE_64`
    Whether pwrite64 is default.
