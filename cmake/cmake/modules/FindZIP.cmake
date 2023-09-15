#[=============================================================================[
Find the libzip library.

Modules sets the following variables:

ZIP_INCLUDE_DIRS
  A list of include directories for using libzip library.
ZIP_LIBRARIES
  A list of libraries for linking when using libzip library.
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
  REASON_FAILURE_MESSAGE "Zip not found. Please install Zip library (libzip)."
)
