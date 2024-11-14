# PHP/Stubs

See: [Stubs.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/Stubs.cmake)

## Basic usage

```cmake
include(PHP/Stubs)
```

Generate *_arginfo.h headers from the *.stub.php sources

The build/gen_stub.php script requires the PHP tokenizer extension.
