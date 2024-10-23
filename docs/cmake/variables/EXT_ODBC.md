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

Default: `unixODBC`

Select the ODBC type. Can be `adabas`, `dbmaker`, `empress-bcs`, `empress`,
`esoob`, `ibm-db2`, `iODBC`, `sapdb`, `solid`, `unixODBC`, or `generic`.

## `EXT_ODBC_VERSION`

Force support for the passed ODBC version. A hex number is expected. Set it to
empty value to prevent an explicit ODBCVER to be defined. By default, it is set
to the highest supported ODBC version by PHP.
