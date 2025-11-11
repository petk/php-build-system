#[=============================================================================[
Configure PHP extensions.

This internal module is responsible for parsing CMakeLists.txt files of PHP
extensions and sorting extensions based on the dependencies listed in the
add_dependencies(). If an extension has specified dependencies, it ensures that
all dependencies are automatically enabled. If any of the dependencies are built
as SHARED libraries, the extension must also be built as a SHARED library.

Dependencies can be specified on top of the CMake's built-in command
add_dependencies(), which builds target dependencies before the target itself.
This internal module reads the add_dependencies() invocations in extensions
CMakeLists.txt files and automatically enables and configures them as SHARED
depending on the configuration if they haven't been explicitly configured. If it
fails to configure extension dependencies automatically it will result in a
fatal error at the end of the configuration phase.

Order of the extensions is then also important in the generated
'main/internal_functions*.c' files (for the list of 'phpext_<extension>_ptr' in
the 'zend_module_entry php_builtin_extensions'). This is the order of how the
PHP modules are registered into the Zend hash table.

PHP internal API also provides dependencies handling with the
'ZEND_MOD_REQUIRED', 'ZEND_MOD_CONFLICTS', and 'ZEND_MOD_OPTIONAL', which should
be set in the extension code itself. PHP internally then sorts the extensions
based on the 'ZEND_MOD_REQUIRED' and 'ZEND_MOD_OPTIONAL', so build time sorting
shouldn't be taken for granted and is mostly used for php-src builds.

Example why setting dependencies with 'ZEND_MOD_REQUIRED' might matter:
https://bugs.php.net/53141

Custom CMake properties:

* PHP_EXTENSION
* PHP_ZEND_EXTENSION
* PHP_EXTENSION_<extension>_DEPS
#]=============================================================================]

include_guard(GLOBAL)

################################################################################
# CMake custom properties.
################################################################################

define_property(
  TARGET
  PROPERTY PHP_EXTENSION
  BRIEF_DOCS "Whether the target is a PHP extension"
)

define_property(
  TARGET
  PROPERTY PHP_ZEND_EXTENSION
  BRIEF_DOCS "Whether the PHP extension target is Zend extension"
)

# Sort extensions by dependencies and evaluate their configuration options.
function(php_extensions_preprocess)
  set(result ${ARGV0})
  set(extensions ${${ARGV0}})

  _php_extensions_sort(extensions)
  _php_extensions_eval_options("${extensions}")

  foreach(extension IN LISTS extensions)
    string(TOUPPER "${extension}" extension_upper)

    if(NOT PHP_EXT_${extension_upper})
      continue()
    endif()

    # Mark shared option variable as advanced.
    if(DEFINED PHP_EXT_${extension_upper}_SHARED)
      mark_as_advanced(PHP_EXT_${extension_upper}_SHARED)
    endif()

    _php_extensions_get_dependencies("${extension}" dependencies)

    # If extension is enabled and one of its dependencies is built as a shared
    # library, configure extension also as a shared library.
    foreach(dependency IN LISTS dependencies)
      string(TOUPPER "${dependency}" dependency_upper)

      if(
        PHP_EXT_${dependency_upper}_SHARED
        AND NOT PHP_EXT_${extension_upper}_SHARED
      )
        message(
          WARNING
          "The '${extension}' extension must be built as a shared library as "
          "its dependency '${dependency}' extension is configured as shared. "
          "The 'PHP_EXT_${extension_upper}_SHARED' option has been "
          "automatically set to 'ON'."
        )

        set(
          CACHE{PHP_EXT_${extension_upper}_SHARED}
          TYPE BOOL
          HELP "Build the ${extension} extension as a shared library"
          FORCE
          VALUE ON
        )

        break()
      endif()
    endforeach()
  endforeach()

  # Validate extensions and their dependencies after extensions are configured.
  cmake_language(DEFER CALL _php_extensions_validate)

  set(${result} ${${result}} PARENT_SCOPE)
endfunction()

################################################################################
# Module internal helper functions.
################################################################################

# Sort extensions by their dependencies.
function(_php_extensions_sort)
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

  set(result ${ARGV0})
  set(extensions ${${ARGV0}})
  set(extensions_before "")
  set(extensions_middle "")

  foreach(extension IN LISTS extensions)
    _php_extensions_parse_dependencies("${extension}" dependencies)
    set_property(
      GLOBAL
      APPEND
      PROPERTY
        PHP_EXTENSION_${extension}_DEPS ${dependencies}
    )

    if(dependencies)
      foreach(dependency IN LISTS dependencies)
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

  list(APPEND extensions_sorted ${extensions_before} ${extensions_middle})
  list(REMOVE_DUPLICATES extensions_sorted)
  list(REVERSE extensions_sorted)

  set(${result} ${extensions_sorted} PARENT_SCOPE)
endfunction()

# Get extension dependencies from the add_dependencies().
function(_php_extensions_parse_dependencies extension result)
  unset(${result} PARENT_SCOPE)

  if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${extension}/CMakeLists.txt)
    return()
  endif()

  file(READ ${CMAKE_CURRENT_SOURCE_DIR}/${extension}/CMakeLists.txt content)

  _php_extensions_remove_comments(content)

  string(CONCAT regex
    # Command invocation:
    "add_dependencies[ \t]*\\("
    # Target name:
    "[ \t\n]*php_ext_${extension}[ \t\n]+"
    # Dependencies:
    "[\"]?(php_ext_[a-zA-Z0-9_; \t\n]+)"
  )

  string(REGEX MATCHALL "${regex}" matches "${content}")

  set(all_dependencies "")

  foreach(match IN LISTS matches)
    if(match MATCHES "${regex}")
      if(CMAKE_MATCH_1)
        string(STRIP "${CMAKE_MATCH_1}" dependencies)
        string(REPLACE " " ";" dependencies "${dependencies}")
        list(TRANSFORM dependencies REPLACE "^php_ext_" "")
        list(APPEND all_dependencies ${dependencies})
      endif()
    endif()
  endforeach()

  if(all_dependencies)
    list(REMOVE_DUPLICATES all_dependencies)

    get_property(all_extensions GLOBAL PROPERTY PHP_ALL_EXTENSIONS)

    foreach(dependency IN LISTS all_dependencies)
      if(NOT "${dependency}" IN_LIST all_extensions)
        list(REMOVE_ITEM all_dependencies ${dependency})
      endif()
    endforeach()

    set(${result} "${all_dependencies}" PARENT_SCOPE)
  endif()
endfunction()

# Get extension dependencies if found.
function(_php_extensions_get_dependencies extension result)
  set(${result} "")

  get_property(deps GLOBAL PROPERTY PHP_EXTENSION_${extension}_DEPS)
  if(deps)
    set(${result} "${deps}")
  endif()

  return(PROPAGATE ${result})
endfunction()

# Get a regex string to match option().
function(_php_extensions_option_regex option result)
  string(CONCAT _
    # Start of the option command invocation:
    "[ \t\n]?option[ \t]*\\([ \t\n]*"
    # Variable name:
    "[ \t\n]*${option}[ \t\n]+"
    # Documentation string without escaped double quotes (\"):
    # TODO: should escaped quotes be also matched?
    #"[ \t\n]*\"([^\"]|\\\")*\"[ \t\n]*"
    "[ \t\n]*\"[^\"]*\"[ \t\n]*"
    # Optional boolean or variable value:
    "([ \t\n]+("
    "ON|on|TRUE|true|YES|yes|Y|y|"
    "OFF|off|FALSE|false|NO|no|N|n|"
    "[0-9.]+|"
    "\\\$\\{[^\\}]+\\}"
    "))?"
    # End of option invocation:
    "[ \t\n]*\\)"
  )

  set(${result} "${_}" PARENT_SCOPE)
endfunction()

# Get a regex string to match cmake_dependent_option().
function(_php_extensions_cmake_dependent_option_regex option result)
  string(CONCAT _
    # Start of the option command invocation:
    "[ \t\n]?cmake_dependent_option[ \t]*\\([ \t\n]*"
    # Variable name:
    "[ \t\n]*${option}[ \t\n]+"
    # Documentation string without escaped double quotes (\"):
    # TODO: should escaped quotes be also matched?
    #"[ \t\n]*\"([^\"]|\\\")*\"[ \t\n]*"
    "[ \t\n]*\"[^\"]*\"[ \t\n]*"
    # Boolean or variable value:
    "[ \t\n]+("
    "ON|on|TRUE|true|YES|yes|Y|y|"
    "OFF|off|FALSE|false|NO|no|N|n|"
    "[0-9.]+|"
    "\\\$\\{[^\\}]+\\}"
    ")"
    # Semicolon separated list of conditions:
    "[ \t\n]*\"[^\"]*\"[ \t\n]*"
    # Boolean or variable force value:
    "[ \t\n]+("
    "ON|on|TRUE|true|YES|yes|Y|y|"
    "OFF|off|FALSE|false|NO|no|N|n|"
    "[0-9.]+|"
    "\\\$\\{[^\\}]+\\}"
    ")"
    # End of option invocation:
    "[ \t\n]*\\)"
  )

  set(${result} "${_}" PARENT_SCOPE)
endfunction()

# Parse and evaluate options of extensions.
function(_php_extensions_eval_options directories)
  set(code "")
  get_property(always_enabled_extensions GLOBAL PROPERTY PHP_ALWAYS_ENABLED_EXTENSIONS)
  get_property(all_extensions GLOBAL PROPERTY PHP_ALL_EXTENSIONS)

  foreach(extension IN LISTS extensions)
    # Skip if extension is always enabled or if dependency is not extension.
    if(
      extension IN_LIST always_enabled_extensions
      OR NOT extension IN_LIST all_extensions
    )
      continue()
    endif()

    file(READ ${CMAKE_CURRENT_SOURCE_DIR}/${extension}/CMakeLists.txt content)
    string(TOUPPER "${extension}" extension_upper)

    # Check if extension has option(PHP_EXT_<extension> ...).
    _php_extensions_remove_comments(content)
    _php_extensions_option_regex("PHP_EXT_${extension_upper}" regex)
    string(REGEX MATCH "${regex}" code "${content}")

    if(code)
      cmake_language(EVAL CODE "${code}")
      unset(code)
    endif()

    # If extension has cmake_dependent_option(PHP_EXT_<extension> ...).
    _php_extensions_cmake_dependent_option_regex(
      "PHP_EXT_${extension_upper}"
      regex
    )
    string(REGEX MATCH "${regex}" code "${content}")

    if(code)
      string(PREPEND code "include(CMakeDependentOption)\n")
      cmake_language(EVAL CODE "${code}")
      unset(code)
    endif()

    # If extension has cmake_dependent_option(PHP_EXT_<extension>_SHARED ...).
    _php_extensions_cmake_dependent_option_regex(
      "PHP_EXT_${extension_upper}_SHARED"
      regex
    )

    string(REGEX MATCH "${regex}" code "${content}")

    if(code)
      string(PREPEND code "include(CMakeDependentOption)\n")
      cmake_language(EVAL CODE "${code}")
      unset(code)
    endif()
  endforeach()
endfunction()

# Remove line comments from CMake code content.
function(_php_extensions_remove_comments)
  string(REGEX REPLACE "[ \t]*#[^\n]*" "" ${ARGV0} "${${ARGV0}}")
  set(${ARGV0} "${${ARGV0}}" PARENT_SCOPE)
endfunction()

# Postconfigure extension right after it has been configured.
function(php_extensions_postconfigure extension)
  if(NOT TARGET php_ext_${extension})
    return()
  endif()

  # If extension is enabled, enable also all its dependencies.
  get_target_property(
    dependencies
    php_ext_${extension}
    MANUALLY_ADDED_DEPENDENCIES
  )
  list(TRANSFORM dependencies REPLACE "^php_ext_" "")
  get_property(always_enabled_extensions GLOBAL PROPERTY PHP_ALWAYS_ENABLED_EXTENSIONS)
  get_property(all_extensions GLOBAL PROPERTY PHP_ALL_EXTENSIONS)

  foreach(dependency IN LISTS dependencies)
    string(TOUPPER "${dependency}" dependency_upper)

    if(
      PHP_EXT_${dependency_upper}
      OR dependency IN_LIST always_enabled_extensions
      OR NOT dependency IN_LIST all_extensions
    )
      continue()
    endif()

    message(
      WARNING
      "The '${extension}' extension requires the '${dependency}' extension. "
      "The 'PHP_EXT_${dependency_upper}' option has been automatically set to "
      "'ON'."
    )

    if(DEFINED CACHE{PHP_EXT_${dependency_upper}})
      set_property(CACHE PHP_EXT_${dependency_upper} PROPERTY VALUE ON)
    else()
      set(
        CACHE{PHP_EXT_${dependency_upper}}
        TYPE BOOL
        HELP "Enable the ${dependency} extension"
        FORCE
        VALUE ON
      )
    endif()
  endforeach()

  if(NOT TARGET PHP::ext::${extension})
    add_library(PHP::ext::${extension} ALIAS php_ext_${extension})
  endif()

  # Mark target as PHP extension.
  set_property(TARGET php_ext_${extension} PROPERTY PHP_EXTENSION TRUE)

  # Set target output filename to "<extension>".
  get_target_property(output php_ext_${extension} OUTPUT_NAME)
  if(NOT output)
    set_property(TARGET php_ext_${extension} PROPERTY OUTPUT_NAME ${extension})
  endif()

  # Specify extension's default installation rules.
  get_target_property(sets php_ext_${extension} INTERFACE_HEADER_SETS)
  set(file_sets "")
  foreach(set IN LISTS sets)
    list(
      APPEND
      file_sets
      FILE_SET
      ${set}
      DESTINATION
      ${CMAKE_INSTALL_INCLUDEDIR}/${PHP_INCLUDE_PREFIX}/ext/${extension}
      COMPONENT php-development
    )
  endforeach()
  install(
    TARGETS php_ext_${extension}
    ARCHIVE EXCLUDE_FROM_ALL
    RUNTIME
      DESTINATION ${PHP_EXTENSION_DIR}
      COMPONENT php
    LIBRARY
      DESTINATION ${PHP_EXTENSION_DIR}
      COMPONENT php
    ${file_sets}
  )

  # Configure shared extension.
  get_target_property(type php_ext_${extension} TYPE)
  if(NOT type MATCHES "^(MODULE|SHARED)_LIBRARY$")
    return()
  endif()

  target_compile_definitions(php_ext_${extension} PRIVATE ZEND_COMPILE_DL_EXT)

  # Set build-phase location for shared extensions.
  get_target_property(location php_ext_${extension} LIBRARY_OUTPUT_DIRECTORY)
  if(NOT location)
    get_property(is_multi_config GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)

    if(is_multi_config)
      set_property(
        TARGET php_ext_${extension}
        PROPERTY LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/modules"
      )
    else()
      set_property(
        TARGET php_ext_${extension}
        PROPERTY LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/modules/$<CONFIG>"
      )
    endif()
  endif()
endfunction()

# Prepend COMPILE_DL_<EXTENSION> macros to extensions configuration headers and
# define them for shared extensions.
function(php_extensions_configure_headers)
  get_property(extensions GLOBAL PROPERTY PHP_EXTENSIONS)
  foreach(extension IN LISTS extensions)
    if(NOT TARGET php_ext_${extension})
      continue()
    endif()

    string(TOUPPER "COMPILE_DL_${extension}" macro)

    get_target_property(type php_ext_${extension} TYPE)
    if(type MATCHES "^(MODULE|SHARED)_LIBRARY$")
      set(${macro} TRUE)
    else()
      set(${macro} FALSE)
    endif()

    # Prepare config.h template.
    string(
      JOIN
      ""
      template
      "/* Define to 1 if the PHP extension '@extension@' is built as a dynamic "
      "module. */\n"
      "#cmakedefine ${macro} 1\n"
    )

    get_target_property(binary_dir php_ext_${extension} BINARY_DIR)
    set(current "")
    if(EXISTS ${binary_dir}/config.h)
      file(READ ${binary_dir}/config.h current)
    endif()

    # Finalize extension's config.h header file.
    if(NOT current MATCHES "(#undef|#define) ${macro}")
      string(STRIP "${template}\n${current}" config)
      file(CONFIGURE OUTPUT ${binary_dir}/config.h CONTENT "${config}\n")
    endif()
  endforeach()
endfunction()

# Validate extensions and their dependencies defined via add_dependencies().
function(_php_extensions_validate)
  get_directory_property(extensions SUBDIRECTORIES)
  list(TRANSFORM extensions REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/" "")

  foreach(extension IN LISTS extensions)
    if(NOT TARGET php_ext_${extension})
      continue()
    endif()

    get_target_property(
      dependencies
      php_ext_${extension}
      MANUALLY_ADDED_DEPENDENCIES
    )

    if(NOT dependencies)
      continue()
    endif()

    list(TRANSFORM dependencies REPLACE "^php_ext_" "")

    get_property(all_extensions GLOBAL PROPERTY PHP_ALL_EXTENSIONS)

    foreach(dependency IN LISTS dependencies)
      # Skip dependencies that are not PHP extensions.
      if(NOT dependency IN_LIST all_extensions)
        continue()
      endif()

      if(NOT TARGET php_ext_${dependency} OR NOT dependency IN_LIST extensions)
        string(TOUPPER "${dependency}" dependency_upper)
        message(
          SEND_ERROR
          "You've enabled the '${extension}' extension, which depends on the "
          "'${dependency}' extension, but you've either not enabled "
          "'${dependency}', or have disabled it. Please set "
          "'PHP_EXT_${dependency_upper}' to 'ON' if available."
        )
      endif()

      get_target_property(dependency_type php_ext_${dependency} TYPE)
      get_target_property(extension_type php_ext_${extension} TYPE)

      if(
        dependency_type MATCHES "^(MODULE|SHARED)_LIBRARY$"
        AND NOT extension_type MATCHES "^(MODULE|SHARED)_LIBRARY$"
      )
        message(
          SEND_ERROR
          "You've configured the '${extension}' extension to be built "
          "statically, but it depends on the '${dependency}' extension, which "
          "you've configured to build as a shared library. You either need to "
          "build the '${extension}' shared or build '${dependency}' statically "
          "for the build to be successful."
        )
      endif()
    endforeach()
  endforeach()
endfunction()
