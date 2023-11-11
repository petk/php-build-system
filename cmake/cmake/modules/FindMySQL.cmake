#[=============================================================================[
Find MySQL database.

This is customized find module for PHP ext/mysqli and pdo_mysql extensions. It
searches for MySQL Unix socket pointer and can be extended more in the future.

Components:

  SOCKET
    The MySQL Unix socket pointer.

Result variables:

  MySQL_SOCKET
    Path to the MySQL Unix socket if one has been found in the predefined
    default locations. If Mysql_PATH variable is set, the MySQL Unix
    socket pointer is set to it instead.

  MySQL_SOCKET_FOUND
    Whether the MySQL Unix socket pointer has been determined.

Cache variables:

  PHP_MYSQL_UNIX_SOCK_ADDR
    If MSQL_SOCKET is determined, it is set to this cache variable.

Hints:
  The MySQL_SOCKET variable can be overridden.
]=============================================================================]#

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(MySQL PROPERTIES
  URL "https://www.mysql.com/"
  DESCRIPTION "Database"
)

if(NOT MySQL_SOCKET)
  set(_mysql_sockets
    /var/run/mysqld/mysqld.sock
    /var/tmp/mysql.sock
    /var/run/mysql/mysql.sock
    /var/lib/mysql/mysql.sock
    /var/mysql/mysql.sock
    /usr/local/mysql/var/mysql.sock
    /Private/tmp/mysql.sock
    /private/tmp/mysql.sock
    /tmp/mysql.sock
  )

  foreach(socket ${_mysql_sockets})
    if(EXISTS ${socket})
      set(MySQL_SOCKET ${socket})
      break()
    endif()
  endforeach()
endif()

if(NOT MySQL_SOCKET)
  string(
    APPEND _reason_failure_message
    "\n    MySQL Unix Socket pointer not found."
  )
else()
  set(
    PHP_MYSQL_UNIX_SOCK_ADDR "${MySQL_SOCKET}"
    CACHE INTERNAL "Path to the MySQL Unix socket"
  )
  set(MySQL_SOCKET_FOUND TRUE)
endif()

find_package_handle_standard_args(
  MySQL
  HANDLE_COMPONENTS
  REASON_FAILURE_MESSAGE "${_reason_failure_message}"
)
