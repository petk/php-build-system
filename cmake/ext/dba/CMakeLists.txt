project(
  PhpExtensionDba
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_DBA "Enable the dba extension" OFF)
add_feature_info(
  "ext/dba"
  EXT_DBA
  "Database (dbm-style) abstraction layer support"
)

cmake_dependent_option(
  EXT_DBA_SHARED
  "Build the dba extension as a shared library"
  OFF
  [[EXT_DBA AND NOT BUILD_SHARED_LIBS]]
  OFF
)

cmake_dependent_option(
  EXT_DBA_CDB
  "DBA: Enable the bundled constant databases (cdb) support"
  ON
  EXT_DBA
  OFF
)
mark_as_advanced(EXT_DBA_CDB)
add_feature_info(
  "ext/dba cdb"
  EXT_DBA_CDB
  "constant databases support"
)

cmake_dependent_option(
  EXT_DBA_CDB_EXTERNAL
  "DBA: Use external (system) cdb library instead of the bundled sources"
  OFF
  [[EXT_DBA AND EXT_DBA_CDB]]
  OFF
)
mark_as_advanced(EXT_DBA_CDB_EXTERNAL)
add_feature_info(
  "ext/dba cdb external"
  EXT_DBA_CDB_EXTERNAL
  "external (system) cdb library used instead of the bundled sources"
)

cmake_dependent_option(
  EXT_DBA_DB
  "DBA: Enable the Oracle Berkeley DB support"
  OFF
  EXT_DBA
  OFF
)

cmake_dependent_option(
  EXT_DBA_DB1
  "DBA: Enable the Oracle Berkeley DB 1.x support/emulation"
  OFF
  [[EXT_DBA AND EXT_DBA_DB]]
  OFF
)

cmake_dependent_option(
  EXT_DBA_DB2
  "DBA: Enable the Oracle Berkeley DB 2.x support"
  OFF
  EXT_DBA
  OFF
)

cmake_dependent_option(
  EXT_DBA_DB3
  "DBA: Enable the Oracle Berkeley DB 3.x support"
  OFF
  EXT_DBA
  OFF
)

cmake_dependent_option(
  EXT_DBA_DBM
  "DBA: Enable the legacy (original) Berkeley DB style support"
  OFF
  [[EXT_DBA AND NOT EXT_DBA_QDBM]]
  OFF
)
mark_as_advanced(EXT_DBA_DBM)
add_feature_info(
  "ext/dba DBM"
  EXT_DBA_DBM
  "legacy (original) Berkeley DB style support"
)

cmake_dependent_option(
  EXT_DBA_FLATFILE
  "DBA: Enable the bundled flat-file DBA handler support"
  ON
  EXT_DBA
  OFF
)
mark_as_advanced(EXT_DBA_FLATFILE)
add_feature_info(
  "ext/dba flat file"
  EXT_DBA_FLATFILE
  "bundled flat-file DBA handler support"
)

cmake_dependent_option(
  EXT_DBA_GDBM
  "DBA: Enable the GNU dbm (GDBM) support"
  OFF
  [[EXT_DBA AND NOT EXT_DBA_QDBM]]
  OFF
)
add_feature_info(
  "ext/dba GDBM"
  EXT_DBA_GDBM
  "GNU dbm support"
)

cmake_dependent_option(
  EXT_DBA_INIFILE
  "DBA: Enable the bundled INI-file DBA handler support"
  ON
  EXT_DBA
  OFF
)
mark_as_advanced(EXT_DBA_INIFILE)
add_feature_info(
  "ext/dba INI file"
  EXT_DBA_INIFILE
  "bundled INI-file DBA handler support"
)

cmake_dependent_option(
  EXT_DBA_LMDB
  "DBA: Enable the Lightning Memory-Mapped Database (LMDB) support"
  OFF
  EXT_DBA
  OFF
)
add_feature_info(
  "ext/dba LMDB"
  EXT_DBA_LMDB
  "Lightning Memory-Mapped Database support"
)

cmake_dependent_option(
  EXT_DBA_NDBM
  "DBA: Enable the ndbm support"
  OFF
  EXT_DBA
  OFF
)
add_feature_info(
  "ext/dba ndbm"
  EXT_DBA_NDBM
  "new dbm support"
)

cmake_dependent_option(
  EXT_DBA_QDBM
  "DBA: Enable the QDBM support"
  OFF
  [[EXT_DBA AND NOT EXT_DBA_DBM AND NOT EXT_DBA_GDBM]]
  OFF
)
add_feature_info(
  "ext/dba QDBM"
  EXT_DBA_QDBM
  "Quick Database Manager support"
)
if(EXT_DBA_QDBM AND EXT_DBA_GDBM)
  message(
    FATAL_ERROR
    "You cannot combine EXT_DBA_GDBM with EXT_DBA_QDBM. Please select either "
    "GDBM or QDBM."
  )
elseif(EXT_DBA_QDBM AND EXT_DBA_DBM)
  message(
    FATAL_ERROR
    "You cannot combine EXT_DBA_DBM with EXT_DBA_QDBM. Please select either "
    "DBM or QDBM."
  )
endif()

cmake_dependent_option(
  EXT_DBA_TCADB
  "DBA: Enable the Tokyo Cabinet abstract DB support"
  OFF
  EXT_DBA
  OFF
)
add_feature_info(
  "ext/dba TCADB"
  EXT_DBA_TCADB
  "Tokyo Cabinet abstract DB support"
)

if(NOT EXT_DBA)
  return()
endif()

if(EXT_DBA_SHARED)
  add_library(php_dba SHARED)
else()
  add_library(php_dba)
endif()

target_sources(
  php_dba
  PRIVATE
    dba_db1.c
    dba_db2.c
    dba_db3.c
    $<$<NOT:$<PLATFORM_ID:Windows>>:dba_db4.c>
    dba.c
    dba.stub.php
)

target_compile_definitions(php_dba PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

if(EXT_DBA_FLATFILE)
  target_sources(
    php_dba
    PRIVATE
      dba_flatfile.c
      libflatfile/flatfile.c
  )

  set(DBA_FLATFILE 1)
endif()

if(EXT_DBA_INIFILE)
  target_sources(
    php_dba
    PRIVATE
      dba_inifile.c
      libinifile/inifile.c
  )

  set(DBA_INIFILE 1)
endif()

# Check for constant databases (cdb) support.
if(EXT_DBA_CDB)
  target_sources(php_dba PRIVATE dba_cdb.c)
  set(DBA_CDB 1)

  if(EXT_DBA_CDB_EXTERNAL)
    find_package(Cdb)
    set_package_properties(
      Cdb
      PROPERTIES
        TYPE REQUIRED
        PURPOSE "Necessary to enable the cdb support in the dba extension."
    )
    target_link_libraries(php_dba PRIVATE Cdb::Cdb)

    set(CDB_INCLUDE_FILE "<cdb.h>")
  else()
    target_sources(
      php_dba
      PRIVATE
        libcdb/cdb.c
        libcdb/cdb_make.c
        libcdb/uint32.c
    )
    set(DBA_CDB_BUILTIN 1)
  endif()
endif()

if(EXT_DBA_LMDB)
  find_package(LMDB)
  set_package_properties(
    LMDB
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the LMDB support in the dba extension."
  )

  target_link_libraries(php_dba PRIVATE LMDB::LMDB)

  target_sources(php_dba PRIVATE dba_lmdb.c)

  set(LMDB_INCLUDE_FILE "<lmdb.h>")
  set(DBA_LMDB 1)
endif()

if(EXT_DBA_TCADB)
  find_package(TokyoCabinet)
  set_package_properties(
    TokyoCabinet
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the Tokyo Cabinet support in the dba extension."
  )

  target_link_libraries(php_dba PRIVATE TokyoCabinet::TokyoCabinet)

  target_sources(php_dba PRIVATE dba_tcadb.c)

  set(TCADB_INCLUDE_FILE "<tcadb.h>")
  set(DBA_TCADB 1)
endif()

if(EXT_DBA_GDBM)
  find_package(GDBM)
  set_package_properties(
    GDBM
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the GDBM support in the dba extension."
  )

  target_link_libraries(php_dba PRIVATE GDBM::GDBM)

  target_sources(php_dba PRIVATE dba_gdbm.c)

  set(GDBM_INCLUDE_FILE "<gdbm.h>")
  set(DBA_GDBM 1)
endif()

if(EXT_DBA_QDBM AND NOT EXT_DBA_DBM AND NOT EXT_DBA_GDBM)
  find_package(QDBM)
  set_package_properties(
    QDBM
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the QDBM support in the dba extension."
  )

  target_link_libraries(php_dba PRIVATE QDBM::QDBM)

  target_sources(php_dba PRIVATE dba_qdbm.c)

  set(QDBM_INCLUDE_FILE "<depot.h>")
  set(DBA_QDBM 1)
endif()

if(EXT_DBA_NDBM)
  find_package(Ndbm)
  set_package_properties(
    Ndbm
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the ndbm support in the dba extension."
  )

  target_link_libraries(php_dba PRIVATE Ndbm::Ndbm)

  target_sources(php_dba PRIVATE dba_ndbm.c)

  set(NDBM_INCLUDE_FILE "<ndbm.h>")
  set(DBA_NDBM 1)
endif()

if(EXT_DBA_DBM)
  find_package(Dbm)
  set_package_properties(
    Dbm
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the DBM support in the dba extension."
  )

  target_link_libraries(php_dba PRIVATE Dbm::Dbm)

  target_sources(php_dba PRIVATE dba_dbm.c)

  set(DBM_INCLUDE_FILE "<dbm.h>")
  set(DBA_DBM 1)
  set(DBM_VERSION "${Dbm_IMPLEMENTATION}")
endif()

if(EXT_DBA_DB)
  if(EXT_DBA_DB1)
    set(BerkeleyDB_USE_DB1 TRUE)
  endif()

  find_package(BerkeleyDB)
  set_package_properties(
    BerkeleyDB
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the Berkeley DB support in the dba extension."
  )

  target_link_libraries(php_dba PRIVATE BerkeleyDB::BerkeleyDB)

  if(BerkeleyDB_DB1_INCLUDE_DIR)
    set(DB1_INCLUDE_FILE "<db_185.h>")

    set(DBA_DB1 1)
    set(DB1_VERSION "Berkeley DB 1.85 emulation in DB")
  endif()

  set(DB4_INCLUDE_FILE "<db.h>")
  set(DBA_DB4 1)
endif()

set(HAVE_DBA 1)

configure_file(config.cmake.h.in config.h)
