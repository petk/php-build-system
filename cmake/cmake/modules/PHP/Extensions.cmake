#[=============================================================================[
Module that exposes a php_extension() function for using in ext/*/CMakeLists.txt
files.

It is intended to be used in the top project level CMakeLists.txt file. It
traverses all PHP extensions and processes their CMakeLists.txt files. Extension
directories are sorted by the priority value from php_extension().

Function:
  php_extension(NAME <name> [SHARED | STATIC]
                [PRIORITY <value>]
                [DEPENDS depends...])

  PRIORITY number can be used to indicate to add the extension subdirectory
  prior to other extensions. Due to CMake nature, directory that is added via
  add_subdirectory later won't be visible in the configuration phase for
  extensions added before. This enables setting some extension variables to
  other extensions.

The module sets the following variables:

PHP_EXTENSIONS
  A list of all enabled extensions.

PHP_EXTENSIONS_STATIC
  A list of all enabled static extensions.

PHP_EXTENSIONS_SHARED
  A list of all enabled shared extensions.
]=============================================================================]#

set(PHP_EXTENSIONS "" CACHE INTERNAL "")
set(PHP_EXTENSIONS_STATIC "" CACHE INTERNAL "")
set(PHP_EXTENSIONS_SHARED "" CACHE INTERNAL "")

function(php_extension)
  set(one_value_args NAME PRIORITY)
  set(multi_value_args DEPENDS)
  set(options SHARED STATIC)

  cmake_parse_arguments(PHP_EXTENSION "${options}" "${one_value_args}" "${multi_value_args}" "" ${ARGN})

  # Check if the NAME argument is provided
  if(NOT PHP_EXTENSION_NAME)
    message(FATAL_ERROR "php_extension expects the NAME argument. Please use 'NAME' in front of the extension name.")
  endif()

  if(PHP_EXTENSION_SHARED)
    message(STATUS "Enabling extension ${PHP_EXTENSION_NAME} as shared.")

    set(
      PHP_EXTENSIONS_SHARED
      ${PHP_EXTENSIONS_SHARED} ${PHP_EXTENSION_NAME}
      CACHE INTERNAL ""
    )

    string(TOUPPER "COMPILE_DL_${PHP_EXTENSION_NAME}" DYNAMIC_NAME)
    set(${DYNAMIC_NAME} 1 CACHE INTERNAL "Whether to build ${PHP_EXTENSION_NAME} as dynamic module")
  else()
    message(STATUS "Enabling extension ${PHP_EXTENSION_NAME} as static.")

    set(
      PHP_EXTENSIONS_STATIC
      ${PHP_EXTENSIONS_STATIC} ${PHP_EXTENSION_NAME}
      CACHE INTERNAL ""
    )
  endif()

  set(
    PHP_EXTENSIONS
    ${PHP_EXTENSIONS} ${PHP_EXTENSION_NAME}
    CACHE INTERNAL ""
  )

  # Define constant for php_config.h. Some extensions are always available so
  # they don't have HAVE_* constants.
  set(default_extensions "date;hash;json;pcre;random;reflection;spl;standard")

  if(NOT "${PHP_EXTENSION_NAME}" IN_LIST default_extensions)
    string(TOUPPER "HAVE_${PHP_EXTENSION_NAME}" DYNAMIC_NAME)
    set(${DYNAMIC_NAME} 1 CACHE INTERNAL "Whether to enable the ${PHP_EXTENSION_NAME} extension.")
  endif()
endfunction()

function(_php_get_extensions result directory level)
  file(GLOB_RECURSE subdirectories LIST_DIRECTORIES TRUE "${directory}/*/" "ext/*/CMakeLists.txt")
  set(directories "")

  foreach(dir ${subdirectories})
    if(EXISTS "${dir}/CMakeLists.txt")
      # Get the relative path of the dir.
      file(RELATIVE_PATH relative_path ${directory} ${dir})

      # Get the directory depth.
      string(REGEX MATCHALL "/" slashes "${relative_path}")
      list(LENGTH slashes depth)

      # Exclude directories deeper than the specified level.
      if("${depth}" LESS "${level}")
        list(APPEND directories "${dir}")
      endif()
    endif()
  endforeach()

  # Sort extension directories by the PRIORITY value in the php_extension().
  foreach(dir ${directories})
    file(READ "${dir}/CMakeLists.txt" content)

    string(REGEX MATCH "php_extension[\\r\\n\\t ]*\\(.*PRIORITY[\\r\\n\\t ]+([0-9]+)" _ ${content})

    if(${CMAKE_MATCH_1})
      list(APPEND directories_numbered "${CMAKE_MATCH_1}.${dir}")
    else()
      list(APPEND directories_numbered "999.${dir}")
    endif()
  endforeach()

  list(SORT directories_numbered COMPARE NATURAL)

  foreach(dir ${directories_numbered})
    string(REGEX MATCHALL "[0-9]+\\.(.*)" _ ${dir})
    list(APPEND directories_sorted ${CMAKE_MATCH_1})
  endforeach()

  set(${result} ${directories_sorted} PARENT_SCOPE)
endfunction()

# Include subdirectories within 'ext/' up to a depth of 1.
_php_get_extensions(extension_directories "${CMAKE_CURRENT_SOURCE_DIR}/ext" 1)

# Add extension directories.
foreach(dir ${extension_directories})
  cmake_path(GET dir FILENAME extension_name)

  add_subdirectory("ext/${extension_name}")
endforeach()
