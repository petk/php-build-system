#[=============================================================================[
# The uri extension

Configure the `uri` extension.

This extension provides support for URI handling.
#]=============================================================================]

cmake_minimum_required(VERSION 3.25...3.31)

project(
  PhpExtensionUri
  LANGUAGES C
)

include(FeatureSummary)

add_feature_info(
  "ext/uri"
  TRUE
  "support for URI handling"
)

add_library(php_ext_uri OBJECT)

target_sources(
  php_ext_uri
  PRIVATE
    php_uri.c
    php_uri.stub.php
    uriparser/src/UriCommon.c
    uriparser/src/UriCompare.c
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
    $<$<NOT:$<PLATFORM_ID:Windows>>:uriparser/src/UriResolve.c>
    uriparser/src/UriShorten.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        php_uri.h
        uriparser/include/uriparser/Uri.h
        uriparser/include/uriparser/UriBase.h
        uriparser/include/uriparser/UriDefsAnsi.h
        uriparser/include/uriparser/UriDefsConfig.h
        uriparser/include/uriparser/UriDefsUnicode.h
        uriparser/include/uriparser/UriIp4.h
        uriparser/src/UriCommon.h
        uriparser/src/UriConfig.h
        uriparser/src/UriIp4Base.h
        uriparser/src/UriMemory.h
        uriparser/src/UriNormalizeBase.h
        uriparser/src/UriParseBase.h
)

target_compile_definitions(
  php_ext_uri
  PRIVATE
    URI_STATIC_BUILD
    ZEND_ENABLE_STATIC_TSRMLS_CACHE
)

target_include_directories(
  php_ext_uri
  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/uriparser/include
)

add_dependencies(php_ext_uri php_ext_lexbor)

set(URI_ENABLE_ANSI TRUE)
set(URI_NO_UNICODE TRUE)

configure_file(cmake/config.h.in config.h)
