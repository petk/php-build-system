include(FeatureSummary)

option(EXT_DL_TEST "Enable the dl_test extension" OFF)

add_feature_info("ext/dl_test" EXT_DL_TEST
  "Adds support for testing dl() function."
)

if(NOT EXT_DL_TEST)
  return()
endif()

# The dl_test extension can be built only as a shared library.
add_library(php_dl_test SHARED
  dl_test.c
)

target_compile_definitions(php_dl_test PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)
