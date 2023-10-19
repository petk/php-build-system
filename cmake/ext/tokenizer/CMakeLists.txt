include(CMakeDependentOption)

option(EXT_TOKENIZER "Enable the tokenizer extension" ON)

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
  set(_type "SHARED")
endif()

add_library(php_tokenizer ${_type}
  tokenizer.c
  tokenizer_data.c
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
          -D PHP_EXECUTABLE=${CMAKE_BINARY_DIR}/sapi/cli/php
          -P CMakeFiles/GenerateTokenizerData.cmake
  DEPENDS ${CMAKE_SOURCE_DIR}/Zend/zend_language_parser.y
  COMMENT "Regenerating ext/tokenizer/tokenizer_data.c"
  VERBATIM
)

# The tokenizer depends on Zend language scanner definitions header.
add_dependencies(php_tokenizer zend)
