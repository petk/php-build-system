#[=============================================================================[
# The reflection extension

Configure the `reflection` extension.

This extension is always enabled.
#]=============================================================================]

project(
  PhpExtensionReflection
  LANGUAGES C
)

include(FeatureSummary)

add_feature_info(
  "ext/reflection"
  ON
  "Reflection API to introspect PHP code"
)

add_library(php_reflection STATIC)
target_sources(
  php_reflection
  PRIVATE
    php_reflection.c
    php_reflection.stub.php
)

target_compile_definitions(
  php_reflection
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
)

add_dependencies(php_reflection php_random)
