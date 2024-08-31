#[=============================================================================[
Find MySQL-compatible (MySQL, MariaDB, Percona, etc.) database.

This is customized find module for PHP mysqli and pdo_mysql extensions. It
searches for MySQL Unix socket pointer and can be extended more in the future.

Components:

  Socket
    The MySQL Unix socket pointer.

  Lib
    The MySQL library or client.

Module defines the following IMPORTED target(s):

  MySQL::MySQL
    The MySQL-compatible library, if found, when using the Lib component.

Result variables:

  MySQL_Socket_FOUND
    Whether the MySQL Unix socket pointer has been determined.
  MySQL_Socket_PATH
    Path to the MySQL Unix socket if one has been found in the predefined
    default locations.
  MySQL_Lib_FOUND
    Whether the Lib component has been found.
  MySQL_FOUND
    Whether the package with requested components has been found.
  MySQL_INCLUDE_DIRS
    MySQL include directories.
  MySQL_LIBRARIES
    MySQL libraries.

Cache variables:

  MySQL_CONFIG_EXECUTABLE
    The mysql_config command-line tool for getting MySQL installation info.
  Mysql_INCLUDE_DIR
    Directory containing package library headers.
  Mysql_LIBRARY
    The path to the package library.

Hints:

  The MySQL_Socket_PATH variable can be overridden.

  The MySQL_ROOT variable adds custom search path.
]=============================================================================]#

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  MySQL
  PROPERTIES
    DESCRIPTION "MySQL-compatible database"
)

set(_reason "")

# Check if MySQL config command-line tool is available.
find_program(
  MySQL_CONFIG_EXECUTABLE
  NAMES mysql_config
  DOC "The mysql_config command-line tool for getting MySQL installation info"
)

# Find the Socket component.
if("Socket" IN_LIST MySQL_FIND_COMPONENTS)
  if(NOT MySQL_Socket_PATH AND MySQL_CONFIG_EXECUTABLE)
    execute_process(
      COMMAND ${MySQL_CONFIG_EXECUTABLE} --socket
      OUTPUT_VARIABLE MySQL_Socket_PATH
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )
  endif()

  if(NOT MySQL_Socket_PATH)
    foreach(
      socket
      IN ITEMS
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
      if(EXISTS ${socket})
        set(MySQL_Socket_PATH ${socket})
        break()
      endif()
    endforeach()
  endif()

  if(NOT MySQL_Socket_PATH)
    string(APPEND _reason "MySQL Unix Socket pointer not found. ")
  else()
    set(MySQL_Socket_FOUND TRUE)
  endif()
endif()

# MySQL library component.
if("Lib" IN_LIST MySQL_FIND_COMPONENTS)
  if(MySQL_CONFIG_EXECUTABLE)
    execute_process(
      COMMAND ${MySQL_CONFIG_EXECUTABLE} --variable=pkgincludedir
      OUTPUT_VARIABLE _mysql_include_dir
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )

    execute_process(
      COMMAND ${MySQL_CONFIG_EXECUTABLE} --variable=pkglibdir
      OUTPUT_VARIABLE _mysql_library_dir
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )
  else()
    # Use pkgconf, if available on the system.
    find_package(PkgConfig QUIET)
    pkg_check_modules(PC_MySQL QUIET mysqlclient)
  endif()

  find_path(
    MySQL_INCLUDE_DIR
    NAMES mysql.h
    PATHS
      ${_mysql_include_dir}
      ${PC_MySQL_INCLUDE_DIRS}
    PATH_SUFFIXES mysql
    DOC "Directory containing MySQL library headers"
  )

  find_library(
    MySQL_LIBRARY
    NAMES mysqlclient mysql
    PATHS
      ${_mysql_library_dir}
      ${PC_MySQL_LIBRARY_DIRS}
    DOC "The path to the MySQL library"
  )

  if(NOT MySQL_INCLUDE_DIR)
    string(APPEND _reason "mysql.h not found. ")
  endif()

  if(NOT MySQL_LIBRARY)
    string(APPEND _reason "The MySQL library not found. ")
  endif()

  if(MySQL_INCLUDE_DIR AND MySQL_LIBRARY)
    set(MySQL_Lib_FOUND TRUE)
  endif()
endif()

find_package_handle_standard_args(
  MySQL
  HANDLE_COMPONENTS
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT MySQL_FOUND)
  return()
endif()

if(MySQL_INCLUDE_DIR)
  set(MySQL_INCLUDE_DIRS ${MySQL_INCLUDE_DIR})
endif()

if(MySQL_LIBRARY)
  set(MySQL_LIBRARIES ${MySQL_LIBRARY})
endif()

if(MySQL_Lib_FOUND AND NOT TARGET MySQL::MySQL)
  add_library(MySQL::MySQL UNKNOWN IMPORTED)

  set_target_properties(
    MySQL::MySQL
    PROPERTIES
      IMPORTED_LOCATION "${MySQL_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${MySQL_INCLUDE_DIR}"
  )
endif()
