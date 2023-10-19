option(EXT_DL_TEST "Enable the dl_test extension" OFF)

if(NOT EXT_DL_TEST)
  return()
endif()

# The dl_test extension can be built only as a shared library.
add_library(php_dl_test SHARED
  dl_test.c
)

target_compile_definitions(php_dl_test PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)
