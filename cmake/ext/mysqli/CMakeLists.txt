include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_MYSQLI "Enable the mysqli extension" OFF)

add_feature_info(
  "ext/mysqli"
  EXT_MYSQLI
  "MySQL-compatible database support"
)

cmake_dependent_option(
  EXT_MYSQLI_SHARED
  "Build the mysqli extension as a shared library"
  OFF
  "EXT_MYSQLI;NOT BUILD_SHARED_LIBS"
  OFF
)

# Common configuration option for mysqli and pdo_mysql extensions.
cmake_dependent_option(
  EXT_MYSQL_SOCKET
  "mysqli/pdo_mysql: Use MySQL Unix socket pointer from default locations"
  OFF
  [[(EXT_MYSQLI OR EXT_PDO_MYSQL) AND NOT CMAKE_SYSTEM_NAME STREQUAL "Windows"]]
  OFF
)

if((EXT_MYSQLI OR EXT_PDO_MYSQL) AND EXT_MYSQL_SOCKET)
  set(
    EXT_MYSQL_SOCKET_PATH ""
    CACHE FILEPATH
    "mysqli/pdo_mysql: Specify path to the MySQL Unix socket pointer location. \
If unspecified, default locations are searched."
  )
  # Change from INTERNAL type to show variable on consecutive configuration run.
  set_property(CACHE EXT_MYSQL_SOCKET_PATH PROPERTY TYPE FILEPATH)
elseif(DEFINED EXT_MYSQL_SOCKET_PATH)
  # Hide variable.
  set_property(CACHE EXT_MYSQL_SOCKET_PATH PROPERTY TYPE INTERNAL)
  unset(PHP_MYSQL_UNIX_SOCK_ADDR CACHE)
endif()

mark_as_advanced(EXT_MYSQL_SOCKET EXT_MYSQL_SOCKET_PATH)

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
      FILES
        mysqli_mysqlnd.h
        php_mysqli_structs.h
)

add_dependencies(php_mysqli php_mysqlnd php_spl)

target_compile_definitions(php_mysqli PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

if(EXT_MYSQL_SOCKET)
  if(EXT_MYSQL_SOCKET_PATH)
    set(MySQL_Socket_PATH "${EXT_MYSQL_SOCKET_PATH}")
  endif()

  find_package(MySQL OPTIONAL_COMPONENTS Socket)
  set_package_properties(
    MySQL
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to set the MySQL socket in mysqli extension."
  )
endif()

if(MySQL_Socket_PATH)
  set(
    PHP_MYSQL_UNIX_SOCK_ADDR "${MySQL_Socket_PATH}"
    CACHE INTERNAL "The MySQL Unix socket location."
  )
endif()
