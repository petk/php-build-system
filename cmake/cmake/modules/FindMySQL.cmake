#[=============================================================================[
Find MySQL-compatible (MySQL, MariaDB, Percona, etc.) database.

This is customized find module for PHP ext/mysqli and pdo_mysql extensions. It
searches for MySQL Unix socket pointer and can be extended more in the future.

Components:

  SOCKET
    The MySQL Unix socket pointer.

  LIBRARY
    The MySQL library.

Module defines the following IMPORTED targets:

  MySQL::MySQL
    The MySQL-compatible library, if found, when using the LIBRARY component.

Result variables:

  MySQL_SOCKET
    Path to the MySQL Unix socket if one has been found in the predefined
    default locations. If Mysql_PATH variable is set, the MySQL Unix
    socket pointer is set to it instead.
  MySQL_SOCKET_FOUND
    Whether the MySQL Unix socket pointer has been determined.
  MySQL_CONFIG_EXECUTABLE
    The mysql_config command-line tool on *nix systems to get MySQL installation
    info.
  MySQL_INCLUDE_DIRS
    MySQL include directories.
  MySQL_LIBRARIES
    MySQL libraries.

Hints:
  The MySQL_SOCKET variable can be overridden.

  The MySQL_ROOT variable adds custom search path.
]=============================================================================]#

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(MySQL PROPERTIES
  DESCRIPTION "MySQL-compatible database"
)

# Check if MySQL config command-line tool is available.
find_program(MySQL_CONFIG_EXECUTABLE mysql_config)

set(_reason_failure_message)

# MySQL socket component.
if("SOCKET" IN_LIST MySQL_FIND_COMPONENTS)
  if(NOT MySQL_SOCKET AND MySQL_CONFIG_EXECUTABLE)
    execute_process(
      COMMAND ${MySQL_CONFIG_EXECUTABLE} --socket
      OUTPUT_VARIABLE MySQL_SOCKET
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  endif()

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
    set(MySQL_SOCKET_FOUND TRUE)
  endif()
endif()

# MySQL library component.
if("LIBRARY" IN_LIST MySQL_FIND_COMPONENTS)
  if(MySQL_CONFIG_EXECUTABLE)
    execute_process(
      COMMAND ${MySQL_CONFIG_EXECUTABLE} --variable=pkgincludedir
      OUTPUT_VARIABLE MySQL_INCLUDE_DIRS
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # TODO: This adds unused direct dependencies.
    execute_process(
      COMMAND ${MySQL_CONFIG_EXECUTABLE} --libs
      OUTPUT_VARIABLE MySQL_LIBRARIES
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  else()
    find_path(MySQL_INCLUDE_DIRS mysql.h PATH_SUFFIXES mysql)

    find_library(MySQL_LIBRARIES NAMES mysqlclient mysql)
  endif()

  if(NOT MySQL_INCLUDE_DIRS)
    string(
      APPEND _reason_failure_message
      "\n    The MySQL include dirs not found."
    )
  endif()

  if(NOT MySQL_LIBRARIES)
    string(
      APPEND _reason_failure_message
      "\n    The MySQL library not found."
    )
  endif()

  if(MySQL_INCLUDE_DIRS AND MySQL_LIBRARIES)
    set(MySQL_LIBRARY_FOUND TRUE)
  endif()
endif()

find_package_handle_standard_args(
  MySQL
  HANDLE_COMPONENTS
  REASON_FAILURE_MESSAGE "${_reason_failure_message}"
)

unset(_reason_failure_message)

if(MySQL_LIBRARY_FOUND AND NOT TARGET MySQL::MySQL)
  add_library(MySQL::MySQL INTERFACE IMPORTED)

  set_target_properties(MySQL::MySQL PROPERTIES
    INTERFACE_LINK_LIBRARIES "${MySQL_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${MySQL_INCLUDE_DIRS}"
  )
endif()
