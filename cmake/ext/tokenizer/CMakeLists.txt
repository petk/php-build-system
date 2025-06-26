#[=============================================================================[
# The tokenizer extension

Configure the `tokenizer` extension.

This extension provides an interface to the PHP tokenizer embedded in the Zend
Engine.

## PHP_EXT_TOKENIZER

* Default: `ON`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_TOKENIZER_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.0)

project(
  tokenizer
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_TOKENIZER "Enable the tokenizer extension" ON)

add_feature_info(
  "ext/tokenizer"
  PHP_EXT_TOKENIZER
  "PHP tokenizer interface"
)

cmake_dependent_option(
  PHP_EXT_TOKENIZER_SHARED
  "Build the tokenizer extension as a shared library"
  OFF
  PHP_EXT_TOKENIZER
  OFF
)

if(NOT PHP_EXT_TOKENIZER)
  return()
endif()

if(PHP_EXT_TOKENIZER_SHARED)
  add_library(php_ext_tokenizer MODULE)
else()
  add_library(php_ext_tokenizer OBJECT)
endif()

target_sources(
  php_ext_tokenizer
  PRIVATE
    tokenizer_data.c
    tokenizer_data.stub.php
    tokenizer.c
    tokenizer.stub.php
)

# Generate tokenizer data source files.
if(EXISTS ${PHP_SOURCE_DIR}/Zend/zend_language_parser.y)
  # The tokenizer extension depends on the generated Zend scanner and parser.
  add_dependencies(php_ext_tokenizer Zend::Zend)

  add_custom_command(
    OUTPUT
      ${CMAKE_CURRENT_SOURCE_DIR}/tokenizer_data.stub.php
      ${CMAKE_CURRENT_SOURCE_DIR}/tokenizer_data.c
    DEPENDS
      ${PHP_SOURCE_DIR}/Zend/zend_language_parser.y
    COMMAND
      ${CMAKE_COMMAND}
      -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/GenerateTokenizerData.cmake
    COMMENT
      "[ext/tokenizer] Regenerating tokenizer_data.c and tokenizer_data.stub.php"
    VERBATIM
  )
endif()
