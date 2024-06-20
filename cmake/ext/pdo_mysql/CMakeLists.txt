# TODO: Integrate zlib functionality.

include(CMakeDependentOption)
include(FeatureSummary)

cmake_dependent_option(
  EXT_PDO_MYSQL
  "Enable the pdo_mysql extension"
  OFF
  "EXT_PDO"
  OFF
)

add_feature_info(
  "ext/pdo_mysql"
  EXT_PDO_MYSQL
  "MySQL-compatible database support in PDO (PHP Data Objects) interface"
)

cmake_dependent_option(
  EXT_PDO_MYSQL_SHARED
  "Build the pdo_mysql extension as a shared library"
  OFF
  "EXT_PDO_MYSQL;NOT BUILD_SHARED_LIBS"
  OFF
)

# Driver selection option.
if(EXT_PDO_MYSQL)
  set(
    EXT_PDO_MYSQL_DRIVER "mysqlnd"
    CACHE STRING "Select MySQL driver: mysqlnd (MySQL Native Driver, \
recommended) or mysql (system MySQL)"
  )
  set_property(
    CACHE EXT_PDO_MYSQL_DRIVER
    PROPERTY STRINGS "mysqlnd" "mysql"
  )
  mark_as_advanced(EXT_PDO_MYSQL_DRIVER)
  # Change from INTERNAL type to show variable on consecutive configuration run.
  set_property(CACHE EXT_PDO_MYSQL_DRIVER PROPERTY TYPE STRING)
elseif(DEFINED EXT_PDO_MYSQL_DRIVER)
  # Hide variable.
  set_property(CACHE EXT_PDO_MYSQL_DRIVER PROPERTY TYPE INTERNAL)
endif()

if(NOT EXT_PDO_MYSQL)
  return()
endif()

if(EXT_PDO_MYSQL_SHARED)
  add_library(php_pdo_mysql SHARED)
else()
  add_library(php_pdo_mysql)
endif()

target_sources(
  php_pdo_mysql
  PRIVATE
    mysql_driver.c
    mysql_sql_parser.c
    mysql_statement.c
    pdo_mysql.c
)

add_dependencies(php_pdo_mysql php_pdo)

target_compile_definitions(
  php_pdo_mysql
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
)

if(EXT_MYSQL_SOCKET)
  if(EXT_MYSQL_SOCKET_PATH)
    set(MySQL_Socket_PATH "${EXT_MYSQL_SOCKET_PATH}")
  endif()

  find_package(MySQL OPTIONAL_COMPONENTS Socket)
  set_package_properties(
    MySQL
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to set the MySQL socket in pdo_mysql extension."
  )
endif()

if(MySQL_Socket_PATH)
  set(
    PHP_MYSQL_UNIX_SOCK_ADDR "${MySQL_Socket_PATH}"
    CACHE INTERNAL "MySQL Unix socket pointer"
  )
endif()

if(NOT EXT_PDO_MYSQL_DRIVER STREQUAL "mysql")
  add_dependencies(php_pdo_mysql php_mysqlnd)

  set(PDO_USE_MYSQLND 1 CACHE INTERNAL "Whether pdo_mysql uses mysqlnd")
else()
  find_package(MySQL COMPONENTS Lib OPTIONAL_COMPONENTS Socket)
  set_package_properties(MySQL PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the pdo_mysql extension."
  )

  target_link_libraries(php_pdo_mysql PRIVATE MySQL::MySQL)

  if(MySQL_Socket_PATH)
    set(
      PDO_MYSQL_UNIX_ADDR "${MySQL_Socket_PATH}"
      CACHE INTERNAL "MySQL Unix socket pointer"
    )
  endif()
endif()

if(RE2C_FOUND)
  re2c_target(
    php_pdo_mysql_sql_parser
    mysql_sql_parser.re
    ${CMAKE_CURRENT_SOURCE_DIR}/mysql_sql_parser.c
  )

  add_dependencies(php_generate_files php_pdo_mysql_sql_parser)
endif()
