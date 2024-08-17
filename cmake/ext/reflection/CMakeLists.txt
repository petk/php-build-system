add_library(php_reflection STATIC php_reflection.c)

target_compile_definitions(
  php_reflection
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
)

add_dependencies(php_reflection php_random)
