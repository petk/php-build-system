include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_PDO "Enable the pdo extension" ON)

add_feature_info("ext/pdo" EXT_PDO
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

target_sources(php_pdo PRIVATE
  pdo_dbh.c
  pdo_sql_parser.c
  pdo_sqlstate.c
  pdo_stmt.c
  pdo.c
)

if(RE2C_FOUND)
  re2c_target(
    NAME php_pdo_sql_parser
    INPUT "${CMAKE_CURRENT_SOURCE_DIR}/pdo_sql_parser.re"
    OUTPUT "${CMAKE_CURRENT_SOURCE_DIR}/pdo_sql_parser.c"
    OPTIONS "--no-generation-date"
  )
endif()

target_sources(
  php_pdo
  PUBLIC FILE_SET pdo_headers
  TYPE HEADERS
  FILES
    php_pdo.h
    php_pdo_driver.h
    php_pdo_error.h
)

install(
  TARGETS php_pdo
  FILE_SET pdo_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/pdo
)
