# `EXT_ODBC`

Default: `OFF`

Values: `ON|OFF`

Enable the PHP `odbc` extension.

Where to find ODBC installation on the system, can be customized with the
`ODBC_ROOT` variable.

**Additional variables:**

## `EXT_ODBC_SHARED`

Default: `OFF`

Values: `ON|OFF`

Build extension as shared library.

## `EXT_ODBC_TYPE`

Default: `auto`

Values: `auto`, `adabas`, `dbmaker`, `empress-bcs`, `empress`, `esoob`,
`ibm-db2`, `iODBC`, `sapdb`, `solid`, `unixODBC`, or `custom`.

Select the ODBC type.

When using `auto`, ODBC will be searched automatically and first found library
will be used.

When using type other than `auto`, `iODBC`, or `unixODBC`, the `ODBC_LIBRARY`
needs to be set manually to find the ODBC library.

For example:

```sh
cmake -S . -B php-build \
  -D EXT_ODBC=ON \
  -D EXT_ODBC_TYPE=custom \
  -D ODBC_LIBRARY=/usr/lib/x86_64-linux-gnu/libodbc.so
```

Additionally, the ODBC library compile definitions, options, or linker flags can
be added if needed:

```sh
cmake -S . -B php-build \
  -D EXT_ODBC=ON \
  -D EXT_ODBC_TYPE=custom \
  -D ODBC_LIBRARY=/usr/lib/x86_64-linux-gnu/libodbc.so \
  -D ODBC_INCLUDE_DIR=... \
  -D ODBC_COMPILE_DEFINITIONS=... \
  -D ODBC_COMPILE_OPTIONS=... \
  -D ODBC_LINK_OPTIONS=...
```

## `EXT_ODBC_VERSION`

Hex number to force support for the ODBC specification version. By default, it
is set to the highest supported ODBC specification version by PHP. A special
value `0` (zero) or empty value prevents an explicit `ODBCVER` to be defined in
the configuration header.
