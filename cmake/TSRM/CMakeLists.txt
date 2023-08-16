message(STATUS "Checking for POSIX threads")

add_library(TSRM TSRM.c)

target_compile_definitions(TSRM PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)
