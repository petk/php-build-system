project(
  PhpExtensionPdoDblib
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_PDO_DBLIB "Enable the pdo_dblib extension" OFF)

add_feature_info(
  "ext/pdo_dblib"
  EXT_PDO_DBLIB
  "Microsoft SQL Server and Sybase database support in PDO (PHP Data Objects)"
)

cmake_dependent_option(
  EXT_PDO_DBLIB_SHARED
  "Build the pdo_dblib extension as a shared library"
  OFF
  "EXT_PDO_DBLIB;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_PDO_DBLIB)
  return()
endif()

if(EXT_PDO_DBLIB_SHARED)
  add_library(php_pdo_dblib SHARED)
else()
  add_library(php_pdo_dblib)
endif()

target_sources(
  php_pdo_dblib
  PRIVATE
    dblib_driver.c
    dblib_stmt.c
    pdo_dblib.c
    pdo_dblib.stub.php
)

add_dependencies(php_pdo_dblib php_pdo)

target_compile_definitions(
  php_pdo_dblib
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
    PDO_DBLIB_FLAVOUR="freetds"
)

find_package(FreeTDS)
set_package_properties(
  FreeTDS
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the pdo_dblib extension."
)

target_link_libraries(php_pdo_dblib PRIVATE FreeTDS::FreeTDS)
