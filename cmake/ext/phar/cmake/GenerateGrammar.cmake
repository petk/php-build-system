# Generate lexer.

include(FeatureSummary)
include(PHP/Package/RE2C)

if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/phar_path_check.c)
  set_package_properties(RE2C PROPERTIES TYPE REQUIRED)
endif()

if(RE2C_FOUND)
  re2c(
    php_ext_phar_path_check
    phar_path_check.re
    ${CMAKE_CURRENT_SOURCE_DIR}/phar_path_check.c
    OPTIONS -b
    CODEGEN
  )
endif()
