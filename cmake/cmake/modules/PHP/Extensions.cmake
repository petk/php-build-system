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
  PROPERTY PHP_ALWAYS_ENABLED_EXTENSIONS
  BRIEF_DOCS "A list of always enabled PHP extensions"
  FULL_DOCS "This property contains a list of always enabled PHP extenions "
            "sorted by the directory priority and their dependencies. These "
            "extensions don't need HAVE_<extension-name> contants and can be "
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

# Try to determine the extension's enabled/disabled option value.
function(_php_extensions_infer_option directory result)
  unset(${result} PARENT_SCOPE)

  cmake_path(GET directory FILENAME extension_name)

  string(TOUPPER "EXT_${extension_name}" option)

  if(DEFINED ${option})
    set(${result} ${${option}} PARENT_SCOPE)
    return()
  endif()

  file(READ "${directory}/CMakeLists.txt" content)

  string(
    REGEX MATCH
    "option[\r\n\t ]*\\([\r\n\t ]*${option}[\r\n\t ]+\"[^\"]+\"[\r\n\t ]+([0-9a-zA-Z]+)[\r\n\t ]*\\)"
    _
    "${content}"
  )

  string(TOLOWER "${CMAKE_MATCH_1}" value)

  set(truthy_list "on;true;yes;y;1")
  set(falsy_list "off;false;no;n;0")

  if(value IN_LIST truthy_list)
    set(${result} ON PARENT_SCOPE)
  elseif(value IN_LIST falsy_list)
    set(${result} OFF PARENT_SCOPE)
  endif()
endfunction()

# Get extension dependencies from the PHP_EXTENSION_DEPENDENCIES property.
function(_php_extensions_get_dependencies directory result)
  unset(${result} PARENT_SCOPE)

  file(READ "${directory}/CMakeLists.txt" content)

  string(
    REGEX MATCH
    "set_target_properties[\r\n\t ]*\\(.*PROPERTIES[\r\n\t ]+.*PHP_EXTENSION_DEPENDENCIES[\r\n\t ]+[\"]?(php_[a-zA-Z0-9_;]+)"
    _
    "${content}"
  )

  if(NOT CMAKE_MATCH_1)
    string(
      REGEX MATCH
      "set_property[\r\n\t ]*\\([\r\n\t ]*TARGET[\r\n\t ]+.*PROPERTY[\r\n\t ]+PHP_EXTENSION_DEPENDENCIES[\r\n\t ]+[\"]?(php_[a-zA-Z0-9_;\r\n\t ]+)"
      _
      "${content}"
    )
  endif()

  if(CMAKE_MATCH_1)
    string(STRIP "${CMAKE_MATCH_1}" dependencies)
    string(REPLACE " " ";" dependencies "${dependencies}")
    list(TRANSFORM dependencies REPLACE "^php_" "")

    set(${result} ${dependencies} PARENT_SCOPE)
  endif()
endfunction()

# Sort extension directories by the target property PHP_EXTENSION_DEPENDENCIES.
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

# Sort extension directories by the directory property PHP_PRIORITY.
function(_php_extensions_sort_by_priority directories result)
  set(extensions_before "")
  set(extensions_middle "")
  set(extensions_after "")

  foreach(dir ${directories})
    file(READ "${dir}/CMakeLists.txt" content)

    string(
      REGEX MATCH
      "set_directory_properties[\r\n\t ]*\\(.*PROPERTIES[\r\n\t ]+.*PHP_PRIORITY[\r\n\t ]+([0-9]+)"
      _
      "${content}"
    )

    if(NOT CMAKE_MATCH_1)
      string(
        REGEX MATCH
        "set_property[\r\n\t ]*\\([\r\n\t ]*DIRECTORY.*PROPERTY[\r\n\t ]+PHP_PRIORITY[\r\n\t ]+([0-9]+)"
        _
        "${content}"
      )
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

# Validate extensions and their dependencies defined with the custom target
# property PHP_EXTENSION_DEPENDENCIES.
function(_php_extensions_validate extensions)
  foreach(extension ${extensions})
    if(NOT TARGET php_${extension})
      continue()
    endif()

    get_target_property(dependencies php_${extension} PHP_EXTENSION_DEPENDENCIES)

    if(NOT dependencies)
      continue()
    endif()

    list(TRANSFORM dependencies REPLACE "^php_" "")

    foreach(dependency ${dependencies})
      string(TOUPPER "${dependency}" dependency_upper)

      if(NOT TARGET php_${dependency} OR NOT dependency IN_LIST extensions)
        message(
          FATAL_ERROR
          "You've configured extension ${extension}, which depends on "
          "extension ${dependency}, but you've either not enabled "
          "${dependency}, or have disabled it. Set EXT_${dependency_upper}=ON"
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
          "You've configured extension ${extension} to build statically, but "
          "it depends on extension ${dependency}, which you've configured to "
          "build shared. You either need to build ${extension} shared or build "
          "${dependency} statically for the build to be successful."
        )
      endif()
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

  # Define COMPILE_DL_<extension-name> constant for php_config.h.
  string(TOUPPER "COMPILE_DL_${extension}" DYNAMIC_NAME)
  set(
    ${DYNAMIC_NAME}
    1
    CACHE INTERNAL
    "Whether to build ${extension} as a shared library"
  )
endfunction()

# Initialize extensions.
function(_php_extensions_initialize directories)
  list(GET directories 0 parent_directory)
  cmake_path(GET parent_directory PARENT_PATH parent_directory)

  foreach(dir ${directories})
    cmake_path(GET dir FILENAME extension)
    string(TOUPPER "${extension}" extension_upper)

    _php_extensions_infer_option("${dir}" is_extension_enabled)

    if(NOT is_extension_enabled)
      continue()
    endif()

    _php_extensions_get_dependencies("${dir}" dependencies)

    # If extension is enabled and one of its dependencies is built as shared,
    # make sure to configure extension as shared.
    foreach(dependency ${dependencies})
      string(TOUPPER "EXT_${dependency}_SHARED" is_shared_option)

      if(${is_shared_option} AND NOT EXT_${extension_upper}_SHARED)
        message(
          WARNING
          "Extension ${extension} must be built as a shared library because "
          "its dependency ${dependency} is set to be built as shared."
          "Setting EXT_${extension_upper}_SHARED=ON"
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

    # If extension is enabled, make sure also all dependencies are enabled.
    foreach(dependency ${dependencies})
      string(TOUPPER "${dependency}" dependency_upper)

      _php_extensions_infer_option(
        "${parent_directory}/${dependency}"
        is_dependency_enabled
      )

      if(NOT ${is_dependency_enabled})
        message(
          WARNING
          "The ${dependency} extension needs to be enabled for "
          "${extension} extension. "
          "Setting EXT_${dependency_upper}=ON"
        )

        set(
          EXT_${dependency_upper}
          ON
          CACHE BOOL
          "Enable the ${dependency} extension"
          FORCE
        )
      endif()
    endforeach()
  endforeach()
endfunction()

# Parse extension subdirectories and sort them.
function(_php_extensions_parse directory result)
  file(GLOB extensions "${directory}/*/CMakeLists.txt")

  foreach(extension ${extensions})
    cmake_path(GET extension PARENT_PATH dir)
    list(APPEND directories "${dir}")
  endforeach()

  _php_extensions_sort_by_dependencies("${directories}" sorted)
  _php_extensions_sort_by_priority("${sorted}" sorted)

  set(${result} ${sorted} PARENT_SCOPE)
endfunction()

# Add extension subdirectories.
function(_php_extensions_include directory)
  _php_extensions_parse("${directory}" directories)
  _php_extensions_initialize("${directories}")

  foreach(dir ${directories})
    _php_extensions_add("${dir}")
  endforeach()

  get_cmake_property(extensions PHP_EXTENSIONS)
  _php_extensions_validate("${extensions}")
endfunction()

################################################################################
# Module execution.
################################################################################

_php_extensions_include("${CMAKE_CURRENT_SOURCE_DIR}/ext")
