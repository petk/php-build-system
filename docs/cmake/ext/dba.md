<!-- This is auto-generated file. -->
* Source code: [ext/dba/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/ext/dba/CMakeLists.txt)

# The dba extension

Configure the `dba` extension.

This extension provides the database (dbm-style) abstraction layer.

## PHP_EXT_DBA

* Default: `OFF`
* Values: `ON|OFF`

Enable the PHP `dba` extension.

## PHP_EXT_DBA_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared library.

## PHP_EXT_DBA_CDB

* Default: `ON`
* Values: `ON|OFF`

Enable the constant databases (cdb) handler.

## PHP_EXT_DBA_CDB_EXTERNAL

* Default: `OFF`
* Values: `ON|OFF`

Use external (system) cdb library instead of the bundled sources.

> [!WARNING]
> At the time of writing external cdb library installed on \*nix systems is most
> likely tinycdb, which isn't supported by PHP. Recommendation is to not enable
> this option and use the bundled cdb library that comes with PHP sources.

## PHP_EXT_DBA_DB

* Default: `OFF`
* Values: `ON|OFF`

Enable the Oracle Berkeley DB handler.

## PHP_EXT_DBA_DB1

* Default: `OFF`
* Values: `ON|OFF`

Enable the Oracle Berkeley DB 1.x support/emulation.

## PHP_EXT_DBA_DBM

* Default: `OFF`
* Values: `ON|OFF`

Enable the legacy (original) Berkeley DB style (Database Manager) handler.

## PHP_EXT_DBA_FLATFILE

* Default: `ON`
* Values: `ON|OFF`

Enable the bundled flat-file DBA handler.

## PHP_EXT_DBA_INIFILE

* Default: `ON`
* Values: `ON|OFF`

Enable the bundled INI-file DBA handler.

## PHP_EXT_DBA_LMDB

* Default: `OFF`
* Values: `ON|OFF`

Enable the Lightning Memory-Mapped Database (LMDB) handler.

## PHP_EXT_DBA_NDBM

* Default: `OFF`
* Values: `ON|OFF`

Enable the ndbm (new dbm) handler.

## PHP_EXT_DBA_QDBM

* Default: `OFF`
* Values: `ON|OFF`

Enable the QDBM (Quick Database Manager) handler

## PHP_EXT_DBA_TCADB

* Default: `OFF`
* Values: `ON|OFF`

Enable the Tokyo Cabinet abstract DB handler.
