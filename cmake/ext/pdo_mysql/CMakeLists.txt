include(CMakeDependentOption)

option(EXT_PDO_MYSQL "Whether to enable the pdo_mysql extension" OFF)

cmake_dependent_option(
  EXT_PDO_MYSQL_SHARED
  "Whether to build the pdo_mysql extension as shared object"
  OFF
  "EXT_PDO_MYSQL;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_PDO_MYSQL)
  return()
endif()

if(NOT EXT_PDO_MYSQL_SHARED AND (EXT_MYSQLND_SHARED OR EXT_PDO_SHARED))
  set(EXT_PDO_MYSQL_SHARED ON CACHE BOOL "" FORCE)
endif()

if(EXT_PDO_MYSQL_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

add_library(php_pdo_mysql ${_library_type}
  pdo_mysql.c
  mysql_driver.c
  mysql_statement.c
)

set_target_properties(php_pdo_mysql PROPERTIES PHP_EXT_DEPENDS "php_mysqlnd;php_pdo")

target_compile_definitions(php_pdo_mysql PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

target_include_directories(php_pdo_mysql PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/..")

set(PDO_USE_MYSQLND 1 CACHE INTERNAL "")

if(EXT_MYSQL_SOCK OR EXT_MYSQL_SOCK_PATH)
  include(PHP/MysqlSocket)
endif()

# TODO: Add MySQL configuration script usage.
