include(CMakeDependentOption)
include(FeatureSummary)

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
    tokenizer.c
)

# The ext/tokenizer depends on the generated Zend language scanner header.
add_dependencies(php_tokenizer zend_language_scanner)

if(PHPSystem_EXECUTABLE)
  set(PHP_EXECUTABLE ${PHPSystem_EXECUTABLE})
elseif(NOT CMAKE_CROSSCOMPILING)
  set(PHP_EXECUTABLE "$<TARGET_FILE:php_cli>")
endif()

if(PHP_EXECUTABLE)
  # Run the ext/tokenizer/tokenizer_data_gen.php script.
  file(
    GENERATE
    OUTPUT CMakeFiles/GenerateTokenizerData.cmake
    CONTENT [[
      if(EXISTS ${PHP_EXECUTABLE})
        execute_process(
          COMMAND ${PHP_EXECUTABLE} ${CURRENT_SOURCE_DIR}/tokenizer_data_gen.php
        )
      endif()
    ]]
  )

  add_custom_command(
    OUTPUT php_tokenizer_data
    COMMAND ${CMAKE_COMMAND}
            -D PHP_EXECUTABLE=${PHP_EXECUTABLE}
            -D CURRENT_SOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}
            -P CMakeFiles/GenerateTokenizerData.cmake
    DEPENDS ${PHP_SOURCE_DIR}/Zend/zend_language_parser.y
    COMMENT "[ext/tokenizer] Regenerating ext/tokenizer/tokenizer_data.c"
    VERBATIM
  )

  add_custom_target(php_tokenizer_generate_data ALL DEPENDS php_tokenizer_data)

  set_property(SOURCE php_tokenizer_data PROPERTY SYMBOLIC TRUE)
endif()
