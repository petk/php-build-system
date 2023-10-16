include(CheckLibraryExists)
include(CMakeDependentOption)

option(EXT_SNMP "Whether to enable the SNMP extension" OFF)

cmake_dependent_option(
  EXT_SNMP_SHARED
  "Whether to build the SNMP extension as shared object"
  OFF
  "EXT_SNMP;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_SNMP)
  return()
endif()

if(EXT_SNMP_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "snmp" ${_library_type})

add_library(php_snmp ${_library_type}
  snmp.c
)

find_package(SNMP 5.3 REQUIRED)

target_link_libraries(php_snmp PRIVATE SNMP::SNMP)

# Sanity check.
check_library_exists(SNMP::SNMP init_snmp "" _have_init_snmp)

if(NOT _have_init_snmp)
  message(FATAL_ERROR "SNMP sanity check failed. The init_snmp was not found in library ${SNMP_LIBRARIES}")
endif()

check_library_exists(SNMP::SNMP shutdown_snmp_logging "" HAVE_SHUTDOWN_SNMP_LOGGING)
check_library_exists(SNMP::SNMP usmHMAC192SHA256AuthProtocol "" HAVE_SNMP_SHA256)
check_library_exists(SNMP::SNMP usmHMAC384SHA512AuthProtocol "" HAVE_SNMP_SHA512)
