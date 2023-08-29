php_extension(NAME "reflection" STATIC)

add_library(ext_reflection STATIC php_reflection.c)

target_include_directories(
  ext_reflection
  PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
)

target_compile_definitions(ext_reflection PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)
