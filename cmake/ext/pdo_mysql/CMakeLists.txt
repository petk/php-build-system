include(CMakeDependentOption)
include(FeatureSummary)

cmake_dependent_option(
  EXT_PDO_MYSQL
  "Enable the pdo_mysql extension"
  OFF
  "EXT_PDO"
  OFF
)

add_feature_info("ext/pdo_mysql" EXT_PDO_MYSQL
  "Adds support for MySQL database to PDO (PHP Data Objects) interface."
)

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
  add_library(php_pdo_mysql SHARED)
else()
  add_library(php_pdo_mysql)
endif()

target_sources(php_pdo_mysql PRIVATE
  pdo_mysql.c
  mysql_driver.c
  mysql_statement.c
)

set_target_properties(
  php_pdo_mysql
  PROPERTIES PHP_EXTENSION_DEPENDENCIES "php_mysqlnd;php_pdo"
)

target_compile_definitions(
  php_pdo_mysql
  PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
)

target_include_directories(
  php_pdo_mysql PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}/.."
)

set(PDO_USE_MYSQLND 1 CACHE INTERNAL "")

if(EXT_MYSQL_SOCK)
  if(EXT_MYSQL_SOCK_PATH)
    set(MySQL_SOCKET "${EXT_MYSQL_SOCK_PATH}")
  endif()

  find_package(MySQL OPTIONAL_COMPONENTS SOCKET)
  set_package_properties(MySQL PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to set the MySQL socket in pdo_mysql extension."
  )
endif()

# TODO: Add MySQL configuration script usage.
