include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_PDO "Enable the pdo extension" ON)

add_feature_info(
  "ext/pdo"
  EXT_PDO
  "PHP Data Objects (PDO) support."
)

cmake_dependent_option(
  EXT_PDO_SHARED
  "Build the pdo extension as a shared library"
  OFF
  "EXT_PDO;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_PDO)
  return()
endif()

if(EXT_PDO_SHARED)
  add_library(php_pdo SHARED)
else()
  add_library(php_pdo)
endif()

target_sources(
  php_pdo
  PRIVATE
    pdo_dbh.c
    pdo_sql_parser.c
    pdo_sqlstate.c
    pdo_stmt.c
    pdo.c
  PUBLIC
    FILE_SET HEADERS
      BASE_DIRS "${PHP_SOURCE_DIR}"
      FILES
        php_pdo.h
        php_pdo_driver.h
        php_pdo_error.h
)

set_target_properties(php_pdo PROPERTIES PHP_EXTENSION_DEPENDENCIES php_spl)

if(RE2C_FOUND)
  re2c_target(
    NAME php_pdo_sql_parser
    INPUT "${CMAKE_CURRENT_SOURCE_DIR}/pdo_sql_parser.re"
    OUTPUT "${CMAKE_CURRENT_SOURCE_DIR}/pdo_sql_parser.c"
    OPTIONS "--no-generation-date"
  )
endif()

install(
  TARGETS php_pdo
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET HEADERS
)
