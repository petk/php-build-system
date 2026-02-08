function(php_tests_integration dir)
  cmake_parse_arguments(
    PARSE_ARGV
    3
    parsed # prefix
    "" # options
    "" # one-value keywords
    "ARGS" # multi-value keywords
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(parsed_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "Missing values for: ${parsed_KEYWORDS_MISSING_VALUES}")
  endif()

  add_test(
    NAME PhpCMakeIntegration${dir}
    COMMAND
      ${CMAKE_COMMAND}
      -B ${CMAKE_CURRENT_BINARY_DIR}/${dir}
      -S ${CMAKE_CURRENT_SOURCE_DIR}/${dir}
  )
endfunction()

php_tests_integration(CheckBuiltin)
php_tests_integration(SearchLibraries)
