## `EXT_PDO_ODBC`

Default: `OFF`

Values: `ON|OFF`

Enable the PHP `pdo-odbc` extension.

Where to find ODBC installation on the system, can be customized with the
`ODBC_ROOT` variable.

**Additional variables:**

## `EXT_PDO_ODBC_SHARED`

Default: `OFF`

Values: `ON|OFF`

Build extension as shared library.

## `EXT_PDO_ODBC_TYPE=ibm-db2|iODBC|unixODBC|generic`

Default: `unixODBC`

Select the ODBC type.

## `EXT_PDO_ODBC_ROOT`

Path to the ODBC library root directory.

## `EXT_PDO_ODBC_LIBRARY`

Set the ODBC library name.

## `EXT_PDO_ODBC_CFLAGS`

A list of additional ODBC library compile flags.

## `EXT_PDO_ODBC_LDFLAGS`

A list of additional ODBC library linker flags.
