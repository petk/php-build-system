# TODO: Add support for the rest of the ODBC types.

include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_ODBC "Enable the odbc extension" OFF)

add_feature_info(
  "ext/odbc"
  EXT_ODBC
  "Unified ODBC databases support (Open Database Connectivity)"
)

cmake_dependent_option(
  EXT_ODBC_SHARED
  "Build the odbc extension as a shared library"
  OFF
  "EXT_ODBC;NOT BUILD_SHARED_LIBS"
  OFF
)

if(EXT_ODBC)
  set(EXT_ODBC_TYPE "unixODBC" CACHE STRING "The ODBC implementation type")

  # Change from INTERNAL type to show variable on consecutive configuration run.
  set_property(CACHE EXT_ODBC_TYPE PROPERTY TYPE STRING)

  block()
    set(odbc_types
      # TODO: "Adabas D" vs "Adabas".
      "adabas"
      "dbmaker"
      "empress-bcs"
      "empress"
      "esoob"
      "ibm-db2"
      "iODBC"
      "sapdb"
      "solid"
      "unixODBC"
      "generic"
    )

    set_property(
      CACHE EXT_ODBC_TYPE
      PROPERTY STRINGS ${odbc_types}
    )

    if(NOT EXT_ODBC_TYPE IN_LIST odbc_types)
      string(REPLACE ";" ", " odbc_types_string "${odbc_types}")

      message(
        FATAL_ERROR
        "Unknown ODBC type EXT_ODBC_TYPE=${EXT_ODBC_TYPE}. Please select one "
        "of these: ${odbc_types_string}."
      )
    endif()
  endblock()
elseif(DEFINED EXT_ODBC_TYPE)
  # Hide variable.
  set_property(CACHE EXT_ODBC_TYPE PROPERTY TYPE INTERNAL)
endif()

set(
  EXT_ODBC_VERSION "0x0350"
  CACHE STRING "Force support for the passed ODBC version. A hex number is \
expected, default 0x0350. Set it to empty value to prevent an explicit ODBCVER \
to be defined."
)
mark_as_advanced(EXT_ODBC_VERSION)

set(
  ODBCVER "${EXT_ODBC_VERSION}"
  CACHE INTERNAL "The highest supported ODBC version"
)

if(NOT EXT_ODBC)
  return()
endif()

if(EXT_ODBC_SHARED)
  add_library(php_odbc SHARED)
else()
  add_library(php_odbc)
endif()

target_sources(
  php_odbc
  PRIVATE
    odbc_utils.c
    php_odbc.c
)

target_compile_definitions(php_odbc PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

find_package(ODBC)
set_package_properties(
  ODBC
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the odbc extension."
)

target_link_libraries(php_odbc PRIVATE ODBC::ODBC)

if(EXT_ODBC_TYPE STREQUAL "adabas")
  set(HAVE_ADABAS 1 CACHE INTERNAL "Whether the ODBC type is Adabas.")
elseif(EXT_ODBC_TYPE STREQUAL "dbmaker")
  set(HAVE_DBMAKER 1 CACHE INTERNAL "Whether the ODBC type is DBMaker.")
elseif(EXT_ODBC_TYPE MATCHES "^(empress|empress-bcs)$")
  set(HAVE_EMPRESS 1 CACHE INTERNAL "Whether the ODBC type is Empress.")
elseif(EXT_ODBC_TYPE STREQUAL "esoob")
  set(HAVE_ESOOB 1 CACHE INTERNAL "Whether the ODBC type is Easysoft OOB.")
elseif(EXT_ODBC_TYPE STREQUAL "ibm-db2")
  set(HAVE_IBMDB2 1 CACHE INTERNAL "Whether the ODBC type is IBM DB2.")
elseif(EXT_ODBC_TYPE STREQUAL "iODBC")
  set(HAVE_IODBC 1 CACHE INTERNAL "Whether the ODBC type is iODBC.")
elseif(EXT_ODBC_TYPE STREQUAL "sapdb")
  set(HAVE_SAPDB 1 CACHE INTERNAL "Whether the ODBC type is SAP DB.")
elseif(EXT_ODBC_TYPE STREQUAL "solid")
  # TODO: Set based on the solid version:
  #set(HAVE_SOLID_35 1 CACHE INTERNAL "Whether the ODBC type is Solid.")
  #set(HAVE_SOLID_30 1 CACHE INTERNAL "Whether the ODBC type is Solid.")
  set(HAVE_SOLID 1 CACHE INTERNAL "Whether the ODBC type is Solid.")
elseif(EXT_ODBC_TYPE STREQUAL "unixODBC")
  set(HAVE_UNIXODBC 1 CACHE INTERNAL "Whether the ODBC type is unixODBC.")
elseif(EXT_ODBC_TYPE STREQUAL "generic")
  set(HAVE_CODBC 1 CACHE INTERNAL "Whether the ODBC type is generic custom.")
endif()

################################################################################
# Set ODBC_* variables for main/build-defs.h file.
################################################################################
if(TARGET ODBC::ODBC)
  block()
    get_target_property(cflags ODBC::ODBC INTERFACE_COMPILE_OPTIONS)
    string(REPLACE ";" " " cflags "${cflags}")
    set(ODBC_CFLAGS "${cflags}" CACHE INTERNAL "ODBC CFLAGS")

    get_target_property(libraries ODBC::ODBC IMPORTED_LOCATION)

    foreach(library ${libraries})
      cmake_path(GET library PARENT_PATH path)
      list(APPEND ldflags "-L${path}")

      cmake_path(GET library STEM name)
      string(REGEX REPLACE "^lib" "" name "${name}")
      list(APPEND libs "-l${name}")
    endforeach()

    list(REMOVE_DUPLICATES ldflags)
    list(REMOVE_DUPLICATES libs)

    string(REPLACE ";" " " ldflags "${ldflags}")
    string(REPLACE ";" " " libs "${libs}")

    set(ODBC_LFLAGS "${ldflags}" CACHE INTERNAL "ODBC linker flags")
    set(ODBC_LIBS "${libs}" CACHE INTERNAL "ODBC libraries")
    set(ODBC_TYPE "${EXT_ODBC_TYPE}" CACHE INTERNAL "ODBC type")
  endblock()
endif()

if(NOT EXT_ODBC_TYPE MATCHES "^(dbmaker|solid)$")
  set(
    HAVE_SQLDATASOURCES 1
    CACHE INTERNAL "Whether SQL datasources are available"
  )
endif()

set(HAVE_UODBC 1 CACHE INTERNAL "Whether the odbc extension is enabled")
