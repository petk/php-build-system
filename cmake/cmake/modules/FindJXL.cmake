#[=============================================================================[
# FindJXL

Finds the JXL library (libjxl):

```cmake
find_package(JXL [<version>] [COMPONENTS <components>...] [...])
```

## Components

This module supports optional components which can be specified using the
`find_package()` command:

```cmake
find_package(
  JXL
  [COMPONENTS <components>...]
  [OPTIONAL_COMPONENTS <components>...]
  [...]
)
```

Supported components include:

* `jxl` - Finds the main JXL library.
* `jxl_cms` - Finds the JXL CMS (Color Management System) library (available as
  of JXL version 0.9).

If no components are specified, by default, the `jxl` is searched as required
component.

## Imported targets

This module provides the following imported targets:

* `JXL::jxl` - Target encapsulating the main JXL library package usage
  requirements, available if package was found.
* `JXL::jxl_cms` - Target encapsulating the JXL CMS library usage requirements,
  available if JXL CMS library was found.

## Result variables

This module defines the following variables:

* `JXL_FOUND` - Boolean indicating whether (the requested version of)
  package was found.
* `JXL_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `JXL_INCLUDE_DIR` - Directory containing package library headers.
* `JXL_<component>_LIBRARY` - The path to the package library.

## Hints

This module accepts the following variables before calling `find_package(JXL)`:

* `JXL_USE_STATIC_LIBS` - Set this variable to boolean true to search for static
  libraries.

## Examples

### Example: Basic usage

```cmake
# CMakeLists.txt
find_package(JXL)
target_link_libraries(example PRIVATE JXL::jxl)
```

### Example: Using components

```cmake
# CMakeLists.txt
find_package(JXL COMPONENTS jxl jxl_cms)
target_link_libraries(example PRIVATE JXL::jxl JXL::jxl_cms)
```
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  JXL
  PROPERTIES
    URL "https://github.com/libjxl/libjxl"
    DESCRIPTION "JPEG XL image format reference implementation library"
)

block(PROPAGATE JXL_FOUND JXL_VERSION)
  set(reason "")
  set(required_vars "")

  # Set default components.
  if(NOT JXL_FIND_COMPONENTS)
    set(JXL_FIND_COMPONENTS jxl)
    set(JXL_FIND_REQUIRED_jxl TRUE)
  endif()

  find_package(PkgConfig QUIET)
  if(PkgConfig_FOUND)
    pkg_check_modules(PC_JXL_jxl QUIET libjxl)
  endif()

  find_path(
    JXL_INCLUDE_DIR
    NAMES jxl/decode.h
    HINTS ${PC_JXL_jxl_INCLUDE_DIRS}
    DOC "Directory containing JXL library headers"
  )
  mark_as_advanced(JXL_INCLUDE_DIR)

  if(NOT JXL_INCLUDE_DIR)
    string(APPEND reason "<jxl/decode.h> not found. ")
  endif()

  # Get version.
  if(EXISTS "${JXL_INCLUDE_DIR}/jxl/version.h")
    file(
      STRINGS ${JXL_INCLUDE_DIR}/jxl/version.h
      results
      REGEX
        "^#[ \t]*define[ \t]+JPEGXL_(MAJOR|MINOR|PATCH)_VERSION[ \t]+[0-9]+[^\n]*$"
    )

    unset(JXL_VERSION)

    foreach(item MAJOR MINOR PATCH)
      foreach(line ${results})
        if(
          line
            MATCHES
            "^#[ \t]*define[ \t]+JPEGXL_${item}_VERSION[ \t]+([0-9]+)[^\n]*$"
        )
          if(DEFINED JXL_VERSION)
            string(APPEND JXL_VERSION ".${CMAKE_MATCH_1}")
          else()
            set(JXL_VERSION "${CMAKE_MATCH_1}")
          endif()
        endif()
      endforeach()
    endforeach()
  endif()

  if(
    NOT JXL_VERSION
    AND PC_JXL_jxl_VERSION
    AND JXL_INCLUDE_DIR IN_LIST PC_JXL_jxl_INCLUDE_DIRS
  )
    set(JXL_VERSION ${PC_JXL_jxl_VERSION})
  endif()

  if("jxl" IN_LIST JXL_FIND_COMPONENTS)
    if(JXL_FIND_REQUIRED_jxl)
      list(APPEND required_vars JXL_jxl_LIBRARY JXL_INCLUDE_DIR)
    endif()

    find_library(
      JXL_jxl_LIBRARY
      NAMES jxl
      HINTS ${PC_JXL_jxl_LIBRARY_DIRS}
      DOC "The path to the JXL library"
    )
    mark_as_advanced(JXL_jxl_LIBRARY)

    if(NOT JXL_jxl_LIBRARY)
      string(APPEND reason "JXL library not found. ")
    endif()

    if(JXL_jxl_LIBRARY AND JXL_INCLUDE_DIR)
      set(JXL_jxl_FOUND TRUE)
    else()
      set(JXL_jxl_FOUND FALSE)
    endif()
  endif()

  if("jxl_cms" IN_LIST JXL_FIND_COMPONENTS)
    if(PkgConfig_FOUND)
      pkg_check_modules(PC_JXL_jxl_cms QUIET libjxl_cms)
    endif()

    if(JXL_FIND_REQUIRED_jxl_cms)
      list(APPEND required_vars JXL_jxl_cms_LIBRARY JXL_INCLUDE_DIR)
    endif()

    find_library(
      JXL_jxl_cms_LIBRARY
      NAMES jxl_cms
      HINTS ${PC_JXL_jxl_cms_LIBRARY_DIRS}
      DOC "The path to the JXL library"
    )
    mark_as_advanced(JXL_jxl_cms_LIBRARY)

    if(NOT JXL_jxl_cms_LIBRARY)
      string(APPEND reason "jxl_cms library not found. ")
    endif()

    if(JXL_jxl_cms_LIBRARY AND JXL_INCLUDE_DIR)
      set(JXL_jxl_cms_FOUND TRUE)
    else()
      set(JXL_jxl_cms_FOUND FALSE)
    endif()
  endif()

  find_package_handle_standard_args(
    JXL
    REQUIRED_VARS ${required_vars}
    VERSION_VAR JXL_VERSION
    HANDLE_VERSION_RANGE
    HANDLE_COMPONENTS
    REASON_FAILURE_MESSAGE "${reason}"
  )

  if(NOT JXL_FOUND)
    return()
  endif()

  if(
    "jxl" IN_LIST JXL_FIND_COMPONENTS
    AND JXL_jxl_FOUND
    AND NOT TARGET JXL::jxl
  )
    add_library(JXL::jxl UNKNOWN IMPORTED)

    set_target_properties(
      JXL::jxl
      PROPERTIES
        IMPORTED_LOCATION "${JXL_jxl_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${JXL_INCLUDE_DIR}"
    )

    if(JXL_USE_STATIC_LIBS)
      set_target_properties(
        JXL::jxl
        PROPERTIES INTERFACE_COMPILE_DEFINITIONS "JXL_STATIC_DEFINE"
      )
    endif()
  endif()

  if(
    "jxl_cms" IN_LIST JXL_FIND_COMPONENTS
    AND JXL_jxl_cms_FOUND
    AND NOT TARGET JXL::jxl_cms
  )
    add_library(JXL::jxl_cms UNKNOWN IMPORTED)

    set_target_properties(
      JXL::jxl_cms
      PROPERTIES
        IMPORTED_LOCATION "${JXL_jxl_cms_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${JXL_INCLUDE_DIR}"
    )

    if(JXL_USE_STATIC_LIBS)
      set_target_properties(
        JXL::jxl_cms
        PROPERTIES INTERFACE_COMPILE_DEFINITIONS "JXL_CMS_STATIC_DEFINE"
      )
    endif()
  endif()
endblock()
