# Generate lexer files.

include(FeatureSummary)
include(PHP/Package/RE2C)

if(
  NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/url_scanner_ex.c
  OR NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/var_unserializer.c
)
  set_package_properties(RE2C PROPERTIES TYPE REQUIRED)
endif()

if(RE2C_FOUND)
  re2c(
    php_ext_standard_url_scanner_ex
    url_scanner_ex.re
    ${CMAKE_CURRENT_SOURCE_DIR}/url_scanner_ex.c
    OPTIONS --bit-vectors
    CODEGEN
  )

  re2c(
    php_ext_standard_var_unserializer
    var_unserializer.re
    ${CMAKE_CURRENT_SOURCE_DIR}/var_unserializer.c
    OPTIONS --bit-vectors
    CODEGEN
  )
endif()
