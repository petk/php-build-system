## `EXT_PDO_ODBC`

Enable the PHP `pdo-odbc` extension.

Default: `OFF`

Values: `ON|OFF`

Where to find ODBC installation on the system, can be customized with the
`ODBC_ROOT` variable.

**Additional variables:**

## `EXT_PDO_ODBC_SHARED`

Build extension as shared library.

Default: `OFF`

Values: `ON|OFF`

## `EXT_PDO_ODBC_TYPE`

Select the ODBC type.

Default: `auto`

Values: `auto`, `ibm-db2`, `iODBC`, `unixODBC`, or `custom`

When using `auto`, ODBC will be searched automatically and first found library
will be used.

When using `custom` or `ibm-db2`, also the `ODBC_LIBRARY` needs to be set
manually to find the ODBC library.

For example:

```sh
cmake -S . -B php-build \
  -D EXT_PDO_ODBC=ON \
  -D EXT_PDO_ODBC_TYPE=custom \
  -D ODBC_LIBRARY=/usr/lib/x86_64-linux-gnu/libodbc.so
```

Additionally, the ODBC library compile definitions, options, or linker flags can
be adjusted if needed:

```sh
cmake -S . -B php-build \
  -D EXT_PDO_ODBC=ON \
  -D EXT_PDO_ODBC_TYPE=custom \
  -D ODBC_LIBRARY=/usr/lib/x86_64-linux-gnu/libodbc.so \
  -D ODBC_INCLUDE_DIR=... \
  -D ODBC_COMPILE_DEFINITIONS=... \
  -D ODBC_COMPILE_OPTIONS=... \
  -D ODBC_LINK_OPTIONS=...
```
