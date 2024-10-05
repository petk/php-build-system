include(FeatureSummary)

add_feature_info(
  "ext/json"
  ON
  "JavaScript Object Notation"
)

add_library(php_json STATIC)

target_sources(
  php_json
  PRIVATE
    json_encoder.c
    json_parser.tab.c
    json_scanner.c
    json.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        php_json_parser.h
        php_json_scanner.h
        php_json.h
)

target_compile_definitions(php_json PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

if(BISON_FOUND)
  bison_target(
    php_json_parser
    json_parser.y
    ${CMAKE_CURRENT_SOURCE_DIR}/json_parser.tab.c
    COMPILE_FLAGS "-Wall --defines -l"
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
    OPTIONS -bci
  )
endif()

# HAVE_JSON is always 1 as of php 8.0 and the constant will be removed in the
# future. Note that HAVE_JSON was never defined for Windows builds.
if(NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(HAVE_JSON 1 CACHE INTERNAL "Whether to enable the json extension.")
endif()
