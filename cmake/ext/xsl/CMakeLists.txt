include(CMakeDependentOption)

option(EXT_XSL "Enable the xsl extension" OFF)

cmake_dependent_option(
  EXT_XSL_SHARED
  "Build the xsl extension as a shared library"
  OFF
  "EXT_XSL;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_XSL)
  return()
endif()

if(EXT_XSL_SHARED)
  set(_type "SHARED")
endif()

add_library(php_xsl ${_type}
  php_xsl.c
  xsltprocessor.c
)

find_package(LibXml2 ${PHP_LIBXML2_MIN_VERSION} REQUIRED)

target_link_libraries(php_xsl PRIVATE LibXml2::LibXml2)

set_target_properties(
  php_xsl
  PROPERTIES PHP_EXTENSION_DEPENDENCIES "php_libxml;php_dom"
)

find_package(LibXslt 1.1.0 REQUIRED)
# Upstream CMake module doesn't mark these as advanced variables.
# TODO: Remove once fixed upstream.
# https://gitlab.kitware.com/cmake/cmake/-/merge_requests/8807
if(CMAKE_VERSION VERSION_LESS 3.28)
  mark_as_advanced(LIBXSLT_EXSLT_INCLUDE_DIR LIBXSLT_LIBRARY)
endif()

target_link_libraries(php_xsl PRIVATE LibXslt::LibXslt)

if(TARGET LibXslt::LibExslt)
  set(HAVE_XSL_EXSLT 1 CACHE INTERNAL "Whether the libexslt library is available")

  target_link_libraries(php_xsl PRIVATE LibXslt::LibExslt)
endif()
