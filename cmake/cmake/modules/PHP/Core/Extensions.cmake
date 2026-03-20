#[=============================================================================[
This is an internal module and is intended for usage only within the php-src.
It provides commands for sorting PHP extensions based on their dependencies.

Load this module in a CMake project with:

  include(PHP/Core/Extensions)

PHP extension dependencies can be specified with the following target properties:
* PHP_REQUIRED_EXTENSIONS
* PHP_OPTIONAL_EXTENSIONS
* PHP_RECOMMENDED_EXTENSIONS
* PHP_CONFLICTING_EXTENSIONS

If any of the required dependencies are built as MODULE libraries, the extension
must also be built as a MODULE library.

The order of the extensions is important in the generated
'main/internal_functions*.c' files (for the list of 'phpext_<extension>_ptr' in
the 'zend_module_entry php_builtin_extensions'). This is the order of how the
PHP modules are registered into the Zend hash table.

PHP core also provides dependencies handling with the 'ZEND_MOD_REQUIRED',
'ZEND_MOD_OPTIONAL', and 'ZEND_MOD_CONFLICTS', which should be set in the
extension source code. PHP internally then sorts the extensions based on the
'ZEND_MOD_REQUIRED' and 'ZEND_MOD_OPTIONAL'.

Example why setting dependencies with 'ZEND_MOD_REQUIRED' might matter:
https://bugs.php.net/53141
#]=============================================================================]

include_guard(GLOBAL)

# Sorts extensions by their dependencies.
function(php_extensions_sort)
  cmake_parse_arguments(
    PARSE_ARGV
    1
    parsed # prefix
    ""     # options
    ""     # one-value keywords
    ""     # multi-value keywords
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  set(extensions_before "")
  set(extensions_middle "")

  foreach(extension IN LISTS ${ARGV0})
    get_target_property(
      dependencies
      PHP::ext::${extension}
      PHP_REQUIRED_EXTENSIONS
    )

    get_target_property(
      optional_dependencies
      PHP::ext::${extension}
      PHP_OPTIONAL_EXTENSIONS
    )

    if(optional_dependencies)
      list(APPEND dependencies "${optional_dependencies}")
    endif()

    get_target_property(
      recommended_extensions
      PHP::ext::${extension}
      PHP_RECOMMENDED_EXTENSIONS
    )

    if(recommended_extensions)
      list(APPEND dependencies "${recommended_extensions}")
    endif()

    if(dependencies)
      foreach(dependency IN LISTS dependencies)
        if(NOT TARGET PHP::ext::${dependency})
          continue()
        endif()

        list(REMOVE_ITEM extensions_middle ${dependency})

        if(NOT dependency IN_LIST extensions_before)
          list(APPEND extensions_before ${dependency})
        endif()
      endforeach()
    endif()

    if(NOT extension IN_LIST extensions_before)
      list(REMOVE_ITEM extensions_middle ${extension})
      list(APPEND extensions_middle ${extension})
    endif()
  endforeach()

  set(${ARGV0} ${extensions_before} ${extensions_middle})
  list(REMOVE_DUPLICATES ${ARGV0})

  return(PROPAGATE ${ARGV0})
endfunction()
