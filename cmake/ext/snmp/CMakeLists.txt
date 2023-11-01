include(CheckLibraryExists)
include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_SNMP "Enable the snmp extension" OFF)

add_feature_info("ext/snmp" EXT_SNMP
  "Adds support for the Simple Network Management Protocol (SNMP)."
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

find_package(SNMP 5.3)
set_package_properties(SNMP PROPERTIES
  TYPE REQUIRED
  PURPOSE "Necessary to enable the snmp extension."
)

target_link_libraries(php_snmp PRIVATE SNMP::SNMP)

if(TARGET SNMP::SNMP)
  # Sanity check.
  check_library_exists(SNMP::SNMP init_snmp "" HAVE_INIT_SNMP)

  if(NOT HAVE_INIT_SNMP)
    message(
      FATAL_ERROR
      "SNMP sanity check failed. The init_snmp was not found in "
      "${SNMP_LIBRARIES}"
    )
  endif()

  check_library_exists(SNMP::SNMP shutdown_snmp_logging "" HAVE_SHUTDOWN_SNMP_LOGGING)
  check_library_exists(SNMP::SNMP usmHMAC192SHA256AuthProtocol "" HAVE_SNMP_SHA256)
  check_library_exists(SNMP::SNMP usmHMAC384SHA512AuthProtocol "" HAVE_SNMP_SHA512)
endif()
