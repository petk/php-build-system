#[=============================================================================[
# PHP/Extensions

Configure PHP extensions.

This module is responsible for parsing `CMakeLists.txt` files of PHP extensions
and sorting extensions based on the dependencies listed in the
`add_dependencies()`. If an extension has specified dependencies, it ensures
that all dependencies are automatically enabled. If any of the dependencies are
built as `SHARED` libraries, the extension must also be built as a `SHARED`
library.

Dependencies can be specified on top of the CMake's built-in command
`add_dependencies()`, which builds target dependencies before the target itself.
This module reads the `add_dependencies()` invocations in extensions
CMakeLists.txt files and automatically enables and configures them as `SHARED`
depending on the configuration if they haven't been explicitly configured. If it
fails to configure extension dependencies automatically it will result in a
fatal error at the end of the configuration phase.

Order of the extensions is then also important in the generated
`main/internal_functions*.c` files (for the list of `phpext_<extension>_ptr` in
the `zend_module_entry php_builtin_extensions`). This is the order of how the
modules are registered into the Zend hash table.

PHP internal API also provides dependencies handling with the
`ZEND_MOD_REQUIRED`, `ZEND_MOD_CONFLICTS`, and `ZEND_MOD_OPTIONAL`, which should
be set in the extension code itself. PHP internally then sorts the extensions
based on the `ZEND_MOD_REQUIRED` and `ZEND_MOD_OPTIONAL`, so build time sorting
shouldn't be taken for granted and is mostly used for php-src builds.

Example why setting dependencies with `ZEND_MOD_REQUIRED` might matter:
https://bugs.php.net/53141

## Custom CMake properties

* `PHP_ZEND_EXTENSION`

  Extensions can utilize this custom target property, which designates the
  extension as a Zend extension rather than a standard PHP extension. Zend
  extensions function similarly to regular PHP extensions, but they are loaded
  using the `zend_extension` INI directive and possess an internally distinct
  structure with additional hooks. Typically employed for advanced
  functionalities like debuggers and profilers, Zend extensions offer enhanced
  capabilities.

  ```cmake
  set_target_properties(php_ext_<extension_name> PROPERTIES PHP_ZEND_EXTENSION TRUE)
  ```

* `PHP_EXTENSION_<extension>_DEPS`

  Global property with a list of all dependencies of <extension> (name of the
  extension as named in ext directory).
#]=============================================================================]

include_guard(GLOBAL)

################################################################################
# CMake custom properties.
################################################################################

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

  get_property(alwaysEnabledExtensions GLOBAL PROPERTY PHP_ALWAYS_ENABLED_EXTENSIONS)

  foreach(extension IN LISTS extensions)
    string(TOUPPER "${extension}" extensionUpper)

    if(NOT PHP_EXT_${extensionUpper})
      continue()
    endif()

    # Mark shared option variable as advanced.
    if(DEFINED PHP_EXT_${extensionUpper}_SHARED)
      mark_as_advanced(PHP_EXT_${extensionUpper}_SHARED)
    endif()

    _php_extensions_get_dependencies("${extension}" dependencies)

    # If extension is enabled and one of its dependencies is built as a shared
    # library, configure extension also as a shared library.
    foreach(dependency IN LISTS dependencies)
      string(TOUPPER "${dependency}" dependencyUpper)

      if(
        PHP_EXT_${dependencyUpper}_SHARED
        AND NOT PHP_EXT_${extensionUpper}_SHARED
      )
        message(
          WARNING
          "The '${extension}' extension must be built as a shared library as "
          "its dependency '${dependency}' extension is configured as shared. "
          "The 'PHP_EXT_${extensionUpper}_SHARED' option has been "
          "automatically set to 'ON'."
        )

        set(
          PHP_EXT_${extensionUpper}_SHARED
          ON
          CACHE BOOL
          "Build the ${extension} extension as a shared library"
          FORCE
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
    message(FATAL_ERROR "Bad arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  set(result ${ARGV0})
  set(extensions ${${ARGV0}})
  set(extensionsBefore "")
  set(extensionsMiddle "")

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
        list(REMOVE_ITEM extensionsMiddle ${dependency})

        if(NOT dependency IN_LIST extensionsBefore)
          list(APPEND extensionsBefore ${dependency})
        endif()
      endforeach()
    endif()

    if(NOT extension IN_LIST extensionsBefore)
      list(REMOVE_ITEM extensionsMiddle ${extension})
      list(APPEND extensionsMiddle ${extension})
    endif()
  endforeach()

  list(APPEND extensionsSorted ${extensionsBefore} ${extensionsMiddle})
  list(REMOVE_DUPLICATES extensionsSorted)
  list(REVERSE extensionsSorted)

  set(${result} ${extensionsSorted} PARENT_SCOPE)
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
    "[ \t\r\n]*php_ext_${extension}[ \t\r\n]+"
    # Dependencies:
    "[\"]?(php_ext_[a-zA-Z0-9_; \t\r\n]+)"
  )

  string(REGEX MATCHALL "${regex}" matches "${content}")

  set(allDependencies "")

  foreach(match IN LISTS matches)
    if(match MATCHES "${regex}")
      if(CMAKE_MATCH_1)
        string(STRIP "${CMAKE_MATCH_1}" dependencies)
        string(REPLACE " " ";" dependencies "${dependencies}")
        list(TRANSFORM dependencies REPLACE "^php_ext_" "")
        list(APPEND allDependencies ${dependencies})
      endif()
    endif()
  endforeach()

  if(allDependencies)
    list(REMOVE_DUPLICATES allDependencies)

    get_property(allExtensions GLOBAL PROPERTY PHP_ALL_EXTENSIONS)

    foreach(dependency IN LISTS allDependencies)
      if(NOT "${dependency}" IN_LIST allExtensions)
        list(REMOVE_ITEM allDependencies ${dependency})
      endif()
    endforeach()

    set(${result} "${allDependencies}" PARENT_SCOPE)
  endif()
endfunction()

# Get extension dependencies if found.
function(_php_extensions_get_dependencies extension result)
  set(${result} PARENT_SCOPE)

  get_property(deps GLOBAL PROPERTY PHP_EXTENSION_${extension}_DEPS)
  if(deps)
    set(${result} "${deps}" PARENT_SCOPE)
  endif()
endfunction()

# Get a regex string to match option().
function(_php_extensions_option_regex option result)
  string(CONCAT _
    # Start of the option command invocation:
    "[ \t\r\n]?option[ \t]*\\([ \t\r\n]*"
    # Variable name:
    "[ \t\r\n]*${option}[ \t\r\n]+"
    # Documentation string without escaped double quotes (\"):
    # TODO: should escaped quotes be also matched?
    #"[ \t\r\n]*\"([^\"]|\\\")*\"[ \t\r\n]*"
    "[ \t\r\n]*\"[^\"]*\"[ \t\r\n]*"
    # Optional boolean or variable value:
    "([ \t\r\n]+("
    "ON|on|TRUE|true|YES|yes|Y|y|"
    "OFF|off|FALSE|false|NO|no|N|n|"
    "[0-9.]+|"
    "\\\$\\{[^\\}]+\\}"
    "))?"
    # End of option invocation:
    "[ \t\r\n]*\\)"
  )

  set(${result} "${_}" PARENT_SCOPE)
endfunction()

# Get a regex string to match cmake_dependent_option().
function(_php_extensions_cmake_dependent_option_regex option result)
  string(CONCAT _
    # Start of the option command invocation:
    "[ \t\r\n]?cmake_dependent_option[ \t]*\\([ \t\r\n]*"
    # Variable name:
    "[ \t\r\n]*${option}[ \t\r\n]+"
    # Documentation string without escaped double quotes (\"):
    # TODO: should escaped quotes be also matched?
    #"[ \t\r\n]*\"([^\"]|\\\")*\"[ \t\r\n]*"
    "[ \t\r\n]*\"[^\"]*\"[ \t\r\n]*"
    # Boolean or variable value:
    "[ \t\r\n]+("
    "ON|on|TRUE|true|YES|yes|Y|y|"
    "OFF|off|FALSE|false|NO|no|N|n|"
    "[0-9.]+|"
    "\\\$\\{[^\\}]+\\}"
    ")"
    # Semicolon separated list of conditions:
    "[ \t\r\n]*\"[^\"]*\"[ \t\r\n]*"
    # Boolean or variable force value:
    "[ \t\r\n]+("
    "ON|on|TRUE|true|YES|yes|Y|y|"
    "OFF|off|FALSE|false|NO|no|N|n|"
    "[0-9.]+|"
    "\\\$\\{[^\\}]+\\}"
    ")"
    # End of option invocation:
    "[ \t\r\n]*\\)"
  )

  set(${result} "${_}" PARENT_SCOPE)
endfunction()

# Parse and evaluate options of extensions.
function(_php_extensions_eval_options directories)
  set(code "")
  get_property(alwaysEnabledExtensions GLOBAL PROPERTY PHP_ALWAYS_ENABLED_EXTENSIONS)
  get_property(allExtensions GLOBAL PROPERTY PHP_ALL_EXTENSIONS)

  foreach(extension IN LISTS extensions)
    # Skip if extension is always enabled or if dependency is not extension.
    if(
      extension IN_LIST alwaysEnabledExtensions
      OR NOT extension IN_LIST allExtensions
    )
      continue()
    endif()

    file(READ ${CMAKE_CURRENT_SOURCE_DIR}/${extension}/CMakeLists.txt content)
    string(TOUPPER "${extension}" extensionUpper)

    # Check if extension has option(PHP_EXT_<extension> ...).
    _php_extensions_remove_comments(content)
    _php_extensions_option_regex("PHP_EXT_${extensionUpper}" regex)
    string(REGEX MATCH "${regex}" code "${content}")

    if(code)
      cmake_language(EVAL CODE "${code}")
      unset(code)
    endif()

    # If extension has cmake_dependent_option(PHP_EXT_<extension> ...).
    _php_extensions_cmake_dependent_option_regex(
      "PHP_EXT_${extensionUpper}"
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
      "PHP_EXT_${extensionUpper}_SHARED"
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
  string(REGEX REPLACE "[ \t]*#[^\r\n]*" "" ${ARGV0} "${${ARGV0}}")
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
  get_property(alwaysEnabledExtensions GLOBAL PROPERTY PHP_ALWAYS_ENABLED_EXTENSIONS)
  get_property(allExtensions GLOBAL PROPERTY PHP_ALL_EXTENSIONS)

  foreach(dependency IN LISTS dependencies)
    string(TOUPPER "${dependency}" dependencyUpper)

    if(
      PHP_EXT_${dependencyUpper}
      OR dependency IN_LIST alwaysEnabledExtensions
      OR NOT dependency IN_LIST allExtensions
    )
      continue()
    endif()

    message(
      WARNING
      "The '${extension}' extension requires the '${dependency}' extension. "
      "The 'PHP_EXT_${dependencyUpper}' option has been automatically set to "
      "'ON'."
    )

    if(DEFINED CACHE{PHP_EXT_${dependencyUpper}})
      set_property(CACHE PHP_EXT_${dependencyUpper} PROPERTY VALUE ON)
    else()
      set(
        PHP_EXT_${dependencyUpper}
        ON
        CACHE BOOL
        "Enable the ${dependency} extension"
        FORCE
      )
    endif()
  endforeach()

  if(NOT TARGET PHP::ext::${extension})
    add_library(PHP::ext::${extension} ALIAS php_ext_${extension})
  endif()

  # Set target output filename to "<extension>".
  get_target_property(output php_ext_${extension} OUTPUT_NAME)
  if(NOT output)
    set_property(TARGET php_ext_${extension} PROPERTY OUTPUT_NAME ${extension})
  endif()

  # Specify extension's default installation rules.
  get_target_property(sets php_ext_${extension} INTERFACE_HEADER_SETS)
  set(fileSets "")
  foreach(set IN LISTS sets)
    list(
      APPEND
      fileSets
      FILE_SET
      ${set}
      DESTINATION
      ${CMAKE_INSTALL_INCLUDEDIR}/${PHP_INCLUDE_PREFIX}/ext/${extension}
    )
  endforeach()
  install(
    TARGETS php_ext_${extension}
    ARCHIVE EXCLUDE_FROM_ALL
    RUNTIME
      DESTINATION ${PHP_EXTENSION_DIR}
    LIBRARY
      DESTINATION ${PHP_EXTENSION_DIR}
    ${fileSets}
  )

  # Configure shared extension.
  get_target_property(type php_ext_${extension} TYPE)
  if(NOT type MATCHES "^(MODULE|SHARED)_LIBRARY$")
    return()
  endif()

  target_compile_definitions(php_ext_${extension} PRIVATE ZEND_COMPILE_DL_EXT)

  set_target_properties(
    php_ext_${extension}
    PROPERTIES
      POSITION_INDEPENDENT_CODE ON
  )

  # Set build-phase location for shared extensions.
  get_target_property(location php_ext_${extension} LIBRARY_OUTPUT_DIRECTORY)
  if(NOT location)
    set_property(
      TARGET php_ext_${extension}
      PROPERTY LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/modules"
    )
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

    get_target_property(binaryDir php_ext_${extension} BINARY_DIR)
    set(current "")
    if(EXISTS ${binaryDir}/config.h)
      file(READ ${binaryDir}/config.h current)
    endif()

    string(STRIP "${template}\n${current}" config)

    # Finalize extension's config.h header file.
    file(CONFIGURE OUTPUT ${binaryDir}/config.h CONTENT "${config}\n")
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

    get_property(allExtensions GLOBAL PROPERTY PHP_ALL_EXTENSIONS)

    foreach(dependency IN LISTS dependencies)
      # Skip dependencies that are not PHP extensions.
      if(NOT dependency IN_LIST allExtensions)
        continue()
      endif()

      if(NOT TARGET php_ext_${dependency} OR NOT dependency IN_LIST extensions)
        string(TOUPPER "${dependency}" dependencyUpper)
        message(
          SEND_ERROR
          "You've enabled the '${extension}' extension, which depends on the "
          "'${dependency}' extension, but you've either not enabled "
          "'${dependency}', or have disabled it. Please set "
          "'PHP_EXT_${dependencyUpper}' to 'ON' if available."
        )
      endif()

      get_target_property(dependencyType php_ext_${dependency} TYPE)
      get_target_property(extensionType php_ext_${extension} TYPE)

      if(
        dependencyType MATCHES "^(MODULE|SHARED)_LIBRARY$"
        AND NOT extensionType MATCHES "^(MODULE|SHARED)_LIBRARY$"
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
