# The dl_test extension can be built either as shared or disabled.
option(EXT_DL_TEST "Whether to enable the dl_test extension" OFF)

if(NOT EXT_DL_TEST)
  return()
endif()

php_extension(NAME "dl_test" SHARED)

add_library(php_dl_test SHARED
  dl_test.c
)

target_compile_definitions(php_dl_test PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)
