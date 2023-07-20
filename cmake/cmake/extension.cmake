#[=============================================================================[
Creates a new PHP extension.

php_extension(NAME <name>)
]=============================================================================]#

set(PHP_EXTENSIONS "" CACHE INTERNAL "")

function(php_extension)
  cmake_parse_arguments(PARSE_ARGV 0 PARSED_ARGS "" "NAME" "")

  if(NOT PARSED_ARGS_NAME)
    message(FATAL_ERROR "php_extension expects a PHP extension name")
  endif()

  message(STATUS "Enabling extension ${PARSED_ARGS_NAME}")

  list(APPEND PHP_EXTENSIONS ${PARSED_ARGS_NAME})
  set(PHP_EXTENSIONS ${PHP_EXTENSIONS} CACHE INTERNAL "")

  # Define constant for php_config.h. Some extensions are always available so
  # they don't have HAVE_* constants.
  set(default_extensions "date;hash;json;pcre;random;reflection;spl;standard")

  if(NOT "${PARSED_ARGS_NAME}" IN_LIST default_extensions)
    string(TOUPPER "HAVE_${PARSED_ARGS_NAME}" DYNAMIC_NAME)
    set(${DYNAMIC_NAME} 1 CACHE STRING "Whether to enable the ${PARSED_ARGS_NAME} extension.")
  endif()
endfunction()
