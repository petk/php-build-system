#!/usr/bin/env -S cmake -P
#
# CMake-based command-line script to update minimum required CMake version,
# CMake presets version, and its schema URL.
#
# Configure versions below and run as:
#
#   cmake -P cmake/scripts/UpdateCMake.cmake [-- <paths>...]

set(version_min 4.3)
set(version_max 4.4)
set(presets_version 11)
set(
  presets_schema
  "https://cmake.org/cmake/help/latest/_downloads/3e2d73bff478d88a7de0de736ba5e361/schema.json"
)

cmake_minimum_required(VERSION ${version_min}...${version_max})

if(NOT CMAKE_SCRIPT_MODE_FILE)
  message(FATAL_ERROR "This is a command-line script.")
endif()

cmake_path(SET PHP_SOURCE_DIR NORMALIZE ${CMAKE_CURRENT_LIST_DIR}/../..)

# Get CMake files.
block(PROPAGATE cmake_files cmake_presets)
  set(has_end_commands_marker FALSE)
  set(paths "")

  foreach(index RANGE ${CMAKE_ARGC})
    if(NOT DEFINED CMAKE_ARGV${index})
      continue()
    endif()

    if(NOT has_end_commands_marker AND CMAKE_ARGV${index} STREQUAL "--")
      set(has_end_commands_marker TRUE)
      continue()
    endif()

    if(has_end_commands_marker)
      list(APPEND paths "${CMAKE_ARGV${index}}")
    endif()
  endforeach()

  set(files "")
  set(directories "")

  foreach(path IN LISTS paths)
    if(NOT IS_ABSOLUTE ${path})
      cmake_path(
        ABSOLUTE_PATH path
        BASE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        NORMALIZE
      )
    endif()

    if(IS_DIRECTORY "${path}")
      list(APPEND directories "${path}")
    elseif(EXISTS "${path}")
      list(APPEND files "${path}")
    endif()
  endforeach()

  if(NOT files AND NOT directories)
    list(APPEND directories ${PHP_SOURCE_DIR})
  endif()

  foreach(dir IN LISTS directories)
    file(
      GLOB_RECURSE found_files
      ${dir}/CMakeLists.txt
      ${dir}/CMakeLists.txt.in
      ${dir}/*.cmake
      ${dir}/*.cmake.in
      ${dir}/CMakePresets.json
      ${dir}/cmake/presets/*.json
    )

    list(APPEND files "${found_files}")
  endforeach()

  set(files_normalized "")
  foreach(file IN LISTS files)
    cmake_path(NORMAL_PATH file)
    list(APPEND files_normalized "${file}")
  endforeach()

  list(REMOVE_DUPLICATES files_normalized)

  set(cmake_presets "${files_normalized}")
  set(cmake_files "${files_normalized}")

  list(FILTER cmake_presets INCLUDE REGEX "\\.json$")
  list(FILTER cmake_files EXCLUDE REGEX "\\.json$")
endblock()

# Update version in found CMake files.
block()
  set(
    regex
    "(cmake_minimum_required[ \t]*\\([ \t\r\n]*VERSION[ \t\r\n]+)([0-9.]+)(\\.\\.\\.)([0-9.]+)"
  )

  foreach(file IN LISTS cmake_files)
    file(READ ${file} content)

    if(content MATCHES "${regex}")
      string(
        REGEX REPLACE "${regex}"
        "\\1${version_min}\\3${version_max}"
        updated_content
        "${content}"
      )

      if(NOT content STREQUAL updated_content)
        message(STATUS "Updating ${file}")

        file(WRITE ${file} "${updated_content}")
      endif()
    endif()
  endforeach()
endblock()

# Update cmake/autotools/PHPConfig.cmake file.
block()
  cmake_path(
    SET file
    NORMALIZE
    ${PHP_SOURCE_DIR}/cmake/autotools/PHPConfig.cmake
  )

  if("${file}" IN_LIST cmake_files)
    file(READ ${file} content)

    string(
      REGEX REPLACE "(set\\(min_cmake_version[ \t]+)([0-9.]+)(\\))"
      "\\1${version_min}\\3"
      updated_content
      "${content}"
    )

    if(NOT content STREQUAL updated_content)
      message(STATUS "Updating ${file}")

      file(WRITE ${file} "${updated_content}")
    endif()
  endif()
endblock()

# Update CMake presets.
block()
  set(version_regex "(\"version\": )([0-9]+)")
  set(schema_regex "(\"\\$schema\": \")(https://[^\"]+)")

  foreach(file IN LISTS cmake_presets)
    file(READ ${file} content)

    set(updated_content "${content}")

    if(content MATCHES "${version_regex}")
      string(
        REGEX REPLACE "${version_regex}"
        "\\1${presets_version}"
        updated_content
        "${content}"
      )
    endif()

    if(updated_content MATCHES "${schema_regex}")
      string(
        REGEX REPLACE "${schema_regex}"
        "\\1${presets_schema}"
        updated_content
        "${updated_content}"
      )
    endif()

    if(NOT content STREQUAL updated_content)
      message(STATUS "Updating ${file}")

      file(WRITE ${file} "${updated_content}")
    endif()
  endforeach()
endblock()
