include(CMakeDependentOption)

option(EXT_MYSQLI "Whether to enable the mysqli extension" OFF)

cmake_dependent_option(EXT_MYSQLI_SHARED "Whether to build the mysqli extension as shared object" OFF "EXT_MYSQLI;NOT BUILD_SHARED_LIBS" OFF)

cmake_dependent_option(EXT_MYSQLI_SOCK "MySQLi/PDO_MYSQL: Location of the MySQL unix socket pointer. If unspecified, the default locations are searched." OFF "EXT_MYSQLI" OFF)

if(NOT EXT_MYSQLI)
  return()
endif()

if(NOT EXT_MYSQLND)
  message(FATAL_ERROR "The mysqli extension requires mysqlnd extension enabled, add EXT_MYSQLND=ON.")
endif()

if(EXT_MYSQLI_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME mysqli ${_library_type})

add_library(ext_mysqli ${_library_type}
  mysqli.c
  mysqli_api.c
  mysqli_prop.c
  mysqli_nonapi.c
  mysqli_report.c
  mysqli_driver.c
  mysqli_warning.c
  mysqli_exception.c
  mysqli_result_iterator.c
)

target_compile_definitions(ext_mysqli PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

if(EXT_MYSQLI_SOCK)
  include(PHPMysqlSocket)
endif()

target_sources(
  ext_mysqli
  PUBLIC FILE_SET ext_mysqli_headers
  TYPE HEADERS
  FILES php_mysqli_structs.h
)

install(
  TARGETS ext_mysqli
  FILE_SET ext_mysqli_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/mysqli
)
