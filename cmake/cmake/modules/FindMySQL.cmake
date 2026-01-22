#[=============================================================================[
# FindMySQL

Finds MySQL-compatible (MySQL, MariaDB, Percona, etc.) database server (MySQL
Unix socket pointer) and MySQL client library:

```cmake
find_package(MySQL [<version>] [COMPONENTS <components>...] [...])
```

## Components

This module supports optional components, which can be specified with:

```cmake
find_package(
  MySQL
  [COMPONENTS <components>...]
  [OPTIONAL_COMPONENTS <components>...]
)
```

Supported components are:

* `Client` - The MySQL client library (libmysqlclient).
* `Server` - The MySQL-compatible database server (provides the Unix socket
  pointer).

If no components are specified, the module searches for the `Server` component
by default.

## Imported targets

This module provides the following imported targets:

* `MySQL::MySQL` - The interface target encapsulating the MySQL-compatible
  client library. This target is available only when the `Client` component was
  found.

## Result variables

This module defines the following variables:

* `MySQL_FOUND` - Boolean indicating whether the (requested version of) package
  with requested components was found.
* `MySQL_VERSION` -  The version of package found.
* `MySQL_Server_FOUND` - Boolean indicating whether the MySQL Unix socket
  pointer has been found.
* `MySQL_SOCKET_PATH` - Path to the MySQL Unix socket as defined by the
  `mysql_config --socket`, or if one was found in the predefined default
  locations. This variable is defined when the `Server` component is specified.
* `MySQL_Client_FOUND` - Boolean indicating whether the `Client` component was
  found.

## Cache variables

The following cache variables may also be set:

* `MySQL_CONFIG_EXECUTABLE` - The `mysql_config` command-line tool for getting
  MySQL installation info.
* `MySQL_INCLUDE_DIR` - Directory containing package library headers.
* `MySQL_LIBRARY` - The path to the MySQL client library.

## Hints

This module accepts the following variables before calling
`find_package(MySQL)`:

* `MySQL_SOCKET_PATH` - This variable can be also overridden from outside the
  module.

## Examples

In the following example, this module is used to find the MySQL client library
and then the imported target is linked to the project target:

```cmake
# CMakeLists.txt

find_package(MySQL COMPONENTS Client)

target_link_libraries(php_foo PRIVATE MySQL::MySQL)
```
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  MySQL
  PROPERTIES
    DESCRIPTION "MySQL-compatible database"
)

set(_reason "")

# Set default components.
if(NOT MySQL_FIND_COMPONENTS)
  set(MySQL_FIND_COMPONENTS Server)
endif()

# Check if MySQL config command-line tool is available.
find_program(
  MySQL_CONFIG_EXECUTABLE
  NAMES mysql_config
  DOC "The mysql_config command-line tool for getting MySQL installation info"
)
mark_as_advanced(MySQL_CONFIG_EXECUTABLE)

# MySQL client library component.
if("Client" IN_LIST MySQL_FIND_COMPONENTS)
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
    find_package(PkgConfig QUIET)
    if(PkgConfig_FOUND)
      pkg_check_modules(PC_MySQL QUIET mysqlclient)
    endif()
  endif()

  find_path(
    MySQL_INCLUDE_DIR
    NAMES mysql.h
    HINTS
      ${_mysql_include_dir}
      ${PC_MySQL_INCLUDE_DIRS}
    PATH_SUFFIXES mysql
    DOC "Directory containing MySQL library headers"
  )

  find_library(
    MySQL_LIBRARY
    NAMES mysqlclient mysql
    NAMES_PER_DIR
    HINTS
      ${_mysql_library_dir}
      ${PC_MySQL_LIBRARY_DIRS}
    DOC "The path to the MySQL library"
  )

  if(NOT MySQL_INCLUDE_DIR)
    string(APPEND _reason "<mysql.h> not found. ")
  endif()

  if(NOT MySQL_LIBRARY)
    string(APPEND _reason "The MySQL library not found. ")
  endif()

  if(MySQL_INCLUDE_DIR AND MySQL_LIBRARY)
    set(MySQL_Client_FOUND TRUE)
  endif()
endif()

# Find the Server component.
if("Server" IN_LIST MySQL_FIND_COMPONENTS)
  if(NOT MySQL_SOCKET_PATH AND MySQL_CONFIG_EXECUTABLE)
    execute_process(
      COMMAND ${MySQL_CONFIG_EXECUTABLE} --socket
      OUTPUT_VARIABLE MySQL_SOCKET_PATH
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )
  endif()

  if(NOT MySQL_SOCKET_PATH)
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
        set(MySQL_SOCKET_PATH ${socket})
        break()
      endif()
    endforeach()
  endif()

  if(NOT MySQL_SOCKET_PATH)
    string(APPEND _reason "MySQL Unix Socket pointer not found. ")
  elseif(NOT EXISTS ${MySQL_SOCKET_PATH})
    string(APPEND _reason "MySQL Unix Socket pointer not found (using default value ${MySQL_SOCKET_PATH}). ")
  else()
    set(MySQL_Server_FOUND TRUE)
  endif()
endif()

# Determine the MySQL package version. The MySQL client library has also some
# internal packaging version scheme (e.g., pkg-config --modversion mysqlclient),
# however, this module looks for the MySQL client version of the public API
# provided by the headers or the mysql_config script, which matches the version
# of the belonging MySQL server package.
block(PROPAGATE MySQL_VERSION)
  if(EXISTS ${MySQL_INCLUDE_DIR}/mysql_version.h)
    set(regex "^#[ \t]*define[ \t]+LIBMYSQL_VERSION[ \t]+\"([0-9.]+)\"[ \t]*$")

    file(STRINGS ${MySQL_INCLUDE_DIR}/mysql_version.h result REGEX "${regex}")

    if(result MATCHES "${regex}")
      set(MySQL_VERSION "${CMAKE_MATCH_1}")
    endif()
  endif()

  if(NOT MySQL_VERSION AND IS_EXECUTABLE ${MySQL_CONFIG_EXECUTABLE})
    execute_process(
      COMMAND ${MySQL_CONFIG_EXECUTABLE} --version
      OUTPUT_VARIABLE MySQL_VERSION
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )
  endif()
endblock()

find_package_handle_standard_args(
  MySQL
  VERSION_VAR MySQL_VERSION
  HANDLE_VERSION_RANGE
  HANDLE_COMPONENTS
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT MySQL_FOUND)
  return()
endif()

if(MySQL_Client_FOUND AND NOT TARGET MySQL::MySQL)
  add_library(MySQL::MySQL UNKNOWN IMPORTED)

  set_target_properties(
    MySQL::MySQL
    PROPERTIES
      IMPORTED_LOCATION "${MySQL_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${MySQL_INCLUDE_DIR}"
  )
endif()
