# PHP/StandardLibrary

Determine the C standard library used for the build.

Result variables:

* `PHP_C_STANDARD_LIBRARY`

  Lowercase name of the C standard library:

    * `dietlibc`
    * `glibc`
    * `llvm`
    * `mscrt`
    * `musl`
    * `uclibc`

Cache variables:
* `__MUSL__`