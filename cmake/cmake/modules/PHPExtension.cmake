#[=============================================================================[
Creates a new PHP extension.

The module defines the following variables

``PHP_EXTENSIONS``
  a list of all enabled extensions

``PHP_EXTENSIONS_SHARED``
  a list of all enabled shared extensions

php_extension(NAME <name> [SHARED])
]=============================================================================]#

set(PHP_EXTENSIONS "" CACHE INTERNAL "")
set(PHP_EXTENSIONS_SHARED "" CACHE INTERNAL "")

function(php_extension)
  # No additional options needed.
  set(options SHARED STATIC)
  set(oneValueArgs NAME)

  cmake_parse_arguments(PHP_EXTENSION "${options}" "${oneValueArgs}" "" ${ARGN})

  # Check if the NAME argument is provided
  if(NOT PHP_EXTENSION_NAME)
    message(FATAL_ERROR "php_extension expects the NAME argument. Please use 'NAME' in front of the extension name.")
  endif()

  if(PHP_EXTENSION_SHARED)
    message(STATUS "Enabling extension ${PHP_EXTENSION_NAME} as shared.")

    list(APPEND PHP_EXTENSIONS_SHARED ${PHP_EXTENSION_NAME})
    set(PHP_EXTENSIONS_SHARED ${PHP_EXTENSIONS_SHARED} CACHE INTERNAL "")
  else()
    message(STATUS "Enabling extension ${PHP_EXTENSION_NAME} as static.")
  endif()

  list(APPEND PHP_EXTENSIONS ${PHP_EXTENSION_NAME})
  set(PHP_EXTENSIONS ${PHP_EXTENSIONS} CACHE INTERNAL "")

  # Define constant for php_config.h. Some extensions are always available so
  # they don't have HAVE_* constants.
  set(default_extensions "date;hash;json;pcre;random;reflection;spl;standard")

  if(NOT "${PHP_EXTENSION_NAME}" IN_LIST default_extensions)
    string(TOUPPER "HAVE_${PHP_EXTENSION_NAME}" DYNAMIC_NAME)
    set(${DYNAMIC_NAME} 1 CACHE STRING "Whether to enable the ${PHP_EXTENSION_NAME} extension.")
  endif()
endfunction()
