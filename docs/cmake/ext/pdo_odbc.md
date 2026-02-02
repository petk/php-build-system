<!-- This is auto-generated file. -->
* Source code: [ext/pdo_odbc/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/ext/pdo_odbc/CMakeLists.txt)

# The pdo_odbc extension

This extension provides PDO interface for using Unified Open Database
Connectivity (ODBC) databases.

## Configuration options

### PHP_EXT_PDO_ODBC

* Default: `OFF`
* Values: `ON|OFF`

Enables the PHP `pdo-odbc` extension.

### PHP_EXT_PDO_ODBC_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Builds extension as shared library.

### PHP_EXT_PDO_ODBC_TYPE

* Default: `auto`
* Values: `auto`, `ibm-db2`, `iODBC`, `unixODBC`, or `custom`

Selects the ODBC type.

When using `auto`, ODBC will be searched automatically and first found library
will be used.

When using `custom` or `ibm-db2`, also the `ODBC_LIBRARY` needs to be set
manually to find the ODBC library.

For example:

```sh
cmake -S . -B php-build \
  -D PHP_EXT_PDO_ODBC=ON \
  -D PHP_EXT_PDO_ODBC_TYPE=custom \
  -D ODBC_LIBRARY=/usr/lib/x86_64-linux-gnu/libodbc.so
```

For example, IBM DB2:

```sh
cmake -S php-src -B php-build \
  -D PHP_EXT_PDO_ODBC=ON \
  -D PHP_EXT_PDO_ODBC_TYPE=ibm-db2 \
  -D ODBC_ROOT=/home/db2inst1/sqllib \
  -D ODBC_LIBRARY=db2
```

Where to find the installed ODBC library on the system, or to customize ODBC
compile definitions, options, or linker flags can be done with the following
variables:

* `ODBC_COMPILE_DEFINITIONS` - additional compile definitions
* `ODBC_COMPILE_OPTIONS` - additional compile options
* `ODBC_INCLUDE_DIR` - path with the ODBC include header files
* `ODBC_LIBRARY` - ODBC library name or absolute path to the ODBC library
* `ODBC_LINK_OPTIONS` - additional linker options
* `ODBC_ROOT` - the base root directory of the ODBC installation

For example:

```sh
cmake -S . -B php-build \
  -D PHP_EXT_PDO_ODBC=ON \
  -D PHP_EXT_PDO_ODBC_TYPE=custom \
  -D ODBC_LIBRARY=/usr/lib/x86_64-linux-gnu/libodbc.so \
  -D ODBC_INCLUDE_DIR=/usr/include \
  -D ODBC_COMPILE_DEFINITIONS="-DSOME_DEF=1 -DSOME_OTHER_DEF_2=1" \
  -D ODBC_COMPILE_OPTIONS=... \
  -D ODBC_LINK_OPTIONS=...
```
