php_extension(NAME "reflection" STATIC)

add_library(reflection STATIC php_reflection.c)

target_compile_definitions(reflection PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)
