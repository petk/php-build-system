<!-- This is auto-generated file. -->
* Source code: [sapi/fuzzer/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/sapi/fuzzer/CMakeLists.txt)

# The fuzzer SAPI

Configure the `fuzzer` PHP SAPI.

> [!NOTE]
> This SAPI is not available when the target system is Windows.

## PHP_SAPI_FUZZER

* Default: `OFF`
* Values: `ON|OFF`

Enable the fuzzer SAPI module - PHP as Clang fuzzing test module (for
developers). For relevant flags on newer Clang versions see
https://llvm.org/docs/LibFuzzer.html#fuzzer-usage

## LIB_FUZZING_ENGINE

* Default: empty

OSS-Fuzz: C++ compiler argument to link fuzz target against the prebuilt engine
library (e.g. libFuzzer). Can be also environment variable. See
https://google.github.io/oss-fuzz
