#[=============================================================================[
# FindCURL

This module overrides the upstream CMake `FindCURL` module with few
customizations:

* Fixed CURL static library.

  When using the `CURL_USE_STATIC_LIBS` hint variable, the upstream module
  doesn't find static library properly. If CURL is found in *config mode*, the
  upstream CURL config files don't provide the `CURL_USE_STATIC_LIBS` hint
  variable. This module bypasses this issue by providing additional imported
  target:

  * `CURL::CURL` - Target encapsulating curl library usage requirements,
    available if curl is found. Contains either shared curl library or when the
    `CURL_USE_STATIC_LIBS` hint variable is set to boolean true, it contains the
    static curl library.

See also:

* https://cmake.org/cmake/help/latest/module/FindCURL.html
* https://gitlab.kitware.com/cmake/cmake/-/issues/25994
#]=============================================================================]

# Find package with upstream CMake find module. Absolute path prevents the
# maximum nesting/recursion depth error on some systems, like macOS.
include(${CMAKE_ROOT}/Modules/FindCURL.cmake)

if(NOT CURL_FOUND OR TARGET CURL::CURL)
  return()
endif()

# TODO: Improve this further.

if(NOT CURL_USE_STATIC_LIBS)
  if(TARGET CURL::libcurl_shared)
    add_library(CURL::CURL ALIAS CURL::libcurl_shared)
  else()
    get_target_property(aliased CURL::libcurl ALIASED_TARGET)
    if(aliased)
      add_library(CURL::CURL ALIAS ${aliased})
    else()
      add_library(CURL::CURL ALIAS CURL::libcurl)
    endif()
  endif()

  return()
endif()

if(TARGET CURL::libcurl_static)
  add_library(CURL::CURL ALIAS CURL::libcurl_static)
else()
  # Support preference of static libs by adjusting CMAKE_FIND_LIBRARY_SUFFIXES.
  set(_curl_cmake_find_library_suffixes ${CMAKE_FIND_LIBRARY_SUFFIXES})
  if(WIN32)
    list(INSERT CMAKE_FIND_LIBRARY_SUFFIXES 0 .lib .a)
  else()
    set(CMAKE_FIND_LIBRARY_SUFFIXES .a)
  endif()

  find_library(CURL_LIBRARY_STATIC NAMES curl)
  mark_as_advanced(CURL_LIBRARY_STATIC)

  # Restore the original find library ordering.
  set(CMAKE_FIND_LIBRARY_SUFFIXES ${_curl_cmake_find_library_suffixes})
  unset(_curl_cmake_find_library_suffixes)

  if(CURL_LIBRARY_STATIC)
    add_library(CURL::CURL UNKNOWN IMPORTED)

    set_target_properties(
      CURL::CURL
      PROPERTIES
        IMPORTED_LOCATION "${CURL_LIBRARY_STATIC}"
        INTERFACE_INCLUDE_DIRECTORIES "${CURL_INCLUDE_DIRS}"
    )

    if(PC_CURL_FOUND AND PC_CURL_STATIC_LIBRARIES)
      set(_curl_static_libraries "${PC_CURL_STATIC_LIBRARIES}")
      list(REMOVE_ITEM _curl_static_libraries curl)
      list(REMOVE_DUPLICATES _curl_static_libraries)
      set_target_properties(
        CURL::CURL
        PROPERTIES INTERFACE_LINK_LIBRARIES "${_curl_static_libraries}"
      )
    endif()

    get_target_property(link_options CURL::libcurl INTERFACE_LINK_OPTIONS)
    message(STATUS "link_options=${link_options}")
    if(link_options)
      set_target_properties(
        CURL::CURL
        PROPERTIES INTERFACE_LINK_OPTIONS "${link_options}"
      )
    endif()

    get_target_property(compile_options CURL::libcurl INTERFACE_COMPILE_OPTIONS)
    message(STATUS "compile_options=${compile_options}")
    if(compile_options)
      set_target_properties(
        CURL::CURL
        PROPERTIES INTERFACE_COMPILE_OPTIONS "${compile_options}"
      )
    endif()

    if(WIN32)
      set_property(
        TARGET CURL::CURL
        APPEND
        PROPERTY INTERFACE_COMPILE_DEFINITIONS "CURL_STATICLIB"
      )
    endif()
  else()
    add_library(CURL::CURL ALIAS CURL::libcurl)
  endif()
endif()
