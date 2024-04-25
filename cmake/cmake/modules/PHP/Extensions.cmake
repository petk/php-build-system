#[=============================================================================[
Add subdirectories of PHP extensions via add_subdirectory().

This module is responsible for traversing CMakeLists.txt files of PHP extensions
and adding them via add_subdirectory(). It sorts extension directories based on
the optional directory property PHP_PRIORITY value and the dependencies listed
in the add_dependencies(). If an extension has specified dependencies, this
module ensures that all dependencies are enabled. If any of the dependencies are
built as SHARED libraries, the extension must also be built as a SHARED library.

The add_dependencies() is CMake's built-in command that builds target
dependencies before the target itself. This module reads the add_dependencies()
invocations in extensions and automatically enables and configures them as
SHARED depending on the configuration if they haven't been explicitly
configured. If it fails to configure extension dependencies automatically it
will result in a fatal error during the configuration phase.

Exposed macro: php_extensions_add(subdirectory)
]=============================================================================]#

include_guard(GLOBAL)

################################################################################
# CMake custom properties.
################################################################################

define_property(
  DIRECTORY
  PROPERTY PHP_PRIORITY
  BRIEF_DOCS "Controls when to add subdirectory in the configuration phase"
  FULL_DOCS "This optional property controls the order of the extensions added "
            "with add_subdirectory(). Directory added with add_subdirectory() "
            "won't be visible in the configuration phase for the directories "
            "added before. Priority number can be used to add the extension "
            "subdirectory prior (0..100) or later (>100) to other extensions. "
            "By default extensions are sorted alphabetically and added in "
            "between. This enables having extension variables visible in "
            "depending extensions."
)

define_property(
  TARGET
  PROPERTY PHP_ZEND_EXTENSION
  BRIEF_DOCS "Whether the extension target is Zend extension"
)

define_property(
  GLOBAL
  PROPERTY PHP_EXTENSIONS
  BRIEF_DOCS "A list of all enabled extensions"
  FULL_DOCS "This property contains a list of all enabled extensions for the "
            "current configuration. Extensions are sorted by the directory "
            "priority and their dependencies."
)

define_property(
  GLOBAL
  PROPERTY PHP_ALWAYS_ENABLED_EXTENSIONS
  BRIEF_DOCS "A list of always enabled PHP extensions"
  FULL_DOCS "This property contains a list of always enabled PHP extensions "
            "which don't need HAVE_<extension-name> symbols and can be "
            "considered as part of the core PHP engine."
)

set_property(GLOBAL PROPERTY PHP_ALWAYS_ENABLED_EXTENSIONS
  date
  hash
  json
  pcre
  random
  reflection
  spl
  standard
)

define_property(
  GLOBAL
  PROPERTY PHP_ALL_EXTENSIONS
  BRIEF_DOCS "A list of all extensions in the ext directory"
)

################################################################################
# Module macro(s) to be used externally.
################################################################################

# Add subdirectories of extensions. Macro enables variable scope of the current
# CMakeLists.txt and adds ability to pass around directory variables.
macro(php_extensions_add directory)
  _php_extensions_get(${directory} directories)
  _php_extensions_sort(directories)

  # Evaluate options of extensions.
  _php_extensions_eval_options("${directories}")

  # Configure extensions and their dependencies.
  _php_extensions_configure("${directories}")

  # Add subdirectories of extensions.
  foreach(dir ${directories})
    cmake_path(GET dir FILENAME extension)
    message(STATUS "Checking ${extension} extension")
    list(APPEND CMAKE_MESSAGE_CONTEXT "ext/${extension}")
    unset(extension)

    add_subdirectory("${dir}")

    list(POP_BACK CMAKE_MESSAGE_CONTEXT)

    _php_extensions_post_configure("${dir}")
  endforeach()

  # Validate options of extensions and their dependencies.
  get_cmake_property(extensions PHP_EXTENSIONS)
  _php_extensions_validate("${extensions}")

  unset(directories)
  unset(extensions)
endmacro()

################################################################################
# Module internal helper functions.
################################################################################

# Get a list of subdirectories related to extensions.
function(_php_extensions_get directory result)
  file(GLOB paths ${directory}/*/CMakeLists.txt)

  set(directories "")

  foreach(path ${paths})
    cmake_path(GET path PARENT_PATH dir)
    list(APPEND directories "${dir}")

    # Add extension name to a list of all extensions.
    cmake_path(GET dir FILENAME extension)
    set_property(GLOBAL APPEND PROPERTY PHP_ALL_EXTENSIONS ${extension})
  endforeach()

  set(${result} ${directories} PARENT_SCOPE)
endfunction()

# Get a sorted list of subdirectories related to extensions.
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
  set(directories ${${ARGV0}})

  _php_extensions_sort_by_dependencies(${result})
  _php_extensions_sort_by_priority(${result})

  set(${result} ${directories} PARENT_SCOPE)
endfunction()

# Sort subdirectories of extensions by the add_dependencies() usage.
function(_php_extensions_sort_by_dependencies)
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
  set(directories ${${ARGV0}})

  set(extensions_before "")
  set(extensions_middle "")

  foreach(dir ${directories})
    _php_extensions_get_dependencies("${dir}" dependencies)

    if(dependencies)
      foreach(dependency ${dependencies})
        list(REMOVE_ITEM extensions_middle ${dependency})

        if(NOT dependency IN_LIST extensions_before)
          list(APPEND extensions_before ${dependency})
        endif()
      endforeach()
    endif()

    cmake_path(GET dir FILENAME extension)

    if(NOT extension IN_LIST extensions_before)
      list(REMOVE_ITEM extensions_middle ${extension})
      list(APPEND extensions_middle ${extension})
    endif()
  endforeach()

  list(APPEND directories_sorted ${extensions_before} ${extensions_middle})
  list(REMOVE_DUPLICATES directories_sorted)
  list(GET directories 0 parent_directory)
  cmake_path(GET parent_directory PARENT_PATH parent_directory)
  list(TRANSFORM directories_sorted PREPEND "${parent_directory}/")

  set(${result} ${directories_sorted} PARENT_SCOPE)
endfunction()

# Sort subdirectories of extensions by the directory property PHP_PRIORITY.
function(_php_extensions_sort_by_priority)
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
  set(directories ${${ARGV0}})

  set(extensions_before "")
  set(extensions_middle "")
  set(extensions_after "")

  foreach(dir ${directories})
    file(READ ${dir}/CMakeLists.txt content)

    string(CONCAT regex
      # Command invocation:
      "set_directory_properties[ \t]*\\("
      # Other optional characters:
      ".*"
      # Properties:
      "PROPERTIES[ \t\r\n]+.*"
      # Custom property name:
      "PHP_PRIORITY[ \t\r\n]+([0-9]+)"
    )

    string(REGEX MATCH "${regex}" _ "${content}")

    if(NOT CMAKE_MATCH_1)
      string(CONCAT regex
        # Command invocation:
        "set_property[ \t]*\\([ \t\r\n]*"
        # Scope name with possible other properties:
        "DIRECTORY.*"
        # Custom property:
        "PROPERTY[ \t\r\n]+PHP_PRIORITY[ \t\r\n]+"
        # Property numeric value:
        "([0-9]+)"
      )

      string(REGEX MATCH "${regex}" _ "${content}")
    endif()

    if(CMAKE_MATCH_1 AND CMAKE_MATCH_1 LESS_EQUAL 100)
      list(APPEND extensions_before "${CMAKE_MATCH_1}.${dir}")
    elseif(CMAKE_MATCH_1 AND CMAKE_MATCH_1 GREATER 100)
      list(APPEND extensions_after "${CMAKE_MATCH_1}.${dir}")
    else()
      list(APPEND extensions_middle "${dir}")
    endif()
  endforeach()

  list(SORT extensions_before COMPARE NATURAL)
  list(SORT extensions_after COMPARE NATURAL)

  set(extensions_sorted "")

  foreach(dir ${extensions_before})
    string(REGEX MATCHALL "^[0-9]+\\.(.*)" _ "${dir}")
    list(APPEND extensions_sorted ${CMAKE_MATCH_1})
  endforeach()

  list(APPEND extensions_sorted ${extensions_middle})

  foreach(dir ${extensions_after})
    string(REGEX MATCHALL "^[0-9]+\\.(.*)" _ "${dir}")
    list(APPEND extensions_sorted ${CMAKE_MATCH_1})
  endforeach()

  set(${result} ${extensions_sorted} PARENT_SCOPE)
endfunction()

# Get extension dependencies from the add_dependencies().
function(_php_extensions_get_dependencies directory result)
  unset(${result} PARENT_SCOPE)

  cmake_path(GET directory FILENAME extension)

  if(NOT EXISTS ${directory}/CMakeLists.txt)
    message(DEBUG "${extension}: ${directory}/CMakeLists.txt not found")
    return()
  endif()

  file(READ ${directory}/CMakeLists.txt content)

  # Remove line comments from CMake code content.
  string(REGEX REPLACE "#[^\r\n]*[\r\n]" "" content "${content}")

  string(CONCAT regex
    # Command invocation:
    "add_dependencies[ \t]*\\("
    # Target name:
    "[ \t\r\n]*php_${extension}[ \t\r\n]+"
    # Dependencies:
    "[\"]?(php_[a-zA-Z0-9_; \t\r\n]+)"
  )

  string(REGEX MATCHALL "${regex}" matches "${content}")

  set(all_dependencies "")

  foreach(match ${matches})
    if(match MATCHES "${regex}")
      if(CMAKE_MATCH_1)
        string(STRIP "${CMAKE_MATCH_1}" dependencies)
        string(REPLACE " " ";" dependencies "${dependencies}")
        list(TRANSFORM dependencies REPLACE "^php_" "")
        list(APPEND all_dependencies ${dependencies})
      endif()
    endif()
  endforeach()

  if(all_dependencies)
    list(REMOVE_DUPLICATES all_dependencies)

    get_cmake_property(all_extensions PHP_ALL_EXTENSIONS)

    foreach(dependency ${all_dependencies})
      if(NOT "${dependency}" IN_LIST all_extensions)
        list(REMOVE_ITEM all_dependencies ${dependency})
      endif()
    endforeach()

    message(DEBUG "${extension} dependencies: ${all_dependencies}")

    set(${result} "${all_dependencies}" PARENT_SCOPE)
  endif()
endfunction()

# Get a regex string to match option().
function(_php_extensions_option_regex option result)
  string(CONCAT _
    # Start of the option command invocation:
    "[ \t\r\n]?option[ \t]*\\([ \t\r\n]*"
    # Optional line comments:
    "([ \t\r\n]*#[^\r\n]*[\r\n])*"
    # Variable name:
    "[ \t\r\n]*${option}[ \t\r\n]+"
    # Optional line comments:
    "([ \t\r\n]*#[^\r\n]*[\r\n])*"
    # Documentation string without escaped double quotes (\"):
    # TODO: should escaped quotes be also matched?
    #"[ \t\r\n]*\"([^\"]|\\\")*\"[ \t\r\n]*"
    "[ \t\r\n]*\"[^\"]*\"[ \t\r\n]*"
    # Optional line comments:
    "([ \t\r\n]*#[^\r\n]*[\r\n])*"
    # Optional boolean or variable value:
    "([ \t\r\n]+("
    "ON|on|TRUE|true|YES|yes|Y|y|"
    "OFF|off|FALSE|false|NO|no|N|n|"
    "[0-9.]+|"
    "\\\$\\{[^\\}]+\\}"
    "))?"
    # Optional line comments:
    "([ \t\r\n]*#[^\r\n]*[\r\n])*"
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
    # Possible inline comments:
    "([ \t\r\n]*#[^\r\n]*[\r\n])*"
    # Variable name:
    "[ \t\r\n]*${option}[ \t\r\n]+"
    # Optional line comments:
    "([ \t\r\n]*#[^\r\n]*[\r\n])*"
    # Documentation string without escaped double quotes (\"):
    # TODO: should escaped quotes be also matched?
    #"[ \t\r\n]*\"([^\"]|\\\")*\"[ \t\r\n]*"
    "[ \t\r\n]*\"[^\"]*\"[ \t\r\n]*"
    # Optional line comments:
    "([ \t\r\n]*#[^\r\n]*[\r\n])*"
    # Boolean or variable value:
    "[ \t\r\n]+("
    "ON|on|TRUE|true|YES|yes|Y|y|"
    "OFF|off|FALSE|false|NO|no|N|n|"
    "[0-9.]+|"
    "\\\$\\{[^\\}]+\\}"
    ")"
    # Optional line comments:
    "([ \t\r\n]*#[^\r\n]*[\r\n])*"
    # Semicolon separated list of conditions:
    "[ \t\r\n]*\"[^\"]*\"[ \t\r\n]*"
    # Optional line comments:
    "([ \t\r\n]*#[^\r\n]*[\r\n])*"
    # Boolean or variable force value:
    "[ \t\r\n]+("
    "ON|on|TRUE|true|YES|yes|Y|y|"
    "OFF|off|FALSE|false|NO|no|N|n|"
    "[0-9.]+|"
    "\\\$\\{[^\\}]+\\}"
    ")"
    # Optional line comments:
    "([ \t\r\n]*#[^\r\n]*[\r\n])*"
    # End of option invocation:
    "[ \t\r\n]*\\)"
  )

  set(${result} "${_}" PARENT_SCOPE)
endfunction()

# Parse and evaluate options of extensions.
function(_php_extensions_eval_options directories)
  set(code "")
  get_cmake_property(always_enabled_extensions PHP_ALWAYS_ENABLED_EXTENSIONS)
  get_cmake_property(all_extensions PHP_ALL_EXTENSIONS)

  foreach(dir ${directories})
    cmake_path(GET dir FILENAME extension)

    # Skip if extension is always enabled or if dependency is not extension.
    if(
      extension IN_LIST always_enabled_extensions
      OR NOT extension IN_LIST all_extensions
    )
      continue()
    endif()

    message(DEBUG "Parsing and evaluating ${extension} options")

    file(READ ${dir}/CMakeLists.txt content)
    string(TOUPPER "${extension}" extension_upper)

    # If extension has option(EXT_<extension> ...).
    _php_extensions_option_regex("EXT_${extension_upper}" regex)
    string(REGEX MATCH "${regex}" code "${content}")

    if(code)
      message(DEBUG "Evaluating code:\n${code}")
      cmake_language(EVAL CODE "${code}")
      unset(code)
    endif()

    # If extension has cmake_dependent_option(EXT_<extension> ...).
    _php_extensions_cmake_dependent_option_regex(
      "EXT_${extension_upper}"
      regex
    )
    string(REGEX MATCH "${regex}" code "${content}")

    if(code)
      message(DEBUG "Evaluating code:\n${code}")
      cmake_language(EVAL CODE "${code}")
      unset(code)
    endif()

    # If extension has cmake_dependent_option(EXT_<extension>_SHARED ...).
    _php_extensions_cmake_dependent_option_regex(
      "EXT_${extension_upper}_SHARED"
      regex
    )

    string(REGEX MATCH "${regex}" code "${content}")

    if(code)
      message(DEBUG "Evaluating code:\n${code}")
      cmake_language(EVAL CODE "${code}")
      unset(code)
    endif()

    if(DEFINED EXT_${extension_upper})
      message(
        DEBUG
        "EXT_${extension_upper}=${EXT_${extension_upper}}"
      )
    endif()

    if(DEFINED EXT_${extension_upper}_SHARED)
      message(
        DEBUG
        "EXT_${extension_upper}_SHARED=${EXT_${extension_upper}_SHARED}"
      )
    endif()
  endforeach()
endfunction()

# Configure extensions according to their dependencies.
function(_php_extensions_configure directories)
  foreach(dir ${directories})
    cmake_path(GET dir FILENAME extension)
    string(TOUPPER "${extension}" extension_upper)

    if(NOT EXT_${extension_upper})
      continue()
    endif()

    # Mark shared option variable as advanced.
    if(DEFINED EXT_${extension_upper}_SHARED)
      mark_as_advanced(EXT_${extension_upper}_SHARED)
    endif()

    _php_extensions_get_dependencies("${dir}" dependencies)

    # If extension is enabled and one of its dependencies is built as a shared
    # library, configure extension also as a shared library.
    foreach(dependency ${dependencies})
      string(TOUPPER "${dependency}" dependency_upper)

      if(EXT_${dependency_upper}_SHARED AND NOT EXT_${extension_upper}_SHARED)
        message(
          WARNING
          "The '${extension}' extension must be built as a shared library due "
          "to its dependency on the '${dependency}' extension, which is "
          "configured as shared. The 'EXT_${extension_upper}_SHARED' option "
          "has been automatically set to 'ON'."
        )

        set(
          EXT_${extension_upper}_SHARED
          ON
          CACHE BOOL
          "Build the ${extension} extension as a shared library"
          FORCE
        )

        break()
      endif()
    endforeach()

    get_cmake_property(always_enabled_extensions PHP_ALWAYS_ENABLED_EXTENSIONS)

    # If extension is enabled, enable also all its dependencies.
    foreach(dependency ${dependencies})
      string(TOUPPER "${dependency}" dependency_upper)

      if(EXT_${dependency_upper} OR dependency IN_LIST always_enabled_extensions)
        continue()
      endif()

      message(
        WARNING
        "The '${extension}' extension requires the '${dependency}' extension. "
        "The 'EXT_${dependency_upper}' option has been automatically set to "
        "'ON'."
      )

      set(
        EXT_${dependency_upper}
        ON
        CACHE BOOL
        "Enable the ${dependency} extension"
        FORCE
      )
    endforeach()
  endforeach()
endfunction()

# Configure extension after extension CMakeLists.txt is added.
function(_php_extensions_post_configure directory)
  cmake_path(GET directory FILENAME extension)

  if(NOT TARGET php_${extension})
    return()
  endif()

  set_property(GLOBAL APPEND PROPERTY PHP_EXTENSIONS ${extension})

  if(NOT TARGET PHP::${extension})
    add_library(PHP::${extension} ALIAS php_${extension})
  endif()

  # Set target output filename to "<extension>".
  get_target_property(output php_${extension} OUTPUT_NAME)
  if(NOT output)
    set_property(TARGET php_${extension} PROPERTY OUTPUT_NAME ${extension})
  endif()

  # Add extension's default installation instructions.
  install(
    TARGETS php_${extension}
    ARCHIVE EXCLUDE_FROM_ALL
    RUNTIME
      DESTINATION ${PHP_EXTENSION_DIR}
    LIBRARY
      DESTINATION ${PHP_EXTENSION_DIR}
    FILE_SET HEADERS
      DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/ext/${extension}
  )

  # Check if extension is always enabled.
  get_cmake_property(extensions PHP_ALWAYS_ENABLED_EXTENSIONS)
  if(extension IN_LIST extensions)
    return()
  endif()

  # Define HAVE_<extension-name> symbol for php_config.h.
  string(TOUPPER "HAVE_${extension}" symbol)
  set(
    ${symbol} 1
    CACHE INTERNAL "Whether to enable the ${extension} extension."
  )

  get_target_property(extension_type php_${extension} TYPE)

  if(NOT extension_type MATCHES "^(MODULE|SHARED)_LIBRARY$")
    return()
  endif()

  # Set location where to put shared extensions.
  get_target_property(location php_${extension} LIBRARY_OUTPUT_DIRECTORY)
  if(NOT location)
    set_property(TARGET php_${extension}
      PROPERTY LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/modules"
    )
  endif()

  # Define COMPILE_DL_<extension-name> symbol for php_config.h to indicate
  # extension is built as a shared library and add compile definitions.
  string(TOUPPER "COMPILE_DL_${extension}" symbol)
  set(
    ${symbol} 1
    CACHE INTERNAL "Whether ${extension} is built as a shared library."
  )
  target_compile_definitions(php_${extension} PRIVATE ZEND_COMPILE_DL_EXT=1)
endfunction()

# Validate extensions and their dependencies defined via add_dependencies().
function(_php_extensions_validate extensions)
  foreach(extension ${extensions})
    if(NOT TARGET php_${extension})
      continue()
    endif()

    get_target_property(
      dependencies
      php_${extension}
      MANUALLY_ADDED_DEPENDENCIES
    )

    if(NOT dependencies)
      continue()
    endif()

    list(TRANSFORM dependencies REPLACE "^php_" "")

    get_cmake_property(all_extensions PHP_ALL_EXTENSIONS)

    foreach(dependency ${dependencies})
      # Skip dependencies that are not PHP extensions.
      if(NOT dependency IN_LIST all_extensions)
        continue()
      endif()

      string(TOUPPER "${dependency}" dependency_upper)

      if(NOT TARGET php_${dependency} OR NOT dependency IN_LIST extensions)
        message(
          FATAL_ERROR
          "You've enabled the '${extension}' extension, which depends on the "
          "'${dependency}' extension, but you've either not enabled "
          "'${dependency}', or have disabled it. Please set "
          "'EXT_${dependency_upper}' to 'ON' if available."
        )
      endif()

      get_target_property(dependency_type php_${dependency} TYPE)
      get_target_property(extension_type php_${extension} TYPE)

      if(
        dependency_type MATCHES "^(MODULE|SHARED)_LIBRARY$"
        AND NOT extension_type MATCHES "^(MODULE|SHARED)_LIBRARY$"
      )
        message(
          FATAL_ERROR
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
