#[=============================================================================[
Traverses all PHP extensions and processes the CMakeLists.txt files in them.
]=============================================================================]#

function(get_php_extensions result directory level)
  file(GLOB_RECURSE SUBDIRECTORIES LIST_DIRECTORIES true "${directory}/*/" "ext/*/CMakeLists.txt")
  set(directories "")
  foreach(subdirectory ${SUBDIRECTORIES})
    if(EXISTS "${subdirectory}/CMakeLists.txt")
      # Get the directory depth
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
  set(${result} ${directories} PARENT_SCOPE)
endfunction()

# Usage example: Include subdirectories within 'ext/' up to a depth of 1
get_php_extensions(SUBDIRECTORIES "${CMAKE_CURRENT_SOURCE_DIR}/ext" 1)

# Process the list of directories
foreach(SUBDIRECTORY ${SUBDIRECTORIES})
  string(REPLACE ${CMAKE_CURRENT_SOURCE_DIR}/ext/ "" EXTENSION_NAME ${SUBDIRECTORY})
  string(REPLACE /CMakeLists.txt "" EXTENSION_NAME ${EXTENSION_NAME})
  add_subdirectory("ext/${EXTENSION_NAME}")
endforeach()
