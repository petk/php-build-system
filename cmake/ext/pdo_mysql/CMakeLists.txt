include(CMakeDependentOption)

option(EXT_PDO_MYSQL "Enable the pdo_mysql extension" OFF)

cmake_dependent_option(
  EXT_PDO_MYSQL_SHARED
  "Build the pdo_mysql extension as a shared library"
  OFF
  "EXT_PDO_MYSQL;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_PDO_MYSQL)
  return()
endif()

if(EXT_PDO_MYSQL_SHARED)
  set(_type "SHARED")
endif()

add_library(php_pdo_mysql ${_type}
  pdo_mysql.c
  mysql_driver.c
  mysql_statement.c
)

set_target_properties(
  php_pdo_mysql
  PROPERTIES PHP_EXTENSION_DEPENDENCIES "php_mysqlnd;php_pdo"
)

target_compile_definitions(php_pdo_mysql PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

target_include_directories(php_pdo_mysql PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/..")

set(PDO_USE_MYSQLND 1 CACHE INTERNAL "")

if(EXT_MYSQL_SOCK OR EXT_MYSQL_SOCK_PATH)
  include(PHP/MysqlSocket)
endif()

# TODO: Add MySQL configuration script usage.
