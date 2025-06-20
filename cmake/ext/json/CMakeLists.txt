#[=============================================================================[
# The json extension

Configure the `json` extension.

This extension provides support for working with JavaScript Object Notation
(JSON) and is always enabled.
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.0)

project(
  PhpExtensionJson
  LANGUAGES C
)

include(FeatureSummary)

add_feature_info(
  "ext/json"
  TRUE
  "JavaScript Object Notation"
)

add_library(php_ext_json OBJECT)

target_sources(
  php_ext_json
  PRIVATE
    json_encoder.c
    json_parser.tab.c
    json_scanner.c
    json.c
    json.stub.php
  PUBLIC
    FILE_SET HEADERS
      FILES
        php_json_parser.h
        php_json_scanner.h
        php_json.h
)

target_compile_definitions(php_ext_json PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

################################################################################
# Generate parser and lexer files.
################################################################################

include(cmake/GenerateGrammar.cmake)
