include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_SIMPLEXML "Enable the simplexml extension" ON)

add_feature_info("ext/simplexml" EXT_SIMPLEXML
  "Toolset for converting XML to a processable object."
)

cmake_dependent_option(
  EXT_SIMPLEXML_SHARED
  "Build the simplexml extension as a shared library"
  OFF
  "EXT_SIMPLEXML;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_SIMPLEXML)
  return()
endif()

if(EXT_SIMPLEXML_SHARED)
  add_library(php_simplexml SHARED)
else()
  add_library(php_simplexml)
endif()

target_sources(php_simplexml PRIVATE
  simplexml.c
)

set_property(
  TARGET php_simplexml
  PROPERTY PHP_EXTENSION_DEPENDENCIES php_libxml
)

find_package(LibXml2 ${PHP_LIBXML2_MIN_VERSION})
set_package_properties(LibXml2 PROPERTIES
  TYPE REQUIRED
  PURPOSE "Necessary to enable the simplexml extension."
)

target_link_libraries(php_simplexml PRIVATE LibXml2::LibXml2)

target_sources(
  php_simplexml
  PUBLIC FILE_SET HEADERS
    BASE_DIRS "${PROJECT_SOURCE_DIR}"
    FILES
      php_simplexml_exports.h
      php_simplexml.h
)

install(
  TARGETS php_simplexml
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET HEADERS
)
