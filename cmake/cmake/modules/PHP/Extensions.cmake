#[=============================================================================[
Traverses all PHP extensions and processes their CMakeLists.txt files. Extension
directories are sorted by the optional directory property PHP_PRIORITY value. If
extension has specified dependencies using the custom PHP_EXT_DEPENDS target
property, these are also checked accordingly.

Cache variables:

PHP_EXTENSIONS
  A list of all enabled extensions.
]=============================================================================]#

# Parse extension subdirectories and sort them by the PHP_PRIORITY property.
function(_php_parse_extensions result directory)
  file(GLOB extensions "${directory}/ext/*/CMakeLists.txt")

  foreach(extension ${extensions})
    cmake_path(GET extension PARENT_PATH extension_dir)
    list(APPEND directories "${extension_dir}")
  endforeach()

  # Sort extension directories by the optional directory property PHP_PRIORITY.
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

    if(CMAKE_MATCH_1)
      list(APPEND directories_numbered "${CMAKE_MATCH_1}.${dir}")
    else()
      list(APPEND directories_numbered "99.${dir}")
    endif()
  endforeach()

  list(SORT directories_numbered COMPARE NATURAL)

  foreach(dir ${directories_numbered})
    string(REGEX MATCHALL "[0-9]+\\.(.*)" _ "${dir}")
    list(APPEND directories_sorted ${CMAKE_MATCH_1})
  endforeach()

  set(${result} ${directories_sorted} PARENT_SCOPE)
endfunction()

_php_parse_extensions(extension_directories "${CMAKE_CURRENT_SOURCE_DIR}")

set(PHP_EXTENSIONS "" CACHE INTERNAL "")

# Add extension subdirectories.
foreach(extension ${extension_directories})
  add_subdirectory("${extension}")

  cmake_path(GET extension FILENAME extension_name)

  if(NOT TARGET php_${extension_name})
    continue()
  endif()

  set(
    PHP_EXTENSIONS
    ${PHP_EXTENSIONS} ${extension_name}
    CACHE INTERNAL ""
  )

  # Define constant for php_config.h. Some extensions are always available so
  # they don't need HAVE_* constants.
  if(NOT "${extension_name}" IN_LIST "date;hash;json;pcre;random;reflection;spl;standard")
    string(TOUPPER "HAVE_${extension_name}" DYNAMIC_NAME)
    set(${DYNAMIC_NAME} 1 CACHE INTERNAL "Whether to enable the ${extension_name} extension.")
  endif()

  get_target_property(extension_type php_${extension_name} TYPE)

  if(extension_type STREQUAL "SHARED_LIBRARY")
    string(TOUPPER "COMPILE_DL_${extension_name}" DYNAMIC_NAME)
    set(${DYNAMIC_NAME} 1 CACHE INTERNAL "Whether to build ${extension_name} as dynamic module")
  endif()

  # Check and configure dependencies if missing.
  get_target_property(dependencies php_${extension_name} PHP_EXT_DEPENDS)

  if(NOT dependencies)
    continue()
  endif()

  string(TOUPPER "${extension_name}" extension_name_upper)

  foreach(dependency ${dependencies})
    string(REGEX MATCH "^php_(.*)" _ "${dependency}")
    string(TOUPPER "${CMAKE_MATCH_1}" dependency_extension_upper)

    if(NOT EXT_${dependency_extension_upper})
      set(EXT_${dependency_extension_upper} ON CACHE BOOL "" FORCE)
    endif()
  endforeach()
endforeach()

# Check extensions and their dependencies defined with the custom target
# property PHP_EXT_DEPENDS.
foreach(extension ${PHP_EXTENSIONS})
  get_target_property(dependencies php_${extension} PHP_EXT_DEPENDS)

  if(NOT dependencies)
    continue()
  endif()

  foreach(dependency ${dependencies})
    string(REGEX MATCH "^php_(.*)" _ "${dependency}")
    string(TOUPPER "${CMAKE_MATCH_1}" dependency_extension_upper)

    if(NOT TARGET ${dependency} OR NOT ${CMAKE_MATCH_1} IN_LIST PHP_EXTENSIONS)
      message(
        FATAL_ERROR
        "You've configured extension ${extension}, which depends on extension "
        "${CMAKE_MATCH_1}, but you've either not enabled ${CMAKE_MATCH_1}, or "
        "have disabled it. Set EXT_${dependency_extension_upper}=ON"
      )
    endif()

    get_target_property(dependency_type ${dependency} TYPE)
    get_target_property(extension_type php_${extension} TYPE)

    if(
      dependency_type STREQUAL "SHARED_LIBRARY"
      AND NOT extension_type STREQUAL "SHARED_LIBRARY"
    )
      message(
        FATAL_ERROR
        "You've configured extension ${extension} to build statically, but it "
        "depends on extension ${CMAKE_MATCH_1}, which you've configured to "
        "build shared. You either need to build ${extension} shared or build "
        "${CMAKE_MATCH_1} statically for the build to be successful."
      )
    endif()
  endforeach()
endforeach()
