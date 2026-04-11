function(php_add_test)
  cmake_parse_arguments(
    PARSE_ARGV
    0
    parsed
    ""
    "NAME;DIR"
    ""
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(parsed_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "Missing values for: ${parsed_KEYWORDS_MISSING_VALUES}")
  endif()

  if(NOT parsed_NAME)
    message(FATAL_ERROR "Missing NAME argument.")
  endif()

  if(NOT parsed_DIR)
    message(FATAL_ERROR "Missing PATH argument.")
  endif()

  add_test(
    NAME ${parsed_NAME}
    COMMAND
      ${CMAKE_COMMAND}
      -DCMAKE_MODULE_PATH=${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../../modules
      -B ${CMAKE_CURRENT_BINARY_DIR}/${parsed_DIR}
      -S ${CMAKE_CURRENT_SOURCE_DIR}/${parsed_DIR}
  )
endfunction()

php_add_test(NAME PhpCMakeModuleCheckBuiltin DIR CheckBuiltin)

php_add_test(
  NAME PhpCMakeModuleCoreExtensionsSorting
  DIR Core/Extensions/Sorting
)

php_add_test(
  NAME PhpCMakeModuleCoreExtensionsVariables
  DIR Core/Extensions/Variables
)

php_add_test(
  NAME PhpCMakeModuleInternalSummaryConflictingExtensions
  DIR Internal/Summary/ConflictingExtensions
)
set_tests_properties(
  PhpCMakeModuleInternalSummaryConflictingExtensions
  PROPERTIES
    WILL_FAIL TRUE
    FAIL_REGULAR_EXPRESSION "Please reconfigure PHP extensions, aborting CMake run."
)

php_add_test(
  NAME PhpCMakeModuleInternalSummaryRequiredExtensions
  DIR Internal/Summary/RequiredExtensions
)
set_tests_properties(
  PhpCMakeModuleInternalSummaryRequiredExtensions
  PROPERTIES
    WILL_FAIL TRUE
    FAIL_REGULAR_EXPRESSION "Please reconfigure PHP extensions, aborting CMake run."
)

php_add_test(NAME PhpCMakeModuleSearchLibraries DIR SearchLibraries)
