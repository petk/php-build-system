project(
  PhpExtensionTokenizer
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)
include(PHP/AddCustomCommand)

option(EXT_TOKENIZER "Enable the tokenizer extension" ON)

add_feature_info(
  "ext/tokenizer"
  EXT_TOKENIZER
  "Interface to the PHP tokenizer embedded in the Zend engine"
)

cmake_dependent_option(
  EXT_TOKENIZER_SHARED
  "Build the tokenizer extension as a shared library"
  OFF
  "EXT_TOKENIZER;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_TOKENIZER)
  return()
endif()

if(EXT_TOKENIZER_SHARED)
  add_library(php_tokenizer SHARED)
else()
  add_library(php_tokenizer)
endif()

target_sources(
  php_tokenizer
  PRIVATE
    tokenizer_data.c
    tokenizer_data.stub.php
    tokenizer.c
    tokenizer.stub.php
)

# The tokenizer extension depends on the generated Zend scanner and parser.
add_dependencies(php_tokenizer Zend::Zend)

# Generate tokenizer data source files.
if(PHP_SOURCE_DIR)
  php_add_custom_command(
    php_generate_tokenizer_data
    OUTPUT
      ${CMAKE_CURRENT_SOURCE_DIR}/tokenizer_data.stub.php
      ${CMAKE_CURRENT_SOURCE_DIR}/tokenizer_data.c
    DEPENDS
      ${CMAKE_CURRENT_SOURCE_DIR}/tokenizer_data_gen.php
      ${PHP_SOURCE_DIR}/Zend/zend_language_parser.y
    PHP_COMMAND
      ${CMAKE_CURRENT_SOURCE_DIR}/tokenizer_data_gen.php
    COMMENT
      "[ext/tokenizer] Regenerating tokenizer_data.c and tokenizer_data.stub.php"
    VERBATIM
  )
endif()

set(HAVE_TOKENIZER 1)

configure_file(config.cmake.h.in config.h @ONLY)
