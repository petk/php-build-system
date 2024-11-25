#[=============================================================================[
# The dl_test extension

Configure the `dl_test` extension.

This extension provides support for testing PHP `dl()` function relevant when
running PHP tests during development.

## EXT_DL_TEST

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

This extension is always built as shared when enabled.
#]=============================================================================]

project(
  PhpExtensionDlTest
  LANGUAGES C
)

include(FeatureSummary)

option(EXT_DL_TEST "Enable the dl_test extension")

add_feature_info(
  "ext/dl_test"
  EXT_DL_TEST
  "support for testing dl() function"
)

if(NOT EXT_DL_TEST)
  return()
endif()

# The dl_test extension can be built only as a shared library.
add_library(php_dl_test SHARED)
target_sources(
  php_dl_test
  PRIVATE
    dl_test.c
    dl_test.stub.php
)

target_compile_definitions(
  php_dl_test
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE
    # TODO: PHP_DL_TEST_EXPORTS is currently unused.
    $<$<AND:$<PLATFORM_ID:Windows>,$<IN_LIST:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>>:PHP_DL_TEST_EXPORTS>
)
