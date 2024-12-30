# Generate lexer.

include(FeatureSummary)
include(PHP/Package/RE2C)

if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/pdo_sql_parser.c)
  set_package_properties(RE2C PROPERTIES TYPE REQUIRED)
endif()

if(RE2C_FOUND)
  re2c(
    php_ext_pdo_sql_parser
    pdo_sql_parser.re
    ${CMAKE_CURRENT_SOURCE_DIR}/pdo_sql_parser.c
    CODEGEN
  )
endif()
