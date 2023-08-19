#[=============================================================================[
CMake module to find and use libzip library.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET)

if(PKG_CONFIG_FOUND)
  pkg_search_module(ZIP libzip)
endif()

find_package_handle_standard_args(
  ZIP
  REQUIRED_VARS ZIP_LIBRARIES
  VERSION_VAR ZIP_VERSION
  REASON_FAILURE_MESSAGE "Zip not found. Please install libzip."
)
