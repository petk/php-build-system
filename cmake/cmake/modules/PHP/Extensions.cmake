#[=============================================================================[
Traverses PHP extensions CMakeLists.txt files. Extension directories are sorted
by the optional directory property PHP_PRIORITY value and the dependencies
listed in the PHP_EXTENSION_DEPENDENCIES target property. If extension has
specified dependencies, it makes sure all dependencies are enabled. If one of
the dependencies is built as a SHARED library, the extension must be also
SHARED.
]=============================================================================]#

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
  PROPERTY PHP_EXTENSION_DEPENDENCIES
  BRIEF_DOCS "A list of depending PHP extensions targets"
  FULL_DOCS "This property enables the specification of dependencies for PHP "
            "extension targets. When defining PHP extension targets, these "
            "dependencies are automatically enabled if they haven't been "
            "explicitly configured. If any of the specified dependencies are "
            "built as SHARED, the PHP extension target itself must also be "
            "built as SHARED. Failing to do so will result in a fatal error "
            "during the configuration phase. Additionally, the dependencies "
            "are added to the beginning of the extensions list when added with "
            "add_subdirectory()."
)

define_property(
  GLOBAL
  PROPERTY PHP_EXTENSIONS
  BRIEF_DOCS "A list of all enabled extensions"
  FULL_DOCS "This property contains a list of all enabled PHP extensions for "
            "the current configuration. Extensions are sorted by the directory "
            "priority and their dependencies."
)

define_property(
  GLOBAL
  PROPERTY PHP_ALWAYS_ENABLED_EXTENSIONS
  BRIEF_DOCS "A list of always enabled PHP extensions"
  FULL_DOCS "This property contains a list of always enabled PHP extenions "
            "which don't need HAVE_<extension-name> contants and can be "
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

################################################################################
# Module internal helper functions.
################################################################################

# Add subdirectories of extensions.
function(_php_extensions_include directory)
  # Get a list of subdirectories related to extensions.
  _php_extensions_get("${directory}" directories)

  # Evaluate options of extensions.
  _php_extensions_eval_options("${directories}")

  # Configure extensions and their dependencies.
  _php_extensions_configure("${directories}")

  # Add subdirectories of extensions.
  foreach(dir ${directories})
    _php_extensions_add("${dir}")
  endforeach()

  # Validate options of extensions and their dependencies.
  get_cmake_property(extensions PHP_EXTENSIONS)
  _php_extensions_validate("${extensions}")
endfunction()

# Get a sorted list of subdirectories related to extensions.
function(_php_extensions_get directory result)
  file(GLOB extensions "${directory}/*/CMakeLists.txt")

  foreach(extension ${extensions})
    cmake_path(GET extension PARENT_PATH dir)
    list(APPEND directories "${dir}")
  endforeach()

  _php_extensions_sort_by_dependencies("${directories}" sorted)
  _php_extensions_sort_by_priority("${sorted}" sorted)

  set(${result} ${sorted} PARENT_SCOPE)
endfunction()

# Sort subdirectories of extensions by the target property
# PHP_EXTENSION_DEPENDENCIES.
function(_php_extensions_sort_by_dependencies directories result)
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
function(_php_extensions_sort_by_priority directories result)
  set(extensions_before "")
  set(extensions_middle "")
  set(extensions_after "")

  foreach(dir ${directories})
    file(READ "${dir}/CMakeLists.txt" content)

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

# Get extension dependencies from the PHP_EXTENSION_DEPENDENCIES property.
function(_php_extensions_get_dependencies directory result)
  unset(${result} PARENT_SCOPE)

  file(READ "${directory}/CMakeLists.txt" content)

  string(CONCAT regex
    # Command invocation:
    "set_target_properties[ \t]*\\("
    # Starting properties keyword:
    ".*PROPERTIES[ \t\r\n]+.*"
    # Custom property name:
    "PHP_EXTENSION_DEPENDENCIES[ \t\r\n]+"
    # Target names:
    "[\"]?(php_[a-zA-Z0-9_;]+)"
  )

  string(REGEX MATCH "${regex}" _ "${content}")

  if(NOT CMAKE_MATCH_1)
    string(CONCAT regex
      # Command invocation:
      "set_property[ \t]*\\([ \t\r\n]*"
      # Scope:
      "TARGET[ \t\r\n]+.*"
      # Custom property:
      "PROPERTY[ \t\r\n]+PHP_EXTENSION_DEPENDENCIES[ \t\r\n]+"
      # A list of dependencies:
      "[\"]?(php_[a-zA-Z0-9_; \t\r\n]+)"
    )

    string(REGEX MATCH "${regex}" _ "${content}")
  endif()

  if(CMAKE_MATCH_1)
    string(STRIP "${CMAKE_MATCH_1}" dependencies)
    string(REPLACE " " ";" dependencies "${dependencies}")
    list(TRANSFORM dependencies REPLACE "^php_" "")

    set(${result} ${dependencies} PARENT_SCOPE)
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

  foreach(dir ${directories})
    cmake_path(GET dir FILENAME extension)
    message(DEBUG "Parsing and evaluating ${extension} options")

    file(READ "${dir}/CMakeLists.txt" content)
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
  list(GET directories 0 parent_directory)
  cmake_path(GET parent_directory PARENT_PATH parent_directory)

  foreach(dir ${directories})
    cmake_path(GET dir FILENAME extension)
    string(TOUPPER "${extension}" extension_upper)

    if(NOT EXT_${extension_upper})
      continue()
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

    # If extension is enabled, enable also all its dependencies.
    foreach(dependency ${dependencies})
      string(TOUPPER "${dependency}" dependency_upper)

      if(EXT_${dependency_upper})
        continue()
      endif()

      message(
        WARNING
        "The '${dependency}' extension requires the '${extension}' extension. "
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

# Add extension subdirectory and add it to enabled extensions.
function(_php_extensions_add directory)
  add_subdirectory("${directory}")

  cmake_path(GET directory FILENAME extension)

  if(NOT TARGET php_${extension})
    return()
  endif()

  set_property(GLOBAL APPEND PROPERTY PHP_EXTENSIONS ${extension})

  # Check if extension is always enabled.
  get_cmake_property(extensions PHP_ALWAYS_ENABLED_EXTENSIONS)
  if(extension IN_LIST extensions)
    return()
  endif()

  # Define HAVE_<extension-name> constant for php_config.h.
  string(TOUPPER "HAVE_${extension}" DYNAMIC_NAME)
  set(
    ${DYNAMIC_NAME}
    1
    CACHE INTERNAL
    "Whether to enable the ${extension} extension."
  )

  get_target_property(extension_type php_${extension} TYPE)

  if(NOT extension_type STREQUAL "SHARED_LIBRARY")
    return()
  endif()

  # Define COMPILE_DL_<extension-name> constant for php_config.h to indicate
  # extension is built as a shared library.
  string(TOUPPER "COMPILE_DL_${extension}" DYNAMIC_NAME)
  set(
    ${DYNAMIC_NAME}
    1
    CACHE INTERNAL
    "Whether to build ${extension} as a shared library"
  )
endfunction()

# Validate extensions and their dependencies defined with the custom target
# property PHP_EXTENSION_DEPENDENCIES.
function(_php_extensions_validate extensions)
  foreach(extension ${extensions})
    if(NOT TARGET php_${extension})
      continue()
    endif()

    get_target_property(
      dependencies
      php_${extension}
      PHP_EXTENSION_DEPENDENCIES
    )

    if(NOT dependencies)
      continue()
    endif()

    list(TRANSFORM dependencies REPLACE "^php_" "")

    foreach(dependency ${dependencies})
      string(TOUPPER "${dependency}" dependency_upper)

      if(NOT TARGET php_${dependency} OR NOT dependency IN_LIST extensions)
        message(
          FATAL_ERROR
          "You've enabled the '${extension}' extension, which depends on the "
          "'${dependency}', but you've either not enabled '${dependency}', or "
          "have disabled it. Please set 'EXT_${dependency_upper}' to 'ON'."
        )
      endif()

      get_target_property(dependency_type php_${dependency} TYPE)
      get_target_property(extension_type php_${extension} TYPE)

      if(
        dependency_type STREQUAL "SHARED_LIBRARY"
        AND NOT extension_type STREQUAL "SHARED_LIBRARY"
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

################################################################################
# Module execution.
################################################################################

_php_extensions_include("${CMAKE_CURRENT_SOURCE_DIR}/ext")
