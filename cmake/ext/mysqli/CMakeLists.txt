include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_MYSQLI "Enable the mysqli extension" OFF)

add_feature_info("ext/mysqli" EXT_MYSQLI
  "MySQL-compatible database support."
)

cmake_dependent_option(
  EXT_MYSQLI_SHARED
  "Build the mysqli extension as a shared library"
  OFF
  "EXT_MYSQLI;NOT BUILD_SHARED_LIBS"
  OFF
)

# Common configuration option for ext/mysqli and ext/pdo_mysql.
cmake_dependent_option(
  EXT_MYSQL_SOCK
  "MySQLi/PDO_MYSQL: Use MySQL Unix socket pointer from default locations."
  OFF
  "EXT_MYSQLI OR EXT_PDO_MYSQL"
  OFF
)

if((EXT_MYSQLI OR EXT_PDO_MYSQL) AND EXT_MYSQL_SOCK)
  set(
    EXT_MYSQL_SOCK_PATH ""
    CACHE FILEPATH
    "MySQLi/PDO_MYSQL: Override MySQL Unix socket pointer location."
  )
  # Change from INTERNAL type to show variable on consecutive configuration run.
  set_property(CACHE EXT_MYSQL_SOCK_PATH PROPERTY TYPE FILEPATH)
elseif(DEFINED EXT_MYSQL_SOCK_PATH)
  # Hide variable.
  set_property(CACHE EXT_MYSQL_SOCK_PATH PROPERTY TYPE INTERNAL)
  unset(PHP_MYSQL_UNIX_SOCK_ADDR CACHE)
endif()

if(NOT EXT_MYSQLI)
  return()
endif()

if(EXT_MYSQLI_SHARED)
  add_library(php_mysqli SHARED)
else()
  add_library(php_mysqli)
endif()

target_sources(
  php_mysqli
  PRIVATE
    mysqli_api.c
    mysqli_driver.c
    mysqli_exception.c
    mysqli_nonapi.c
    mysqli_prop.c
    mysqli_report.c
    mysqli_result_iterator.c
    mysqli_warning.c
    mysqli.c
  PUBLIC
    FILE_SET HEADERS
      BASE_DIRS "${PHP_SOURCE_DIR}"
      FILES
        mysqli_mysqlnd.h
        php_mysqli_structs.h
)

set_target_properties(php_mysqli PROPERTIES PHP_EXTENSION_DEPENDENCIES php_mysqlnd)

target_compile_definitions(php_mysqli PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

if(EXT_MYSQL_SOCK)
  if(EXT_MYSQL_SOCK_PATH)
    set(MySQL_SOCKET "${EXT_MYSQL_SOCK_PATH}")
  endif()

  find_package(MySQL OPTIONAL_COMPONENTS SOCKET)
  set_package_properties(MySQL PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to set the MySQL socket in mysqli extension."
  )
endif()

if(MySQL_SOCKET)
  set(
    PHP_MYSQL_UNIX_SOCK_ADDR "${MySQL_SOCKET}"
    CACHE INTERNAL "MySQL Unix socket pointer"
  )
endif()

install(
  TARGETS php_mysqli
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET HEADERS
)
