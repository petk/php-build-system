include(CMakeDependentOption)

cmake_dependent_option(EXT_PDO_MYSQL "Whether to enable the pdo_mysql extension" OFF "EXT_PDO" OFF)

cmake_dependent_option(EXT_PDO_MYSQL_SHARED "Whether to build the pdo_mysql extension as shared object" OFF "EXT_PDO_MYSQL;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_PDO_MYSQL)
  return()
endif()

# TODO: Check if ext/mysqlnd can be enabled from other extensions.
if(NOT EXT_MYSQLND)
  message(FATAL_ERROR "The pdo_mysql extension requires mysqlnd extension enabled, add EXT_MYSQLND=ON.")
endif()

if(EXT_PDO_MYSQL_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME pdo_mysql ${_library_type})

add_library(ext_pdo_mysql ${_library_type}
  pdo_mysql.c
  mysql_driver.c
  mysql_statement.c
)

target_compile_definitions(ext_pdo_mysql PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

target_include_directories(ext_pdo_mysql PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/..")

set(PDO_USE_MYSQLND 1 CACHE INTERNAL "")

if(EXT_MYSQL_SOCK OR EXT_MYSQL_SOCK_PATH)
  include(PHPMysqlSocket)
endif()

# TODO: Add MySQL configuration script usage.
