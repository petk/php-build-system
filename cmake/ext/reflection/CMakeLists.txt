php_extension(NAME "reflection" STATIC)

add_library(ext_reflection STATIC php_reflection.c)

target_compile_definitions(ext_reflection PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)
