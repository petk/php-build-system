include(CMakeDependentOption)

option(EXT_PDO "Whether to enable the PDO extension" ON)

cmake_dependent_option(EXT_PDO_SHARED "Whether to build the PDO extension as shared object" OFF "EXT_PDO;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_PDO)
  return()
endif()

re2c_target(
  NAME pdoSqlParser
  INPUT "${CMAKE_CURRENT_SOURCE_DIR}/pdo_sql_parser.re"
  OUTPUT "${CMAKE_CURRENT_SOURCE_DIR}/pdo_sql_parser.c"
  OPTIONS "--no-generation-date"
)

if(EXT_PDO_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "pdo" ${_library_type})

add_library(ext_pdo ${_library_type}
  pdo.c
  pdo_dbh.c
  pdo_stmt.c
  pdo_sql_parser.c
  pdo_sqlstate.c
)

target_sources(
  ext_pdo
  PUBLIC FILE_SET ext_pdo_headers
  TYPE HEADERS
  FILES
    php_pdo.h
    php_pdo_driver.h
    php_pdo_error.h
)

install(
  TARGETS ext_pdo
  FILE_SET ext_pdo_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/pdo
)
