#[=============================================================================[
CMake module to find and use Sodium library (libsodium).
#]=============================================================================]

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET)

if(PKG_CONFIG_FOUND)
  pkg_search_module(SODIUM libsodium)
endif()

if(SODIUM_FOUND)
  set(SODIUM_LIBRARIES ${SODIUM_LIBRARIES})
  set(SODIUM_INCLUDE_DIRS ${SODIUM_INCLUDE_DIRS})
endif()

find_package_handle_standard_args(
  SODIUM
  REQUIRED_VARS SODIUM_LIBRARIES
  VERSION_VAR SODIUM_VERSION
)
