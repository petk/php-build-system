#[=============================================================================[
# The xsl extension

Configure the `xsl` extension.

This extension provides XSL standard support for performing XSLT
transformations.

## PHP_EXT_XSL

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_XSL_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.0)

project(
  PhpExtensionXsl
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_XSL "Enable the xsl extension")

add_feature_info(
  "ext/xsl"
  PHP_EXT_XSL
  "XSL transformations (XSLT) support"
)

cmake_dependent_option(
  PHP_EXT_XSL_SHARED
  "Build the xsl extension as a shared library"
  OFF
  "PHP_EXT_XSL;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT PHP_EXT_XSL)
  return()
endif()

if(PHP_EXT_XSL_SHARED)
  add_library(php_ext_xsl SHARED)
else()
  add_library(php_ext_xsl)
endif()

target_sources(
  php_ext_xsl
  PRIVATE
    php_xsl.c
    php_xsl.stub.php
    xsltprocessor.c
)

target_compile_definitions(
  php_ext_xsl
  PRIVATE
    # TODO: Fix LIBXML_STATIC usage based on the static/shared libxml2 package.
    $<$<AND:$<PLATFORM_ID:Windows>,$<NOT:$<IN_LIST:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>>>:DOM_EXPORTS;LIBXML_STATIC>
    # TODO: Fix based on the static/shared xslt package.
    $<$<PLATFORM_ID:Windows>:LIBXSLT_STATIC>
)

target_link_options(
  php_ext_xsl
  PRIVATE
    $<$<AND:$<CONFIG:Debug,DebugAssertions>,$<C_COMPILER_ID:MSVC>>:LINKER:/nodefaultlib:msvcrt>
)

include(Packages/LibXml2)

set_package_properties(
  LibXml2
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the xsl extension."
)

target_link_libraries(php_ext_xsl PRIVATE LibXml2::LibXml2)

add_dependencies(php_ext_xsl php_ext_libxml php_ext_dom)

find_package(LibXslt 1.1.0)
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
