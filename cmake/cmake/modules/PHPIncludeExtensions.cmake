#[=============================================================================[
Traverses all PHP extensions and processes the CMakeLists.txt files in them.
]=============================================================================]#

function(get_php_extensions result directory level)
  file(GLOB_RECURSE SUBDIRECTORIES LIST_DIRECTORIES TRUE "${directory}/*/" "ext/*/CMakeLists.txt")
  set(directories "")
  foreach(subdirectory ${SUBDIRECTORIES})
    if(EXISTS "${subdirectory}/CMakeLists.txt")
      # Get the relative path of the subdirectory
      file(RELATIVE_PATH relative_path ${directory} ${subdirectory})
      # Get the directory depth
      string(REGEX MATCHALL "/" slashes "${relative_path}")
      list(LENGTH slashes depth)
      # Exclude directories deeper than the specified level
      if("${depth}" LESS "${level}")
        list(APPEND directories "${subdirectory}")
      endif()
    endif()
  endforeach()

  # Sort extension directories by the PRIORITY value in the php_extension().
  set(sorted_directories ${directories})

  foreach(directory ${directories})
    file(READ "${directory}/CMakeLists.txt" content)

    # The dummy _ variable name is used because entire content matched is not
    # important, only the group match.
    string(REGEX MATCH "php_extension[\\r\\n\\t ]*\\(.*PRIORITY[\\r\\n\\t ]+([0-9]+)" _ ${content})

    if(${CMAKE_MATCH_1})
      set(priority ${CMAKE_MATCH_1})

      if(priority LESS 999)
        list(REMOVE_ITEM sorted_directories "${directory}")
        list(PREPEND sorted_directories "${directory}")
      endif()
    endif()
  endforeach()

  set(${result} ${sorted_directories} PARENT_SCOPE)
endfunction()

# Include subdirectories within 'ext/' up to a depth of 1.
get_php_extensions(SUBDIRECTORIES "${CMAKE_CURRENT_SOURCE_DIR}/ext" 1)

# Process the list of directories
foreach(subdirectory ${SUBDIRECTORIES})
  string(REPLACE ${CMAKE_CURRENT_SOURCE_DIR}/ext/ "" EXTENSION_NAME ${subdirectory})
  string(REPLACE /CMakeLists.txt "" EXTENSION_NAME ${EXTENSION_NAME})
  add_subdirectory("ext/${EXTENSION_NAME}")
endforeach()
