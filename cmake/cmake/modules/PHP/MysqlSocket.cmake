#[=============================================================================[
Searches for MySQL Unix socket location.

The module sets the following variables:

PHP_MYSQL_UNIX_SOCK_ADDR
  Path to the MySQL Unix socket if one has been found in the predefined default
  locations. If EXT_MYSQL_SOCK_PATH variable is set, the MySQL Unix socket
  pointer is set to it instead.
]=============================================================================]#

function(_php_set_mysql_socket)
  if(EXT_MYSQL_SOCK_PATH)
    set(mysql_socket ${EXT_MYSQL_SOCK_PATH})
  else()
    set(sockets
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

    foreach(socket ${sockets})
      if(EXISTS ${socket})
        set(mysql_socket ${socket})
        break()
      endif()
    endforeach()
  endif()

  if(mysql_socket)
    set(PHP_MYSQL_UNIX_SOCK_ADDR "${mysql_socket}" CACHE INTERNAL "Path to the MySQL Unix socket")
  endif()
endfunction()

message(STATUS "Checking for MySQL Unix socket location")

_php_set_mysql_socket()

if(PHP_MYSQL_UNIX_SOCK_ADDR)
  message(STATUS "MySQL Unix socket location: ${PHP_MYSQL_UNIX_SOCK_ADDR}")
else()
  message(WARNING "MySQL Unix socket could not be found")
endif()
