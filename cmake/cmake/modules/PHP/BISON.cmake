#[=============================================================================[
# PHP/BISON

Wrapper module for using `bison`.

* `PHP_BISON_OPTIONAL`

  Set to `TRUE` if `bison` is optional and generated parser file is shipped with
  the release archive, for example.

## Basic usage

```cmake
# CMakeLists.txt

# Check if bison is required. PHP tarball packaged and released at php.net
# already contains generated lexer and parser files. In such cases these don't
# need to be generated again. When building from a Git repository, bison and
# re2c are required to be installed so files can be generated as part of the
# build process.
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/json_parser.tab.c)
  set(PHP_BISON_OPTIONAL TRUE)
endif()
include(PHP/BISON)

php_bison(
  php_ext_json_parser
  json_parser.y
  ${CMAKE_CURRENT_SOURCE_DIR}/json_parser.tab.c
  COMPILE_FLAGS "${PHP_BISON_DEFAULT_OPTIONS}"
  VERBOSE REPORT_FILE json_parser.tab.output
  DEFINES_FILE ${CMAKE_CURRENT_SOURCE_DIR}/json_parser.tab.h
)
```
#]=============================================================================]

include(FeatureSummary)

# Minimum required bison version.
set(PHP_BISON_MIN_VERSION 3.0.0)

# Add Bison options based on the build type.
if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.32)
  # See: https://gitlab.kitware.com/cmake/cmake/-/merge_requests/9921
  set(PHP_BISON_DEFAULT_OPTIONS "-Wall $<$<CONFIG:Release,MinSizeRel>:-l>")
else()
  set(PHP_BISON_DEFAULT_OPTIONS "$<IF:$<CONFIG:Release,MinSizeRel>,-lWall,-Wall>")
endif()

if(CMAKE_SCRIPT_MODE_FILE)
  set(PHP_BISON_DEFAULT_OPTIONS "-l -Wall")
endif()

find_package(BISON ${PHP_BISON_MIN_VERSION} GLOBAL)

block()
  set(type "")
  if(NOT PHP_BISON_OPTIONAL)
    set(type TYPE REQUIRED)
  endif()

  set_package_properties(
    BISON
    PROPERTIES
      ${type}
      PURPOSE "Necessary to generate PHP parser files."
  )
endblock()

macro(php_bison)
  if(CMAKE_SCRIPT_MODE_FILE)
    bison_execute(${ARGN})
  else()
    bison_target(${ARGN})
  endif()
endmacro()
