# PHP embed SAPI

PHP embed SAPI can be built like this:

```sh
./buildconf
./configure --enable-embed
make
```

The embed library is then located in the `libs` directory as shared object
`libs/libphp.so` which can be further used in other applications. It exposes
PHP API as C library object for other programs to use PHP.
