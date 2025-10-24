#[=============================================================================[
# FindACL

Finds the ACL library:

```cmake
find_package(ACL [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `ACL::ACL` - The package library, if found.

## Result variables

This module defines the following variables:

* `ACL_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `ACL_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `ACL_IS_BUILT_IN` - Whether ACL is a part of the C library (for example, on
  BSD-based systems).
* `ACL_INCLUDE_DIR` - Directory containing package library headers.
* `ACL_LIBRARY` - The path to the package library.

## Hints

This module accepts the following variables before calling `find_package(ACL)`:

* `ACL_USE_USER_GROUP` - When set to boolean true a check is performed whether
  the ACL library supports `ACL_USER` and `ACL_GROUP`. For example, macOS
  doesn't have support for user/group.

## Examples

### Example: Basic usage

Finding ACL library and linking its imported target to the project target:

```cmake
# CMakeLists.txt
find_package(ACL)
target_link_libraries(example PRIVATE ACL::ACL)
```
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
      check_symbol_exists(acl_free sys/acl.h ${result})
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
      ]] ${result})
    endif()
  cmake_pop_check_state()
endfunction()

################################################################################
# Find package.
################################################################################

# Disable searching for built-in ACL when overriding search paths.
if(
  NOT DEFINED ACL_IS_BUILT_IN
  AND NOT DEFINED ACL_INCLUDE_DIR
  AND NOT DEFINED ACL_LIBRARY
  AND (
    CMAKE_PREFIX_PATH
    OR ACL_ROOT
    OR DEFINED ENV{ACL_ROOT}
  )
)
  find_path(
    ACL_INCLUDE_DIR
    NAMES sys/acl.h
    DOC "Directory containing ACL library headers"
    NO_CMAKE_ENVIRONMENT_PATH
    NO_SYSTEM_ENVIRONMENT_PATH
    NO_CMAKE_INSTALL_PREFIX
    NO_CMAKE_SYSTEM_PATH
  )

  find_library(
    ACL_LIBRARY
    NAMES acl
    DOC "The path to the ACL library"
    NO_CMAKE_ENVIRONMENT_PATH
    NO_SYSTEM_ENVIRONMENT_PATH
    NO_CMAKE_INSTALL_PREFIX
    NO_CMAKE_SYSTEM_PATH
  )

  if(ACL_INCLUDE_DIR AND ACL_LIBRARY)
    set(ACL_IS_BUILT_IN FALSE)
  else()
    unset(CACHE{ACL_INCLUDE_DIR})
    unset(CACHE{ACL_LIBRARY})
  endif()
endif()

set(_reason "")
set(_ACL_REQUIRED_VARS "")

# If no compiler is loaded C library can't be checked anyway.
if(NOT CMAKE_C_COMPILER_LOADED AND NOT CMAKE_CXX_COMPILER_LOADED)
  set(ACL_IS_BUILT_IN FALSE)
endif()

if(NOT DEFINED ACL_IS_BUILT_IN)
  _acl_check(ACL_IS_BUILT_IN)

  if(ACL_IS_BUILT_IN)
    set(ACL_SANITY_CHECK TRUE)
  endif()
endif()

if(ACL_IS_BUILT_IN)
  _acl_check(ACL_SANITY_CHECK)

  set(_ACL_REQUIRED_VARS _ACL_IS_BUILT_IN_MSG)
  set(_ACL_IS_BUILT_IN_MSG "built in to C library")
else()
  set(_ACL_REQUIRED_VARS ACL_LIBRARY ACL_INCLUDE_DIR)

  find_package(PkgConfig QUIET)
  if(PkgConfig_FOUND)
    pkg_check_modules(PC_ACL QUIET libacl)
  endif()

  find_path(
    ACL_INCLUDE_DIR
    NAMES sys/acl.h
    HINTS ${PC_ACL_INCLUDE_DIRS}
    DOC "Directory containing ACL library headers"
  )
  mark_as_advanced(ACL_INCLUDE_DIR)

  if(NOT ACL_INCLUDE_DIR)
    string(APPEND _reason "<sys/acl.h> not found. ")
  endif()

  find_library(
    ACL_LIBRARY
    NAMES acl
    HINTS ${PC_ACL_LIBRARY_DIRS}
    DOC "The path to the ACL library"
  )
  mark_as_advanced(ACL_LIBRARY)

  if(NOT ACL_LIBRARY)
    string(APPEND _reason "ACL library not found. ")
  endif()

  # ACL headers don't provide version. Try pkg-config.
  if(PC_ACL_VERSION AND ACL_INCLUDE_DIR IN_LIST PC_ACL_INCLUDE_DIRS)
    set(ACL_VERSION ${PC_ACL_VERSION})
  endif()

  _acl_check(ACL_SANITY_CHECK)
endif()

if(NOT ACL_SANITY_CHECK)
  if(ACL_USE_USER_GROUP)
    string(APPEND _reason "ACL_USER and ACL_GROUP sanity check failed. ")
  else()
    string(APPEND _reason "ACL sanity check failed. ")
  endif()
endif()

find_package_handle_standard_args(
  ACL
  REQUIRED_VARS ${_ACL_REQUIRED_VARS} ACL_SANITY_CHECK
  VERSION_VAR ACL_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)
unset(_ACL_REQUIRED_VARS)
unset(_ACL_IS_BUILT_IN_MSG)

if(NOT ACL_FOUND)
  return()
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
