include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_TOKENIZER "Enable the tokenizer extension" ON)

add_feature_info(
  "ext/tokenizer"
  EXT_TOKENIZER
  "Interface to the PHP tokenizer embedded in the Zend engine."
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
    tokenizer.c
)

# Run the ext/tokenizer/tokenizer_data_gen.php script after PHP cli SAPI has
# been built depending on the state of Zend/zend_language_parser.y.
file(
  GENERATE
  OUTPUT CMakeFiles/GenerateTokenizerData.cmake
  CONTENT "
    if(EXISTS \$\{PHP_EXECUTABLE\})
      execute_process(
        COMMAND \$\{PHP_EXECUTABLE\} ${CMAKE_CURRENT_SOURCE_DIR}/tokenizer_data_gen.php
      )
    endif()
  "
)

add_custom_command(
  OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/tokenizer_data.c
  COMMAND ${CMAKE_COMMAND}
          -D PHP_EXECUTABLE=${PHP_BINARY_DIR}/sapi/cli/php
          -P CMakeFiles/GenerateTokenizerData.cmake
  DEPENDS ${PHP_SOURCE_DIR}/Zend/zend_language_parser.y
  COMMENT "[ext/tokenizer] Regenerating ext/tokenizer/tokenizer_data.c"
  VERBATIM
)

# The tokenizer depends on Zend language scanner definitions header.
add_dependencies(php_tokenizer Zend::Zend)
