include(CheckLibraryExists)
include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_SNMP "Enable the snmp extension" OFF)

add_feature_info("ext/snmp" EXT_SNMP
  "Simple Network Management Protocol (SNMP) support."
)

cmake_dependent_option(
  EXT_SNMP_SHARED
  "Build the snmp extension as a shared library"
  OFF
  "EXT_SNMP;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_SNMP)
  return()
endif()

if(EXT_SNMP_SHARED)
  add_library(php_snmp SHARED)
else()
  add_library(php_snmp)
endif()

target_sources(php_snmp PRIVATE
  snmp.c
)

find_package(NetSnmp 5.3)
set_package_properties(
  NetSnmp
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the snmp extension."
)

target_link_libraries(php_snmp PRIVATE NetSnmp::NetSnmp)

if(TARGET NetSnmp::NetSnmp)
  check_library_exists(
    NetSnmp::NetSnmp
    shutdown_snmp_logging
    ""
    HAVE_SHUTDOWN_SNMP_LOGGING
  )

  check_library_exists(
    NetSnmp::NetSnmp
    usmHMAC192SHA256AuthProtocol
    ""
    HAVE_SNMP_SHA256
  )

  check_library_exists(
    NetSnmp::NetSnmp
    usmHMAC384SHA512AuthProtocol
    ""
    HAVE_SNMP_SHA512
  )
endif()
