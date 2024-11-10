project(
  PhpExtensionOdbc
  LANGUAGES C
)

include(CheckIncludeFile)
include(CheckLibraryExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)
include(PHP/Set)

option(EXT_ODBC "Enable the odbc extension" OFF)
add_feature_info(
  "ext/odbc"
  EXT_ODBC
  "Unified Open Database Connectivity (ODBC) databases support"
)

cmake_dependent_option(
  EXT_ODBC_SHARED
  "Build the odbc extension as a shared library"
  OFF
  [[EXT_ODBC AND NOT BUILD_SHARED_LIBS]]
  OFF
)

php_set(
  EXT_ODBC_TYPE
  CHOICES
    "auto"
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
    "custom"
  IF EXT_ODBC
  DOC "The ODBC implementation type (library driving the ODBC)"
)
mark_as_advanced(EXT_ODBC_TYPE)

# Validate ODBC type for odbc and pdo_odbc extensions. Ideally, the same ODBC
# driver library should be used for both extensions.
if(EXT_ODBC AND EXT_PDO_ODBC AND NOT EXT_ODBC_TYPE STREQUAL EXT_PDO_ODBC_TYPE)
  message(
    FATAL_ERROR
    "Different ODBC types detected for 'odbc' and 'pdo_odbc' PHP "
    "extensions:\n"
    "EXT_ODBC_TYPE=${EXT_ODBC_TYPE}\n"
    "EXT_PDO_ODBC_TYPE=${EXT_PDO_ODBC_TYPE}\n"
    "To prevent library symbol collisions when building both 'odbc' and "
    "'pdo_odbc' please link with the same ODBC library. Or disable one of "
    "the extensions by setting EXT_ODBC or EXT_PDO_ODBC to 'OFF'."
  )
endif()

# Some ODBC drivers require setting ODBC_LIBRARY manually to find package.
if(
  EXT_ODBC
  AND NOT EXT_ODBC_TYPE MATCHES "auto|unixODBC|iODBC"
  AND NOT ODBC_LIBRARY
)
  message(
    FATAL_ERROR
    "When using EXT_ODBC_TYPE=${EXT_ODBC_TYPE}, please set also "
    "ODBC_LIBRARY and optionally ODBC_INCLUDE_DIR to locate the ODBC "
    "installation."
  )
endif()

php_set(
  EXT_ODBC_VERSION
  TYPE STRING
  IF [[EXT_ODBC AND NOT EXT_ODBC_TYPE MATCHES "^(unixODBC|dbmaker)$"]]
  VALUE "0x0350"
  ELSE_VALUE "0x0350"
  DOC
    "Hex number to force support for the ODBC specification version. Default: "
    "0x0350. Set to special value 0 (zero) or empty to not define explicit "
    "ODBCVER in the configuration header."
)
mark_as_advanced(EXT_ODBC_VERSION)
# Validate hexadecimal version.
if(EXT_ODBC_VERSION AND NOT EXT_ODBC_VERSION MATCHES "^0x[0-9A-Fa-f]+$")
  message(
    FATAL_ERROR
    "The value 'EXT_ODBC_VERSION=${EXT_ODBC_VERSION}' is NOT valid hexadecimal "
    "number."
  )
endif()

unset(PHP_ODBC_CFLAGS CACHE)
unset(PHP_ODBC_LFLAGS CACHE)
unset(PHP_ODBC_LIBS CACHE)
unset(PHP_ODBC_TYPE CACHE)

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
    odbc.stub.php
    php_odbc.c
)

target_compile_definitions(php_odbc PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

# TODO: Can this be fixed better?
get_target_property(extension_type php_odbc TYPE)
if(NOT extension_type MATCHES "^(MODULE|SHARED)_LIBRARY$")
  target_link_libraries(php_odbc PRIVATE PHP::main)
endif()

if(NOT EXT_ODBC_TYPE STREQUAL "auto")
  set(ODBC_USE_DRIVER "${EXT_ODBC_TYPE}")
endif()
find_package(ODBC)
set_package_properties(
  ODBC
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the odbc extension."
)

if(ODBC_DRIVER AND EXT_ODBC_TYPE STREQUAL "auto")
  set(EXT_ODBC_TYPE "${ODBC_DRIVER}")
endif()

target_link_libraries(php_odbc PRIVATE ODBC::ODBC)

if(EXT_ODBC_TYPE STREQUAL "adabas")
  set(HAVE_ADABAS 1)
elseif(EXT_ODBC_TYPE STREQUAL "dbmaker")
  set(HAVE_DBMAKER 1)
elseif(EXT_ODBC_TYPE MATCHES "^(empress|empress-bcs)$")
  set(HAVE_EMPRESS 1)
elseif(EXT_ODBC_TYPE STREQUAL "esoob")
  set(HAVE_ESOOB 1)
elseif(EXT_ODBC_TYPE STREQUAL "ibm-db2")
  # Sanity check.
  if(TARGET ODBC::ODBC)
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LIBRARIES ODBC::ODBC)
      check_include_file(sqlcli1.h HAVE_SQLCLI1_H)
      check_library_exists(ODBC::ODBC "" SQLExecute HAVE_SQLEXECUTE)
    cmake_pop_check_state()
    if(NOT HAVE_SQLCLI1_H)
      message(FATAL_ERROR "Required <sqlcli1.h> header file not found")
    endif()
    if(NOT HAVE_SQLEXECUTE)
      message(
        FATAL_ERROR
        "ODBC build test failed. SQLExecute not found. The DB2 environment "
        "needs to be sourced. Run the command line:\n"
        "  . $IBM_DB2/db2profile"
      )
    endif()
  endif()
  set(HAVE_IBMDB2 1)
elseif(EXT_ODBC_TYPE STREQUAL "iODBC")
  set(HAVE_IODBC 1)
  # To match the native build system string:
  set(EXT_ODBC_TYPE iodbc)
elseif(EXT_ODBC_TYPE STREQUAL "sapdb")
  set(HAVE_SAPDB 1)
elseif(EXT_ODBC_TYPE STREQUAL "solid")
  # Set based on the Solid version:
  if(ODBC_LIBRARY MATCHES "23\.(a|so)$")
    set(HAVE_SOLID 1)
  elseif(ODBC_LIBRARY MATCHES "30\.(a|so)$")
    set(HAVE_SOLID_30 1)
  else()
    set(HAVE_SOLID_35 1)
  endif()

  # Additional configuration for using obsolete <sqlunix.h> header on obsolete
  # systems.
  if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(SS_LINUX 1)
  elseif(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
    set(SS_FBX 1)
  endif()
elseif(EXT_ODBC_TYPE STREQUAL "unixODBC")
  set(HAVE_UNIXODBC 1)
elseif(EXT_ODBC_TYPE STREQUAL "custom")
  set(HAVE_CODBC 1)
  # To match the native build system string:
  set(EXT_ODBC_TYPE custom-odbc)
endif()

if(NOT EXT_ODBC_TYPE MATCHES "^(dbmaker|solid)$")
  set(HAVE_SQLDATASOURCES 1)
endif()

################################################################################
# Set ODBC_* variables for main/build-defs.h file.
################################################################################
if(TARGET ODBC::ODBC)
  block(PROPAGATE PHP_ODBC_BUILD_DEFINITIONS_CODE)
    get_target_property(definitions ODBC::ODBC INTERFACE_COMPILE_DEFINITIONS)
    get_target_property(options ODBC::ODBC INTERFACE_COMPILE_OPTIONS)
    set(cflags "")
    if(definitions)
      list(APPEND cflags ${definitions})
    endif()
    if(options)
      list(APPEND cflags ${options})
    endif()
    if(cflags)
      list(JOIN cflags " " cflags)
    endif()

    get_target_property(libraries ODBC::ODBC IMPORTED_LOCATION)
    foreach(library ${libraries})
      cmake_path(GET library PARENT_PATH path)
      list(APPEND ldflags "-L${path}")

      cmake_path(GET library STEM name)
      string(REGEX REPLACE "^lib" "" name "${name}")
      list(APPEND libs "-l${name}")
    endforeach()

    get_target_property(options ODBC::ODBC INTERFACE_LINK_OPTIONS)
    if(options)
      list(APPEND ldflags ${options})
    endif()

    list(REMOVE_DUPLICATES ldflags)
    list(REMOVE_DUPLICATES libs)

    list(JOIN ldflags " " ldflags)
    list(JOIN libs " " libs)

    set(PHP_ODBC_CFLAGS "${cflags}" CACHE INTERNAL "ODBC CFLAGS")
    set(PHP_ODBC_LFLAGS "${ldflags}" CACHE INTERNAL "ODBC linker flags")
    set(PHP_ODBC_LIBS "${libs}" CACHE INTERNAL "ODBC libraries")
    set(PHP_ODBC_TYPE "${EXT_ODBC_TYPE}" CACHE INTERNAL "ODBC type")

    if(
      NOT CMAKE_SYSTEM_NAME STREQUAL "Windows"
      AND NOT PHP_SOURCE_DIR
      AND NOT EXISTS ${PHP_SOURCE_DIR}/main/build-defs.h.in
    )
      set(
        PHP_ODBC_BUILD_DEFINITIONS_CODE
        [[
/* The compile options that PHP odbc extension was built with. */
#define PHP_ODBC_CFLAGS "@PHP_ODBC_CFLAGS@"

/* The linker flags that PHP odbc extension was built with. */
#define PHP_ODBC_LFLAGS "@PHP_ODBC_LFLAGS@"

/* The libraries linker flags that PHP odbc extension was built with. */
#define PHP_ODBC_LIBS "@PHP_ODBC_LIBS@"

/* The ODBC library used in the PHP odbc extension. */
#define PHP_ODBC_TYPE "@PHP_ODBC_TYPE@"]]
      )

      string(
        CONFIGURE
        "${PHP_ODBC_BUILD_DEFINITIONS_CODE}"
        PHP_ODBC_BUILD_DEFINITIONS_CODE
      )
    endif()
  endblock()
endif()

if(EXT_ODBC_VERSION)
  set(ODBCVER "${EXT_ODBC_VERSION}")
endif()

set(HAVE_UODBC 1)

configure_file(config.cmake.h.in config.h)
