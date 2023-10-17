include(CMakeDependentOption)

option(EXT_MYSQLI "Whether to enable the mysqli extension" OFF)

cmake_dependent_option(
  EXT_MYSQLI_SHARED
  "Whether to build the mysqli extension as shared object"
  OFF
  "EXT_MYSQLI;NOT BUILD_SHARED_LIBS"
  OFF
)

# Common configuration option for ext/mysqli and ext/pdo_mysql.
cmake_dependent_option(
  EXT_MYSQL_SOCK
  "MySQLi/PDO_MYSQL: Whether to use the MySQL Unix socket. Default locations for the MySQL Unix socket pointer are searched."
  OFF
  "EXT_MYSQLI OR EXT_PDO_MYSQL"
  OFF
)

if(EXT_MYSQLI OR EXT_PDO_MYSQL)
  set(EXT_MYSQL_SOCK_PATH "" CACHE FILEPATH "MySQLi/PDO_MYSQL: Optional location of the MySQL unix socket pointer.")
endif()

if(NOT EXT_MYSQLI)
  return()
endif()

if(NOT EXT_MYSQLI_SHARED AND EXT_MYSQLND_SHARED)
  set(EXT_MYSQLI_SHARED ON CACHE BOOL "" FORCE)
endif()

if(EXT_MYSQLI_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

add_library(php_mysqli ${_library_type}
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

set_target_properties(php_mysqli PROPERTIES PHP_EXT_DEPENDS php_mysqlnd)

target_compile_definitions(php_mysqli PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

if(EXT_MYSQL_SOCK OR EXT_MYSQL_SOCK_PATH)
  include(PHP/MysqlSocket)
endif()

target_sources(
  php_mysqli
  PUBLIC FILE_SET mysqli_headers
  TYPE HEADERS
  FILES
    mysqli_mysqlnd.h
    php_mysqli_structs.h
)

install(
  TARGETS php_mysqli
  FILE_SET mysqli_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/mysqli
)
