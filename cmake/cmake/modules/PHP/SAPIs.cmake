#[=============================================================================[
Add subdirectories of PHP SAPIs via `add_subdirectory()`.

This module is responsible for traversing `CMakeLists.txt` files of PHP SAPIs
and adding them via `add_subdirectory()`.

## Exposed macro

```cmake
php_sapis_add(subdirectory)
```

## Custom CMake properties

* `PHP_ALL_SAPIS`

  Global property with a list of all PHP SAPIs in the sapi directory.

* `PHP_SAPIS`

  This global property contains a list of all enabled PHP SAPIs for the current
  configuration.
#]=============================================================================]

macro(php_sapis_add directory)
  _php_sapis_get(${directory} directories)

  # Add subdirectories of PHP SAPIs.
  foreach(dir ${directories})
    cmake_path(GET dir FILENAME sapi)
    message(STATUS "Checking ${sapi} SAPI")
    list(APPEND CMAKE_MESSAGE_CONTEXT "sapi/${sapi}")
    unset(sapi)

    add_subdirectory("${dir}")

    list(POP_BACK CMAKE_MESSAGE_CONTEXT)

    _php_sapis_post_configure("${dir}")
  endforeach()

  _php_sapis_validate()

  unset(directories)
  unset(sapis)
endmacro()

# Get a list of subdirectories related to PHP SAPIs.
function(_php_sapis_get directory result)
  file(GLOB paths ${directory}/*/CMakeLists.txt)

  set(directories "")

  foreach(path ${paths})
    cmake_path(GET path PARENT_PATH dir)
    list(APPEND directories "${dir}")

    # Add SAPI name to a list of all SAPIs.
    cmake_path(GET dir FILENAME sapi)
    set_property(GLOBAL APPEND PROPERTY PHP_ALL_SAPIS ${module})
  endforeach()

  set(${result} ${directories} PARENT_SCOPE)
endfunction()

# Configure SAPI after its CMakeLists.txt is added.
function(_php_sapis_post_configure directory)
  cmake_path(GET directory FILENAME sapi)

  if(NOT TARGET php_${sapi})
    return()
  endif()

  set_property(GLOBAL APPEND PROPERTY PHP_SAPIS ${sapi})

  if(NOT TARGET PHP::${sapi})
    get_target_property(type php_${sapi} TYPE)

    if(type STREQUAL "EXECUTABLE")
      add_executable(PHP::${sapi} ALIAS php_${sapi})
    else()
      add_library(PHP::${sapi} ALIAS php_${sapi})
    endif()
  endif()
endfunction()

# Check if at least one SAPI is enabled.
function(_php_sapis_validate)
  get_cmake_property(sapis PHP_SAPIS)
  if(NOT sapis)
    message(
      WARNING
      "None of the PHP SAPIs have been enabled. If this is intentional, you "
      "can disregard this warning."
    )
  endif()
endfunction()
