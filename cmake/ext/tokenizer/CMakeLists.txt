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

# The tokenizer extension depends on the generated Zend scanner and parser.
add_dependencies(php_tokenizer Zend::Zend)

if(PHPSystem_EXECUTABLE)
  set(PHP_EXECUTABLE ${PHPSystem_EXECUTABLE})
elseif(NOT CMAKE_CROSSCOMPILING)
  set(PHP_EXECUTABLE "$<TARGET_FILE:php_cli>")
elseif(CMAKE_CROSSCOMPILING AND CMAKE_CROSSCOMPILING_EMULATOR)
  set(PHP_EXECUTABLE "${CMAKE_CROSSCOMPILING_EMULATOR};$<TARGET_FILE:php_cli>")
endif()

if(PHP_EXECUTABLE)
  add_custom_command(
    OUTPUT php_tokenizer_data
    COMMAND ${PHP_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/tokenizer_data_gen.php
    DEPENDS
      php_cli
      ${PHP_SOURCE_DIR}/Zend/zend_language_parser.y
    COMMENT "[ext/tokenizer] Regenerating ext/tokenizer/tokenizer_data.c"
    VERBATIM
  )

  add_custom_target(php_tokenizer_generate_data ALL DEPENDS php_tokenizer_data)

  set_property(SOURCE php_tokenizer_data PROPERTY SYMBOLIC TRUE)
endif()
