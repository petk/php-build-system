#[=============================================================================[
# The json extension

Configure the `json` extension.

This extension provides support for working with JavaScript Object Notation
(JSON) and is always enabled.
#]=============================================================================]

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

add_library(php_json OBJECT)

target_sources(
  php_json
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

target_compile_definitions(php_json PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

if(BISON_FOUND)
  bison_target(
    php_json_parser
    json_parser.y
    ${CMAKE_CURRENT_SOURCE_DIR}/json_parser.tab.c
    COMPILE_FLAGS "${PHP_DEFAULT_BISON_FLAGS}"
    VERBOSE REPORT_FILE json_parser.tab.output
    DEFINES_FILE ${CMAKE_CURRENT_SOURCE_DIR}/json_parser.tab.h
  )

  add_custom_target(php_json_parser DEPENDS ${BISON_TARGET_outputs})
  add_dependencies(php_generate_files php_json_parser)
endif()

if(RE2C_FOUND)
  re2c_target(
    php_json_scanner
    json_scanner.re
    ${CMAKE_CURRENT_SOURCE_DIR}/json_scanner.c
    HEADER ${CMAKE_CURRENT_SOURCE_DIR}/php_json_scanner_defs.h
    OPTIONS -bc
  )
endif()
