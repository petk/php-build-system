#[=============================================================================[
CMake module to find and use GMP library.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET)

if(PKG_CONFIG_FOUND)
  pkg_search_module(GMP gmp)
endif()

find_package_handle_standard_args(
  GMP
  REQUIRED_VARS GMP_LIBRARIES
  VERSION_VAR GMP_VERSION
  REASON_FAILURE_MESSAGE "GMP not found. Please install libgmp."
)
