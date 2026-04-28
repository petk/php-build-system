#[=============================================================================[
# The xsl extension

This extension provides XSL standard support for performing XSLT
transformations.

## Configuration options

### PHP_EXT_XSL

* Default: `OFF`
* Values: `ON|OFF|shared`

Enables the extension.
#]=============================================================================]

cmake_minimum_required(VERSION 4.3...4.4)

project(
  PHP_EXT_XSL
  LANGUAGES C
)

include(FeatureSummary)

option(PHP_EXT_XSL "Enable the xsl extension" ${PROJECT_IS_TOP_LEVEL})

add_feature_info(
  "ext/xsl"
  PHP_EXT_XSL
  "XSL transformations (XSLT) support"
)

if(NOT PHP_EXT_XSL)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(xsl)

if(PHP_EXT_XSL STREQUAL "shared" OR PROJECT_IS_TOP_LEVEL)
  add_library(php_ext_xsl MODULE)
else()
  add_library(php_ext_xsl OBJECT)
endif()

target_sources(
  php_ext_xsl
  PRIVATE
    php_xsl.c
    php_xsl.stub.php
    xsltprocessor.c
)

target_include_directories(php_ext_xsl PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

target_compile_definitions(
  php_ext_xsl
  PRIVATE
    # TODO: Fix LIBXML_STATIC usage based on the static/shared libxml2 package.
    $<$<AND:$<PLATFORM_ID:Windows>,$<NOT:$<STREQUAL:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY>>>:DOM_EXPORTS;LIBXML_STATIC>
    # TODO: Fix based on the static/shared xslt package.
    $<$<PLATFORM_ID:Windows>:LIBXSLT_STATIC>
)

if(MSVC)
  target_link_options(
    php_ext_xsl
    PRIVATE
      $<$<CONFIG:Debug,PhpRelWithDebInfo>:LINKER:/nodefaultlib:msvcrt>
  )
endif()

include(PHP/Package/LibXml2)

set_package_properties(
  LibXml2
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the xsl extension."
)

target_link_libraries(php_ext_xsl PRIVATE LibXml2::LibXml2)

set_property(
  TARGET php_ext_xsl
  PROPERTY PHP_REQUIRED_EXTENSIONS libxml dom
)

include(PHP/Package/LibXslt)
find_package(LibXslt ${PHP_PACKAGE_LIBXSLT_MIN_VERSION})
set_package_properties(
  LibXslt
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the xsl extension."
)

target_link_libraries(php_ext_xsl PRIVATE LibXslt::LibXslt)

if(TARGET LibXslt::LibExslt)
  set(HAVE_XSL_EXSLT TRUE)

  target_link_libraries(php_ext_xsl PRIVATE LibXslt::LibExslt)

  target_compile_definitions(
    php_ext_xsl
    PRIVATE
    # TODO: Fix based on the static/shared xslt package.
    $<$<PLATFORM_ID:Windows>:LIBEXSLT_STATIC>
  )
endif()

add_feature_info(
  "ext/xsl EXSLT"
  HAVE_XSL_EXSLT
  "XSLT extensions support"
)

set(HAVE_XSL TRUE)

configure_file(cmake/config.h.in config.h)
