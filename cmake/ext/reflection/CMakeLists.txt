#[=============================================================================[
# The reflection extension

Configure the `reflection` extension.

This extension provides support for Reflection API to introspect PHP code and is
always enabled.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

project(
  PHP_EXT_REFLECTION
  LANGUAGES C
)

if(PROJECT_IS_TOP_LEVEL)
  message(
    FATAL_ERROR
    "The PHP reflection extension is intended to be built only within the "
    "top-level PHP source tree (php-src)."
  )
endif()

include(FeatureSummary)

add_feature_info(
  "ext/reflection"
  TRUE
  "PHP code introspection API"
)

include(PHP/Extension)
php_extension(reflection)

add_library(php_ext_reflection OBJECT)
target_sources(
  php_ext_reflection
  PRIVATE
    php_reflection.c
    php_reflection.stub.php
)

target_compile_definitions(
  php_ext_reflection
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE
)

add_dependencies(php_ext_reflection php_ext_random)
