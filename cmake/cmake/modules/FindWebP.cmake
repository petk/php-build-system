#[=============================================================================[
# FindWebP

Finds the libwebp library:

```cmake
find_package(WebP [<version>] [COMPONENTS <components>...] [...])
```

## Components

This module supports optional components which can be specified using the
`find_package()` command:

```cmake
find_package(
  WebP
  [COMPONENTS <components>...]
  [OPTIONAL_COMPONENTS <components>...]
  [...]
)
```

Supported components include:

* `webp` - Finds the main WebP library.
* `webpdecoder` - Finds the WebP decoder library.
* `webpdemux` - Finds the WebP Demux library.
* `libwebpmux` - Finds the WebP Mux library. Named after the upstream target
  name from CMake config files.

If no components are specified, by default, the `webp` is searched as required
component.

## Imported targets

This module provides the following imported targets:

* `WebP::webp` - Target encapsulating the Webp main webp library, if `webp`
  component was found.
* `WebP::webpdecoder` - Target encapsulating the webpdecoder library, if
  `webpdecoder` component was found.
* `WebP::webpdemux` - Target encapsulating the webpdemux library, if
  `webpdemux` component was found.
* `WebP::libwebpmux` - Target encapsulating the webpmux library, if `libwebpmux`
  component was found.

## Result variables

This module defines the following variables:

* `WebP_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `WebP_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `WebP_INCLUDE_DIR` - Directory containing package library headers.
* `WebP_<component>_LIBRARY` - The path to the package component library.

## Examples

## Example: Basic usage

```cmake
# CMakeLists.txt
find_package(WebP)
target_link_libraries(example PRIVATE WebP::webp)
```

## Example: Finding WebP components

```cmake
# CMakeLists.txt
find_package(WebP COMPONENTS webp webpdemux libwebpmux)
target_link_libraries(
  example
  PRIVATE WebP::webp WebP::webpdemux WebP::libwebpmux
)
```
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  WebP
  PROPERTIES
    URL "https://developers.google.com/speed/webp/"
    DESCRIPTION "Library for the WebP graphics format"
)

block(PROPAGATE WebP_FOUND WebP_VERSION)
  set(reason "")
  set(required_vars "")

  # Set default components.
  if(NOT WebP_FIND_COMPONENTS)
    set(WebP_FIND_COMPONENTS webp)
    set(WebP_FIND_REQUIRED_webp TRUE)
  endif()

  find_package(PkgConfig QUIET)
  if(PkgConfig_FOUND)
    pkg_check_modules(PC_WebP_webp QUIET libwebp)
  endif()

  find_path(
    WebP_INCLUDE_DIR
    NAMES webp/decode.h
    HINTS ${PC_WebP_webp_INCLUDE_DIRS}
    DOC "Directory containing libwebp library headers"
  )
  mark_as_advanced(WebP_INCLUDE_DIR)

  if(NOT WebP_INCLUDE_DIR)
    string(APPEND reason "webp/decode.h not found. ")
  endif()

  # WebP headers don't provide version. Try pkg-config.
  if(
    PC_WebP_webp_VERSION
    AND WebP_INCLUDE_DIR IN_LIST PC_WebP_webp_INCLUDE_DIRS
  )
    set(WebP_VERSION ${PC_WebP_webp_VERSION})
  endif()

  if("webp" IN_LIST WebP_FIND_COMPONENTS)
    if(WebP_FIND_REQUIRED_webp)
      list(APPEND required_vars WebP_webp_LIBRARY WebP_INCLUDE_DIR)
    endif()

    find_library(
      WebP_webp_LIBRARY
      NAMES webp
      HINTS ${PC_WebP_webp_LIBRARY_DIRS}
      DOC "The path to the libwebp library"
    )
    mark_as_advanced(WebP_webp_LIBRARY)

    if(NOT WebP_webp_LIBRARY)
      string(APPEND reason "webp library not found. ")
    endif()

    if(WebP_webp_LIBRARY AND WebP_INCLUDE_DIR)
      set(WebP_webp_FOUND TRUE)
    else()
      set(WebP_webp_FOUND FALSE)
    endif()
  endif()

  if("webpdecoder" IN_LIST WebP_FIND_COMPONENTS)
    find_package(PkgConfig QUIET)
    if(PkgConfig_FOUND)
      pkg_check_modules(PC_WebP_webpdecoder QUIET libwebpdecoder)
    endif()

    if(WebP_FIND_REQUIRED_webpdecoder)
      list(APPEND required_vars WebP_webpdecoder_LIBRARY WebP_INCLUDE_DIR)
    endif()

    find_library(
      WebP_webpdecoder_LIBRARY
      NAMES webpdecoder
      HINTS ${PC_WebP_webpdecoder_LIBRARY_DIRS}
      DOC "The path to the libwebpdecoder library"
    )
    mark_as_advanced(WebP_webpdecoder_LIBRARY)

    if(NOT WebP_webpdecoder_LIBRARY)
      string(APPEND reason "webpdecoder library not found. ")
    endif()

    if(WebP_webpdecoder_LIBRARY AND WebP_INCLUDE_DIR)
      set(WebP_webpdecoder_FOUND TRUE)
    else()
      set(WebP_webpdecoder_FOUND FALSE)
    endif()
  endif()

  if("webpdemux" IN_LIST WebP_FIND_COMPONENTS)
    find_package(PkgConfig QUIET)
    if(PkgConfig_FOUND)
      pkg_check_modules(PC_WebP_webpdemux QUIET libwebpdemux)
    endif()

    if(WebP_FIND_REQUIRED_webpdemux)
      list(APPEND required_vars WebP_webpdemux_LIBRARY WebP_INCLUDE_DIR)
    endif()

    find_library(
      WebP_webpdemux_LIBRARY
      NAMES webpdemux
      HINTS ${PC_WebP_webpdemux_LIBRARY_DIRS}
      DOC "The path to the libwebpdemux library"
    )
    mark_as_advanced(WebP_webpdemux_LIBRARY)

    if(NOT WebP_webpdemux_LIBRARY)
      string(APPEND reason "webpdemux library not found. ")
    endif()

    if(WebP_webpdemux_LIBRARY AND WebP_INCLUDE_DIR)
      set(WebP_webpdemux_FOUND TRUE)
    else()
      set(WebP_webpdemux_FOUND FALSE)
    endif()
  endif()

  if("libwebpmux" IN_LIST WebP_FIND_COMPONENTS)
    find_package(PkgConfig QUIET)
    if(PkgConfig_FOUND)
      pkg_check_modules(PC_WebP_webpmux QUIET libwebpmux)
    endif()

    if(WebP_FIND_REQUIRED_libwebpmux)
      list(APPEND required_vars WebP_libwebpmux_LIBRARY WebP_INCLUDE_DIR)
    endif()

    find_library(
      WebP_libwebpmux_LIBRARY
      NAMES webpmux
      HINTS ${PC_WebP_libwebpmux_LIBRARY_DIRS}
      DOC "The path to the webpmux library"
    )
    mark_as_advanced(WebP_libwebpmux_LIBRARY)

    if(NOT WebP_libwebpmux_LIBRARY)
      string(APPEND reason "webpmux library not found. ")
    endif()

    if(WebP_libwebpmux_LIBRARY AND WebP_INCLUDE_DIR)
      set(WebP_libwebpmux_FOUND TRUE)
    else()
      set(WebP_libwebpmux_FOUND FALSE)
    endif()
  endif()

  find_package_handle_standard_args(
    WebP
    REQUIRED_VARS ${required_vars}
    VERSION_VAR WebP_VERSION
    HANDLE_VERSION_RANGE
    HANDLE_COMPONENTS
    REASON_FAILURE_MESSAGE "${reason}"
  )

  if(NOT WebP_FOUND)
    return()
  endif()

  if(
    "webp" IN_LIST WebP_FIND_COMPONENTS
    AND WebP_webp_FOUND
    AND NOT TARGET WebP::webp
  )
    add_library(WebP::webp UNKNOWN IMPORTED)

    set_target_properties(
      WebP::webp
      PROPERTIES
        IMPORTED_LOCATION "${WebP_webp_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${WebP_INCLUDE_DIR}"
    )
  endif()

  if(
    "webpdecoder" IN_LIST WebP_FIND_COMPONENTS
    AND WebP_webpdecoder_FOUND
    AND NOT TARGET WebP::webpdecoder
  )
    add_library(WebP::webpdecoder UNKNOWN IMPORTED)

    set_target_properties(
      WebP::webpdecoder
      PROPERTIES
        IMPORTED_LOCATION "${WebP_webpdecoder_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${WebP_INCLUDE_DIR}"
    )
  endif()

  if(
    "webpdemux" IN_LIST WebP_FIND_COMPONENTS
    AND WebP_webpdemux_FOUND
    AND NOT TARGET WebP::webpdemux
  )
    add_library(WebP::webpdemux UNKNOWN IMPORTED)

    set_target_properties(
      WebP::webpdemux
      PROPERTIES
        IMPORTED_LOCATION "${WebP_webpdemux_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${WebP_INCLUDE_DIR}"
    )
  endif()

  if(
    "libwebpmux" IN_LIST WebP_FIND_COMPONENTS
    AND WebP_libwebpmux_FOUND
    AND NOT TARGET WebP::libwebpmux
  )
    add_library(WebP::libwebpmux UNKNOWN IMPORTED)

    set_target_properties(
      WebP::libwebpmux
      PROPERTIES
        IMPORTED_LOCATION "${WebP_libwebpmux_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${WebP_INCLUDE_DIR}"
    )
  endif()
endblock()
