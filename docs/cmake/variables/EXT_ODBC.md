# `EXT_ODBC`

* Default: `OFF`
* Values: `ON|OFF`

Enable the PHP `odbc` extension.

## `EXT_ODBC_SHARED`

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared library.

## `EXT_ODBC_TYPE`

Select the ODBC type.

Default: `auto`

Values:
  * `auto` - Use this type to find Windows ODBC implementation, unixODBC, iODBC,
    or similar automatically. First found library will be used.
  * `adabas` - When using Adabas database management system.
  * `dbmaker` - When using [DBMaker](https://www.dbmaker.com/).
  * `empress-bcs` - Empress Local Access support, required Empress version is
    8.60 or newer.
  * `empress` - Empress support, required Empress version is 8.60 or newer.
  * `esoob` - Easysoft ODBC-ODBC Bridge support
  * `ibm-db2` - IBM DB2 support.
  * `iODBC` - Independent Open Database Connectivity library
  * `sapdb` - SAP DB support.
  * `solid` - Solid DB support.
  * `unixODBC` - Open Database Connectivity library for *nix systems
  * `custom` - Use this type when using a custom ODBC implementation that cannot
    be found automatically and to manually adjust the compilation options.
    Unlike other special types, PHP code here expects ODBC implementation with
    `<odbc.h>` header.

When using type other than `auto`, `iODBC`, or `unixODBC`, the `ODBC_LIBRARY`
needs to be set manually to find the ODBC library.

For example:

```sh
cmake -S . -B php-build \
  -D EXT_ODBC=ON \
  -D EXT_ODBC_TYPE=custom \
  -D ODBC_LIBRARY=/usr/lib/x86_64-linux-gnu/libodbc.so
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

For example, when using Sybase SQL Anywhere 5.5.00 on QNX:

```sh
cmake -S php-src -B php-build \
  -D EXT_ODBC=ON \
  -D EXT_ODBC_TYPE=custom \
  -D ODBC_LIBRARY=<path-to-libodbc.so> \
  -D ODBC_INCLUDE_DIR=... \
  -D ODBC_COMPILE_DEFINITIONS="-DODBC_QNX -DSQLANY_BUG" \
  -D ODBC_LINK_OPTIONS="-lunix -ldblib"
```

For Adabas:

```sh
cmake -S php-src -B php-build \
  -D EXT_ODBC=ON \
  -D EXT_ODBC_TYPE=adabas \
  -D ODBC_ROOT=/path/to/adabas \
  -D ODBC_LIBRARY=odbc_adabas \
  -D ODBC_INCLUDE_DIR=/path/to/adabas/incl \
  -D ODBC_LINK_OPTIONS="-lsqlptc -lsqlrte"
```

For DBMaker:

```sh
cmake -S php-src -B php-build \
  -D EXT_ODBC=ON \
  -D EXT_ODBC_TYPE=dbmaker \
  -D ODBC_ROOT=/path/to/dbmaker \
  -D ODBC_LIBRARY=dmapic \
```

For Easysoft OOB support:

```sh
cmake -S php-src -B php-build \
  -D EXT_ODBC=ON \
  -D EXT_ODBC_TYPE=esoob \
  -D ODBC_ROOT=/usr/local/easysoft/oob/client \
  -D ODBC_LIBRARY=esoobclient \
```

For Empress:

```sh
cmake -S php-src -B php-build \
  -D EXT_ODBC=ON \
  -D EXT_ODBC_TYPE=empress \
  -D ODBC_ROOT=/path/to/empress \
  -D ODBC_LIBRARY=empodbccl
```

For Empress Local Access:

```sh
cmake -S php-src -B php-build \
  -D EXT_ODBC=ON \
  -D EXT_ODBC_TYPE=empress-bcs \
  -D ODBC_ROOT=/path/to/empress \
  -D ODBC_LIBRARY=empodbcbcs \
  -D ODBC_LINK_OPTIONS="-lempphpbcs -lms -lmscfg -lbasic -lbasic_os -lnlscstab -lnlsmsgtab -lm -ldl -lcrypt"
```

For IBM DB2:

```sh
cmake -S php-src -B php-build \
  -D EXT_ODBC=ON \
  -D EXT_ODBC_TYPE=ibm-db2 \
  -D ODBC_ROOT=/home/db2inst1/sqllib \
  -D ODBC_LIBRARY=db2
```

For Solid DB:

```sh
cmake -S php-src -B php-build \
  -D EXT_ODBC=ON \
  -D EXT_ODBC_TYPE=solid \
  -D ODBC_ROOT=/path/to/solid \
  -D ODBC_LIBRARY=sqlod \
  -D ODBC_INCLUDE_DIR=/path/to/solid/incl
```

> [!WARNING]
> These examples might need to be adjusted and updated for the current ODBC
> versions and implementations.

## `EXT_ODBC_VERSION`

Hex number to force support for the ODBC specification version. By default, it
is set to the highest supported ODBC specification version by PHP. A special
value `0` (zero) or empty value prevents an explicit `ODBCVER` to be defined in
the configuration header.

> [!NOTE]
> ODBC specification version overriding is not supported for `unixODBC` and
> `dbmaker` ODBC types.
