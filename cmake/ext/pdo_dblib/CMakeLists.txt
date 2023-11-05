include(CMakeDependentOption)
include(FeatureSummary)

cmake_dependent_option(
  EXT_PDO_DBLIB
  "Enable the pdo_dblib extension"
  OFF
  "EXT_PDO"
  OFF
)

add_feature_info("ext/pdo_dblib" EXT_PDO_DBLIB
  "Support for Microsoft SQL Server and Sybase in PDO (PHP Data Objects)."
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

target_sources(php_pdo_dblib PRIVATE
  dblib_driver.c
  dblib_stmt.c
  pdo_dblib.c
)

set_target_properties(
  php_pdo_dblib
  PROPERTIES PHP_EXTENSION_DEPENDENCIES php_pdo
)

target_compile_definitions(
  php_pdo_dblib
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
    PDO_DBLIB_FLAVOUR="freetds"
)

target_include_directories(
  php_pdo_dblib
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/.."
)

find_package(FreeTDS)
set_package_properties(FreeTDS PROPERTIES
  TYPE REQUIRED
  PURPOSE "Necessary to enable the pdo_dblib extension."
)

target_link_libraries(php_pdo_dblib PRIVATE FreeTDS::FreeTDS)
