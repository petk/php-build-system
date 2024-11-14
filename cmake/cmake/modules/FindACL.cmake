#[=============================================================================[
Find the ACL library.

Module defines the following `IMPORTED` target(s):

* `ACL::ACL` - The package library, if found.

Result variables:

* `ACL_FOUND` - Whether the package has been found.
* `ACL_INCLUDE_DIRS` - Include directories needed to use this package.
* `ACL_LIBRARIES` - Libraries needed to link to the package library.
* `ACL_VERSION` - Package version, if found.

Cache variables:

* `ACL_IS_BUILT_IN` - Whether ACL is a part of the C library (BSD-based
  systems).
* `ACL_INCLUDE_DIR` - Directory containing package library headers.
* `ACL_LIBRARY` - The path to the package library.

Hints:

The `ACL_ROOT` variable adds custom search path.

Set `ACL_USE_USER_GROUP` to `TRUE` before calling `find_package(ACL)` to also
check if the ACL library supports `ACL_USER` and `ACL_GROUP`. For example, macOS
doesn't have support for user/group.
#]=============================================================================]

include(CheckSourceCompiles)
include(CheckSymbolExists)
include(CMakePushCheckState)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  ACL
  PROPERTIES
    URL "https://savannah.nongnu.org/projects/acl/"
    DESCRIPTION "POSIX Access Control Lists library"
)

################################################################################
# Module helpers.
################################################################################

function(_acl_check result)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)
    if(ACL_INCLUDE_DIR)
      set(CMAKE_REQUIRED_INCLUDES ${ACL_INCLUDE_DIR})
    endif()
    if(ACL_LIBRARY)
      set(CMAKE_REQUIRED_LIBRARIES ${ACL_LIBRARY})
    endif()

    if(NOT ACL_USE_USER_GROUP)
      check_symbol_exists(acl_free "sys/acl.h" _acl_successful)
    else()
      check_source_compiles(C [[
        #include <sys/acl.h>

        int main(void)
        {
          acl_t acl;
          acl_entry_t user, group;
          acl = acl_init(1);
          acl_create_entry(&acl, &user);
          acl_set_tag_type(user, ACL_USER);
          acl_create_entry(&acl, &group);
          acl_set_tag_type(user, ACL_GROUP);
          acl_free(acl);
          return 0;
        }
      ]] _acl_successful)
    endif()
  cmake_pop_check_state()

  if(_acl_successful)
    set(${result} TRUE PARENT_SCOPE)
  else()
    set(${result} FALSE PARENT_SCOPE)
  endif()

  unset(_acl_successful CACHE)
endfunction()

################################################################################
# Disable built-in ACL when overriding search paths in FindACL.
################################################################################
if(CMAKE_PREFIX_PATH OR ACL_ROOT)
  find_path(
    _acl_INCLUDE_DIR
    NAMES
      sys/acl.h
    PATHS
      ${CMAKE_PREFIX_PATH}
      ${ACL_ROOT}
    PATH_SUFFIXES
      include
    NO_DEFAULT_PATH
  )

  if(_acl_INCLUDE_DIR)
    set(ACL_INCLUDE_DIR ${_acl_INCLUDE_DIR})
    set(ACL_IS_BUILT_IN FALSE)
  endif()
endif()

################################################################################
# Find package.
################################################################################

set(_reason "")

# If no compiler is loaded C library can't be checked anyway.
if(NOT CMAKE_C_COMPILER_LOADED AND NOT CMAKE_CXX_COMPILER_LOADED)
  set(ACL_IS_BUILT_IN FALSE)
endif()

if(NOT DEFINED ACL_IS_BUILT_IN)
  block(PROPAGATE ACL_IS_BUILT_IN _acl_works)
    _acl_check(_acl_works)

    if(_acl_works)
      set(
        ACL_IS_BUILT_IN TRUE
        CACHE INTERNAL "Whether ACL is a part of the C library"
      )
    else()
      set(ACL_IS_BUILT_IN FALSE)
    endif()
  endblock()
endif()

set(_ACL_REQUIRED_VARS)
if(ACL_IS_BUILT_IN)
  set(_ACL_REQUIRED_VARS _ACL_IS_BUILT_IN_MSG)
  set(_ACL_IS_BUILT_IN_MSG "built in to C library")
else()
  set(_ACL_REQUIRED_VARS ACL_LIBRARY ACL_INCLUDE_DIR)

  # Use pkgconf, if available on the system.
  find_package(PkgConfig QUIET)
  if(PKG_CONFIG_FOUND)
    pkg_check_modules(PC_ACL QUIET libacl)
  endif()

  find_path(
    ACL_INCLUDE_DIR
    NAMES sys/acl.h
    HINTS ${PC_ACL_INCLUDE_DIRS}
    DOC "Directory containing ACL library headers"
  )

  if(NOT ACL_INCLUDE_DIR)
    string(APPEND _reason "sys/acl.h not found. ")
  endif()

  find_library(
    ACL_LIBRARY
    NAMES acl
    HINTS ${PC_ACL_LIBRARY_DIRS}
    DOC "The path to the ACL library"
  )

  if(NOT ACL_LIBRARY)
    string(APPEND _reason "ACL library not found. ")
  endif()

  # Get version.
  block(PROPAGATE ACL_VERSION)
    # ACL headers don't provide version. Try pkgconf version, if found.
    if(PC_ACL_VERSION AND ACL_INCLUDE_DIR)
      cmake_path(COMPARE "${ACL_INCLUDE_DIR}" EQUAL "${PC_ACL_INCLUDEDIR}" isEqual)

      if(isEqual)
        set(ACL_VERSION ${PC_ACL_VERSION})
      endif()
    endif()
  endblock()

  _acl_check(_acl_works)

  mark_as_advanced(ACL_INCLUDE_DIR ACL_LIBRARY)
endif()

if(NOT _acl_works)
  if(ACL_USE_USER_GROUP)
    string(APPEND _reason "ACL_USER and ACL_GROUP check failed. ")
  else()
    string(APPEND _reason "acl_free check failed. ")
  endif()
endif()

################################################################################
# Handle find_package arguments.
################################################################################

find_package_handle_standard_args(
  ACL
  REQUIRED_VARS
    ${_ACL_REQUIRED_VARS}
    _acl_works
  VERSION_VAR ACL_VERSION
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)
unset(_acl_works)
unset(_ACL_REQUIRED_VARS)
unset(_ACL_IS_BUILT_IN_MSG)

if(NOT ACL_FOUND)
  return()
endif()

if(ACL_IS_BUILT_IN)
  set(ACL_INCLUDE_DIRS "")
  set(ACL_LIBRARIES "")
else()
  set(ACL_INCLUDE_DIRS ${ACL_INCLUDE_DIR})
  set(ACL_LIBRARIES ${ACL_LIBRARY})
endif()

if(NOT TARGET ACL::ACL)
  add_library(ACL::ACL UNKNOWN IMPORTED)

  if(ACL_INCLUDE_DIR)
    set_target_properties(
      ACL::ACL
      PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${ACL_INCLUDE_DIR}"
    )
  endif()

  if(ACL_LIBRARY)
    set_target_properties(
      ACL::ACL
      PROPERTIES
        IMPORTED_LOCATION "${ACL_LIBRARY}"
    )
  endif()
endif()
