project(
  PhpExtensionPdoOdbc
  LANGUAGES C
)

include(CheckIncludeFile)
include(CheckLibraryExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

cmake_dependent_option(
  EXT_PDO_ODBC
  "Enable the pdo_odbc extension"
  OFF
  "EXT_PDO"
  OFF
)

add_feature_info(
  "ext/pdo_odbc"
  EXT_PDO_ODBC
  "Unified ODBC support in PDO (Open Database Connectivity)"
)

cmake_dependent_option(
  EXT_PDO_ODBC_SHARED
  "Build the pdo_odbc extension as a shared library"
  OFF
  "EXT_PDO_ODBC;NOT BUILD_SHARED_LIBS"
  OFF
)

block()
  if(EXT_PDO_ODBC)
    set(odbc_types
      "ibm-db2"
      "iODBC"
      "unixODBC"
      "generic"
    )

    set(EXT_PDO_ODBC_TYPE "unixODBC" CACHE STRING "The ODBC implementation type")

    set_property(
      CACHE EXT_PDO_ODBC_TYPE
      PROPERTY STRINGS ${odbc_types}
    )

    # Change from INTERNAL type to show variable on consecutive configuration run.
    set_property(CACHE EXT_PDO_ODBC_TYPE PROPERTY TYPE STRING)

    if(NOT EXT_PDO_ODBC_TYPE IN_LIST odbc_types)
      list(JOIN odbc_types ", " odbc_types_string)

      message(
        FATAL_ERROR
        "Unknown PDO ODBC type EXT_PDO_ODBC_TYPE=${EXT_PDO_ODBC_TYPE}. Please "
        "select one of these: ${odbc_types_string}."
      )
    endif()
  elseif(DEFINED EXT_PDO_ODBC_TYPE)
    # Hide variable.
    set_property(CACHE EXT_PDO_ODBC_TYPE PROPERTY TYPE INTERNAL)
  endif()
endblock()

# ODBC library directory.
if(EXT_PDO_ODBC)
  set(
    EXT_PDO_ODBC_ROOT ""
    CACHE PATH "Set the path to ODBC library root directory"
  )
  mark_as_advanced(EXT_PDO_ODBC_ROOT)
  # Change from INTERNAL type to show variable on consecutive configuration run.
  set_property(CACHE EXT_PDO_ODBC_ROOT PROPERTY TYPE PATH)
elseif(DEFINED EXT_PDO_ODBC_ROOT)
  # Hide variable.
  set_property(CACHE EXT_PDO_ODBC_ROOT PROPERTY TYPE INTERNAL)
endif()

# ODBC library name.
if(EXT_PDO_ODBC)
  set(EXT_PDO_ODBC_LIBRARY "" CACHE STRING "Set the ODBC library name")
  mark_as_advanced(EXT_PDO_ODBC_LIBRARY)
  # Change from INTERNAL type to show variable on consecutive configuration run.
  set_property(CACHE EXT_PDO_ODBC_LIBRARY PROPERTY TYPE STRING)
elseif(DEFINED EXT_PDO_ODBC_LIBRARY)
  # Hide variable.
  set_property(CACHE EXT_PDO_ODBC_LIBRARY PROPERTY TYPE INTERNAL)
endif()

# ODBC library linker flags.
if(EXT_PDO_ODBC)
  set(EXT_PDO_ODBC_LDFLAGS "" CACHE STRING "Set the ODBC library linker flags")
  mark_as_advanced(EXT_PDO_ODBC_LDFLAGS)
  # Change from INTERNAL type to show variable on consecutive configuration run.
  set_property(CACHE EXT_PDO_ODBC_LDFLAGS PROPERTY TYPE STRING)
elseif(DEFINED EXT_PDO_ODBC_LDFLAGS)
  # Hide variable.
  set_property(CACHE EXT_PDO_ODBC_LDFLAGS PROPERTY TYPE INTERNAL)
endif()

# ODBC library C flags.
if(EXT_PDO_ODBC)
  set(EXT_PDO_ODBC_CFLAGS "" CACHE STRING "Set the ODBC library C flags")
  mark_as_advanced(EXT_PDO_ODBC_CFLAGS)
  # Change from INTERNAL type to show variable on consecutive configuration run.
  set_property(CACHE EXT_PDO_ODBC_CFLAGS PROPERTY TYPE STRING)
elseif(DEFINED EXT_PDO_ODBC_CFLAGS)
  # Hide variable.
  set_property(CACHE EXT_PDO_ODBC_CFLAGS PROPERTY TYPE INTERNAL)
endif()

if(NOT EXT_PDO_ODBC)
  return()
endif()

if(EXT_PDO_ODBC_SHARED)
  add_library(php_pdo_odbc SHARED)
else()
  add_library(php_pdo_odbc)
endif()

target_sources(
  php_pdo_odbc
  PRIVATE
    odbc_driver.c
    odbc_stmt.c
    pdo_odbc.c
    pdo_odbc.stub.php
)

add_dependencies(php_pdo_odbc php_pdo)

target_include_directories(
  php_pdo_odbc
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/..
)

# TODO: Can this be fixed better?
get_target_property(extension_type php_pdo_odbc TYPE)
if(NOT extension_type MATCHES "^(MODULE|SHARED)_LIBRARY$")
  target_link_libraries(php_pdo_odbc PRIVATE PHP::main)
endif()

if(EXT_PDO_ODBC_TYPE STREQUAL "ibm-db2")
  # Set some sensible default root directory.
  if(NOT EXT_PDO_ODBC_ROOT)
    set(ODBC_ROOT "/home/db2inst1/sqllib")
  endif()
  set(ODBC_TYPE "db2")
elseif(EXT_PDO_ODBC_TYPE STREQUAL "iODBC")
  set(ODBC_TYPE "iodbc")
elseif(EXT_PDO_ODBC_TYPE STREQUAL "unixODBC")
  set(ODBC_TYPE "odbc")
endif()

if(EXT_PDO_ODBC_TYPE STREQUAL "generic" AND EXT_PDO_ODBC_LIBRARY)
  set(PDO_ODBC_TYPE "${EXT_PDO_ODBC_TYPE}-${EXT_PDO_ODBC_LIBRARY}")
else()
  set(PDO_ODBC_TYPE "${EXT_PDO_ODBC_TYPE}")
endif()

if(EXT_PDO_ODBC_ROOT AND NOT ODBC_ROOT)
  set(ODBC_ROOT ${EXT_PDO_ODBC_ROOT})
endif()

if(EXT_PDO_ODBC_LIBRARY AND NOT ODBC_TYPE)
  set(ODBC_TYPE ${EXT_PDO_ODBC_LIBRARY})
endif()

find_package(ODBC)
set_package_properties(
  ODBC
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the pdo_odbc extension."
)

if(TARGET ODBC::ODBC)
  if(EXT_PDO_ODBC_CFLAGS)
    target_compile_options(ODBC::ODBC INTERFACE ${EXT_PDO_ODBC_CFLAGS})
  endif()

  if(EXT_PDO_ODBC_LDFLAGS)
    target_link_options(ODBC::ODBC INTERFACE ${EXT_PDO_ODBC_LDFLAGS})
  endif()

  # Sanity checks.
  block()
    foreach(
      header
      IN ITEMS
        cli0cli.h
        cli0core.h
        cli0defs.h
        cli0env.h
        cli0ext.h
        iodbc.h
        isql.h
        isqlext.h
        LibraryManager.h
        odbc.h
        sql.h
        sqlcli1.h
        sqlext.h
        sqltypes.h
        sqlucode.h
        sqlunix.h
        udbcext.h
    )
      string(MAKE_C_IDENTIFIER "HAVE_${header}" const)
      string(TOUPPER "${const}" const)

      cmake_push_check_state(RESET)
        set(CMAKE_REQUIRED_LIBRARIES ODBC::ODBC)
        check_include_file(${header} ${const})
      cmake_pop_check_state()

      if(${const})
        set(have_headers TRUE)
      endif()
    endforeach()

    if(NOT have_headers)
      message(FATAL_ERROR "Cannot find header file(s) for pdo_odbc")
    endif()
  endblock()

  # Check for an ODBC 1.0 function to assert that the libraries work.
  check_library_exists("${ODBC_LIBRARY}" SQLBindCol "" _HAVE_SQLBINDCOL)

  if(NOT _HAVE_SQLBINDCOL)
    message(
      FATAL_ERROR
      "Could not find the SQLBindCol ODBC 1.0 function in the ODBC library."
    )
  endif()

  # Check for an ODBC 3.0 function to assert that they're *good* libraries.
  check_library_exists("${ODBC_LIBRARIES}" SQLAllocHandle "" _HAVE_SQLALLOCHANDLE)

  if(NOT _HAVE_SQLALLOCHANDLE)
    message(
      FATAL_ERROR
      "Could not find the ODBC 3.0 function SQLAllocHandle in the ODBC "
      "library. Your ODBC library does not appear to be ODBC 3 compatible. You "
      "should consider using iODBC or unixODBC instead, and loading your "
      "libraries as a driver in that environment. It will emulate the "
      "functions required for PDO support."
    )
  endif()
endif()

target_link_libraries(php_pdo_odbc PRIVATE ODBC::ODBC)

configure_file(config.cmake.h.in config.h @ONLY)
