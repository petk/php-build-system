#[=============================================================================[
Searches for MySQL Unix socket location.

The module sets the following variables:

PHP_MYSQL_UNIX_SOCK_ADDR
  Path to the MySQL Unix socket if one has been found.
]=============================================================================]#

set(_sockets
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

message(STATUS "Checking for MySQL Unix socket location")

foreach(socket ${_sockets})
  if(EXISTS ${socket})
    set(PHP_MYSQL_UNIX_SOCK_ADDR "${socket}" CACHE INTERNAL "Path to the MySQL Unix socket")
    message(STATUS "MySQL Unix socket location: ${socket}")
    break()
  endif()
endforeach()

if(NOT PHP_MYSQL_UNIX_SOCK_ADDR)
  message(WARNING "MySQL Unix socket could not be found")
endif()
