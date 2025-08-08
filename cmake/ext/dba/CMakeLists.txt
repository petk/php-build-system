#[=============================================================================[
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
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.2)

project(
  PhpExtensionDba
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_DBA "Enable the dba extension")
add_feature_info(
  "ext/dba"
  PHP_EXT_DBA
  "dbm-style database abstraction"
)

cmake_dependent_option(
  PHP_EXT_DBA_SHARED
  "Build the dba extension as a shared library"
  OFF
  PHP_EXT_DBA
  OFF
)

cmake_dependent_option(
  PHP_EXT_DBA_CDB
  "DBA: Enable the constant databases (cdb) handler"
  ON
  PHP_EXT_DBA
  OFF
)
mark_as_advanced(PHP_EXT_DBA_CDB)
add_feature_info(
  "ext/dba cdb"
  PHP_EXT_DBA_CDB
  "constant databases handler"
)

cmake_dependent_option(
  PHP_EXT_DBA_CDB_EXTERNAL
  "DBA: Use external (system) cdb library instead of the bundled sources"
  OFF
  [[PHP_EXT_DBA AND PHP_EXT_DBA_CDB]]
  OFF
)
mark_as_advanced(PHP_EXT_DBA_CDB_EXTERNAL)
add_feature_info(
  "ext/dba cdb external"
  PHP_EXT_DBA_CDB_EXTERNAL
  "system cdb library instead of bundled"
)

cmake_dependent_option(
  PHP_EXT_DBA_DB
  "DBA: Enable the Oracle Berkeley DB handler"
  OFF
  PHP_EXT_DBA
  OFF
)
mark_as_advanced(PHP_EXT_DBA_DB)
add_feature_info(
  "ext/dba DB"
  PHP_EXT_DBA_DB
  "Berkeley DB handler"
)

cmake_dependent_option(
  PHP_EXT_DBA_DB1
  "DBA: Enable the Oracle Berkeley DB 1.x support/emulation"
  OFF
  [[PHP_EXT_DBA AND PHP_EXT_DBA_DB]]
  OFF
)
mark_as_advanced(PHP_EXT_DBA_DB1)
add_feature_info(
  "ext/dba DB 1"
  PHP_EXT_DBA_DB1
  "Berkeley DB 1.x support/emulation"
)

cmake_dependent_option(
  PHP_EXT_DBA_DBM
  "DBA: Enable the legacy (original) Berkeley DB style handler"
  OFF
  [[PHP_EXT_DBA AND NOT PHP_EXT_DBA_QDBM]]
  OFF
)
mark_as_advanced(PHP_EXT_DBA_DBM)
add_feature_info(
  "ext/dba DBM"
  PHP_EXT_DBA_DBM
  "legacy (original) Berkeley DB handler"
)

cmake_dependent_option(
  PHP_EXT_DBA_FLATFILE
  "DBA: Enable the bundled flat-file handler"
  ON
  PHP_EXT_DBA
  OFF
)
mark_as_advanced(PHP_EXT_DBA_FLATFILE)
add_feature_info(
  "ext/dba flat-file"
  PHP_EXT_DBA_FLATFILE
  "bundled flat-file handler"
)

cmake_dependent_option(
  PHP_EXT_DBA_INIFILE
  "DBA: Enable the bundled INI-file handler"
  ON
  PHP_EXT_DBA
  OFF
)
mark_as_advanced(PHP_EXT_DBA_INIFILE)
add_feature_info(
  "ext/dba INI-file"
  PHP_EXT_DBA_INIFILE
  "bundled INI-file handler"
)

cmake_dependent_option(
  PHP_EXT_DBA_LMDB
  "DBA: Enable the Lightning Memory-Mapped Database (LMDB) handler"
  OFF
  PHP_EXT_DBA
  OFF
)
add_feature_info(
  "ext/dba LMDB"
  PHP_EXT_DBA_LMDB
  "Lightning Memory-Mapped Database handler"
)

cmake_dependent_option(
  PHP_EXT_DBA_NDBM
  "DBA: Enable the new dbm (ndbm) handler"
  OFF
  PHP_EXT_DBA
  OFF
)
mark_as_advanced(PHP_EXT_DBA_NDBM)
add_feature_info(
  "ext/dba ndbm"
  PHP_EXT_DBA_NDBM
  "new dbm handler"
)

cmake_dependent_option(
  PHP_EXT_DBA_QDBM
  "DBA: Enable the Quick Database Manager (QDBM) handler"
  OFF
  [[PHP_EXT_DBA AND NOT PHP_EXT_DBA_DBM]]
  OFF
)
add_feature_info(
  "ext/dba QDBM"
  PHP_EXT_DBA_QDBM
  "Quick Database Manager handler"
)
if(PHP_EXT_DBA_QDBM AND PHP_EXT_DBA_DBM)
  message(
    FATAL_ERROR
    "You cannot combine 'PHP_EXT_DBA_DBM' with 'PHP_EXT_DBA_QDBM'. Please "
    "select either DBM or QDBM."
  )
endif()

cmake_dependent_option(
  PHP_EXT_DBA_TCADB
  "DBA: Enable the Tokyo Cabinet abstract DB handler"
  OFF
  PHP_EXT_DBA
  OFF
)
add_feature_info(
  "ext/dba TCADB"
  PHP_EXT_DBA_TCADB
  "Tokyo Cabinet handler"
)

if(NOT PHP_EXT_DBA)
  return()
endif()

if(PHP_EXT_DBA_SHARED)
  add_library(php_ext_dba MODULE)
else()
  add_library(php_ext_dba OBJECT)
endif()

target_sources(
  php_ext_dba
  PRIVATE
    dba.c
    dba.stub.php
)

target_compile_definitions(php_ext_dba PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

################################################################################
# Constant databases (cdb).
################################################################################
if(PHP_EXT_DBA_CDB)
  target_sources(php_ext_dba PRIVATE dba_cdb.c)
  set(DBA_CDB TRUE)

  if(PHP_EXT_DBA_CDB_EXTERNAL)
    find_package(Cdb)
    set_package_properties(
      Cdb
      PROPERTIES
        TYPE REQUIRED
        PURPOSE "Necessary to enable the cdb handler in the dba extension."
    )
    target_link_libraries(php_ext_dba PRIVATE Cdb::Cdb)

    set(CDB_INCLUDE_FILE "<cdb.h>")

    # At the time of writing external cdb library installed on *nix systems is
    # most likely tinycdb, which isn't supported by PHP.
    message(
      WARNING
      "When using external tinycdb library, it has different cdb_findnext() "
      "signature, cdb_make* functions and doesn't use legacy uint32 type. PHP "
      "source code isn't adjusted for using it yet. Recommendation is to "
      "disable the 'PHP_EXT_DBA_CDB_EXTERNAL' (set it to 'OFF'), which will "
      "use the cdb library bundled with PHP."
    )
  else()
    target_sources(
      php_ext_dba
      PRIVATE
        libcdb/cdb.c
        libcdb/cdb_make.c
        libcdb/uint32.c
    )
    set(DBA_CDB_BUILTIN TRUE)
  endif()
endif()

################################################################################
# Berkeley DB.
################################################################################
if(PHP_EXT_DBA_DB)
  if(PHP_EXT_DBA_DB1)
    set(BerkeleyDB_USE_DB1 TRUE)
  endif()

  find_package(BerkeleyDB)
  set_package_properties(
    BerkeleyDB
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the Berkeley DB handler in the dba extension."
  )
  target_link_libraries(php_ext_dba PRIVATE BerkeleyDB::BerkeleyDB)

  # Check whether the Berkeley DB version is supported by PHP.
  get_target_property(type php_ext_dba TYPE)
  if(
    BerkeleyDB_VERSION VERSION_GREATER_EQUAL 4.1
    AND BerkeleyDB_VERSION VERSION_LESS 4.1.25
  )
    message(
      FATAL_ERROR
      "Berkeley DB version ${BerkeleyDB_VERSION} is not supported. Supported "
      "versions are earlier than 4.1 or 4.1.25 and newer."
    )
  elseif(
    type MATCHES "^(MODULE|SHARED)_LIBRARY$"
    AND BerkeleyDB_VERSION VERSION_LESS 3.3
  )
    message(
      FATAL_ERROR
      "When building dba extension as shared, at least Berkeley DB version 3.3 "
      "is required. Found Berkeley DB version ${BerkeleyDB_VERSION}. Either "
      "the Berkeley DB should be upgraded or set the 'PHP_EXT_DBA_SHARED' to "
      "'OFF'."
    )
  endif()

  if(BerkeleyDB_DB1_INCLUDE_DIR)
    set(DB1_INCLUDE_FILE "<db_185.h>")
    set(DBA_DB1 TRUE)
    set(DB1_VERSION "Berkeley DB 1.85 emulation in DB")
    target_sources(php_ext_dba PRIVATE dba_db1.c)
  endif()

  if(BerkeleyDB_VERSION VERSION_LESS_EQUAL 1 AND NOT PHP_EXT_DBA_DB1)
    set(DB1_INCLUDE_FILE "<db.h>")
    set(DBA_DB1 TRUE)
    set(DB1_VERSION "Unknown DB1")
    target_sources(php_ext_dba PRIVATE dba_db1.c)
  elseif(BerkeleyDB_VERSION VERSION_LESS_EQUAL 2)
    set(DB2_INCLUDE_FILE "<db.h>")
    set(DBA_DB2 TRUE)
    target_sources(php_ext_dba PRIVATE dba_db2.c)
  elseif(BerkeleyDB_VERSION VERSION_LESS_EQUAL 3)
    set(DB3_INCLUDE_FILE "<db.h>")
    set(DBA_DB3 TRUE)
    target_sources(php_ext_dba PRIVATE dba_db3.c)
  else()
    set(DB4_INCLUDE_FILE "<db.h>")
    set(DBA_DB4 TRUE)
    target_sources(php_ext_dba PRIVATE dba_db4.c)
  endif()
endif()

################################################################################
# DBM.
################################################################################
if(PHP_EXT_DBA_DBM)
  find_package(Dbm)
  set_package_properties(
    Dbm
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the DBM handler in the dba extension."
  )

  target_link_libraries(php_ext_dba PRIVATE Dbm::Dbm)

  target_sources(php_ext_dba PRIVATE dba_dbm.c)

  set(DBM_INCLUDE_FILE "<dbm.h>")
  set(DBA_DBM TRUE)
  set(DBM_VERSION "DBM")
endif()

################################################################################
# Flat-file.
################################################################################
if(PHP_EXT_DBA_FLATFILE)
  target_sources(
    php_ext_dba
    PRIVATE
      dba_flatfile.c
      libflatfile/flatfile.c
  )

  set(DBA_FLATFILE TRUE)
endif()

################################################################################
# INI-file.
################################################################################
if(PHP_EXT_DBA_INIFILE)
  target_sources(
    php_ext_dba
    PRIVATE
      dba_inifile.c
      libinifile/inifile.c
  )

  set(DBA_INIFILE TRUE)
endif()

################################################################################
# LMDB.
################################################################################
if(PHP_EXT_DBA_LMDB)
  find_package(LMDB)
  set_package_properties(
    LMDB
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the LMDB handler in the dba extension."
  )

  target_link_libraries(php_ext_dba PRIVATE LMDB::LMDB)

  target_sources(php_ext_dba PRIVATE dba_lmdb.c)

  set(LMDB_INCLUDE_FILE "<lmdb.h>")
  set(DBA_LMDB TRUE)
endif()

################################################################################
# ndbm.
################################################################################
if(PHP_EXT_DBA_NDBM)
  find_package(Ndbm)
  set_package_properties(
    Ndbm
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the ndbm handler in the dba extension."
  )

  target_link_libraries(php_ext_dba PRIVATE Ndbm::Ndbm)

  target_sources(php_ext_dba PRIVATE dba_ndbm.c)

  set(NDBM_INCLUDE_FILE "<ndbm.h>")
  set(DBA_NDBM TRUE)
endif()

################################################################################
# QDBM.
################################################################################
if(PHP_EXT_DBA_QDBM AND NOT PHP_EXT_DBA_DBM)
  find_package(QDBM)
  set_package_properties(
    QDBM
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the QDBM handler in the dba extension."
  )

  target_link_libraries(php_ext_dba PRIVATE QDBM::QDBM)

  target_sources(php_ext_dba PRIVATE dba_qdbm.c)

  set(QDBM_INCLUDE_FILE "<depot.h>")
  set(DBA_QDBM TRUE)
endif()

################################################################################
# Tokyo Cabinet.
################################################################################
if(PHP_EXT_DBA_TCADB)
  find_package(TokyoCabinet)
  set_package_properties(
    TokyoCabinet
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the Tokyo Cabinet handler in the dba extension."
  )

  target_link_libraries(php_ext_dba PRIVATE TokyoCabinet::TokyoCabinet)

  target_sources(php_ext_dba PRIVATE dba_tcadb.c)

  set(TCADB_INCLUDE_FILE "<tcadb.h>")
  set(DBA_TCADB TRUE)
endif()

set(HAVE_DBA TRUE)

configure_file(cmake/config.h.in config.h)
