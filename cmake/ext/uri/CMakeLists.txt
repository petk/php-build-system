#[=============================================================================[
# The uri extension

Configure the `uri` extension.

This extension provides support for URI handling.

## Configuration options

### PHP_EXT_URI_EXTERNAL

* Default: `OFF`
* Values: `ON|OFF`

Use external/system uriparser library instead of the bundled uriparser library
that comes with PHP.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

project(
  PHP_EXT_URI
  LANGUAGES C
)

if(PROJECT_IS_TOP_LEVEL)
  message(
    FATAL_ERROR
    "The PHP uri extension is intended to be built only within the "
    "top-level PHP source tree (php-src)."
  )
endif()

include(FeatureSummary)

add_feature_info(
  "ext/uri"
  TRUE
  "support for URI handling"
)

option(
  PHP_EXT_URI_EXTERNAL
  "Use external/system uriparser library, instead of the bundled one"
)
mark_as_advanced(PHP_EXT_URI_EXTERNAL)
add_feature_info(
  "ext/uri external uriparser"
  PHP_EXT_URI_EXTERNAL
  "system uriparser library instead of bundled"
)

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(uri)

add_library(php_ext_uri OBJECT)

target_sources(
  php_ext_uri
  PRIVATE
    php_uri_common.c
    php_uri.c
    php_uri.stub.php
    uri_parser_php_parse_url.c
    uri_parser_rfc3986.c
    uri_parser_whatwg.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        php_uri_common.h
        php_uri.h
        uri_parser_php_parse_url.h
        uri_parser_rfc3986.h
        uri_parser_whatwg.h
)

if(PHP_EXT_URI_EXTERNAL)
  find_package(uriparser 1.0.0)
  set_package_properties(
    uriparser
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to use external uriparser library."
  )
  target_link_libraries(php_ext_uri PRIVATE uriparser::uriparser)
else()
  target_sources(
    php_ext_uri
    PRIVATE
      uriparser/src/UriCommon.c
      uriparser/src/UriCompare.c
      uriparser/src/UriCopy.c
      uriparser/src/UriEscape.c
      uriparser/src/UriFile.c
      uriparser/src/UriIp4.c
      uriparser/src/UriIp4Base.c
      uriparser/src/UriMemory.c
      uriparser/src/UriNormalize.c
      uriparser/src/UriNormalizeBase.c
      uriparser/src/UriParse.c
      uriparser/src/UriParseBase.c
      uriparser/src/UriQuery.c
      uriparser/src/UriRecompose.c
      uriparser/src/UriResolve.c
      uriparser/src/UriSetFragment.c
      uriparser/src/UriSetHostAuto.c
      uriparser/src/UriSetHostCommon.c
      uriparser/src/UriSetHostIp4.c
      uriparser/src/UriSetHostIp6.c
      uriparser/src/UriSetHostIpFuture.c
      uriparser/src/UriSetHostRegName.c
      uriparser/src/UriSetPath.c
      uriparser/src/UriSetPort.c
      uriparser/src/UriSetQuery.c
      uriparser/src/UriSetScheme.c
      uriparser/src/UriSetUserInfo.c
      uriparser/src/UriShorten.c
      uriparser/src/UriVersion.c
    PUBLIC
      FILE_SET HEADERS
        FILES
          uriparser/include/uriparser/Uri.h
          uriparser/include/uriparser/UriBase.h
          uriparser/include/uriparser/UriDefsAnsi.h
          uriparser/include/uriparser/UriDefsConfig.h
          uriparser/include/uriparser/UriDefsUnicode.h
          uriparser/include/uriparser/UriIp4.h
  )

  target_compile_definitions(php_ext_uri PRIVATE URI_STATIC_BUILD)

  target_include_directories(
    php_ext_uri
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/uriparser/include
  )
endif()

target_compile_definitions(php_ext_uri PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

add_dependencies(php_ext_uri php_ext_lexbor)

configure_file(cmake/config.h.in config.h)
