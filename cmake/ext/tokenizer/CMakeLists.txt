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
  # Patch tokenizer_data_gen.php to generate output only when needed.
  file(READ "${CMAKE_CURRENT_SOURCE_DIR}/tokenizer_data_gen.php" content)
  string(
    REPLACE
    [[$infile = __DIR__ . '/../../Zend/zend_language_parser.y';]]
    "$infile = '${PHP_SOURCE_DIR}/Zend/zend_language_parser.y';"
    content
    "${content}"
  )
  string(
    REPLACE
    [[$outfile_stub = __DIR__ . '/tokenizer_data.stub.php';]]
    "$outfile_stub =  '${CMAKE_CURRENT_SOURCE_DIR}/tokenizer_data.stub.php';"
    content
    "${content}"
  )
  string(
    REPLACE
    [[$outfile_c = __DIR__ . '/tokenizer_data.c';]]
    "$outfile_c = '${CMAKE_CURRENT_SOURCE_DIR}/tokenizer_data.c';"
    content
    "${content}"
  )
  string(
    REPLACE
    [[file_put_contents($outfile_stub, $result);

echo "Wrote $outfile_stub\n";]]
    [[
      if (file_exists($outfile_stub)) {
        $currentContent = file_get_contents($outfile_stub);
      }
      if ($currentContent !== $result) {
        file_put_contents($outfile_stub, $result);
        echo "Wrote $outfile_stub\n";
      }
    ]]
    content
    "${content}"
  )
  string(
    REPLACE
    [[file_put_contents($outfile_c, $result);

echo "Wrote $outfile_c\n";]]
    [[
      $currentContent = '';
      if (file_exists($outfile_c)) {
        $currentContent = file_get_contents($outfile_c);
      }
      if ($currentContent !== $result) {
        file_put_contents($outfile_c, $result);
        echo "Wrote $outfile_c\n";
      }
    ]]
    content
    "${content}"
  )
  file(
    WRITE
    "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/tokenizer_data_gen.php"
    "${content}"
  )

  add_custom_command(
    OUTPUT
      php_tokenizer_data
    COMMAND
      ${PHP_EXECUTABLE}
        ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/tokenizer_data_gen.php
    DEPENDS
      ${CMAKE_CURRENT_SOURCE_DIR}/tokenizer_data_gen.php
      ${PHP_SOURCE_DIR}/Zend/zend_language_parser.y
    COMMENT "[ext/tokenizer] Regenerating ext/tokenizer/tokenizer_data.c"
    VERBATIM
  )
  add_custom_target(php_tokenizer_generate_data ALL DEPENDS php_tokenizer_data)
  set_property(SOURCE php_tokenizer_data PROPERTY SYMBOLIC TRUE)
endif()
