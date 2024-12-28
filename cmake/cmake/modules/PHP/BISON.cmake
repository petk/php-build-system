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

if(BISON_FOUND)
  bison(...)
endif()
```
#]=============================================================================]

include(FeatureSummary)

# Minimum required bison version.
set(PHP_BISON_MIN_VERSION 3.0.0)

# Add Bison --no-lines (-l) option to not generate '#line' directives based on
# this module usage and build type.
if(CMAKE_SCRIPT_MODE_FILE)
  set(BISON_DEFAULT_OPTIONS --no-lines)
else()
  set(BISON_DEFAULT_OPTIONS $<$<CONFIG:Release,MinSizeRel>:--no-lines>)
endif()

# Report all warnings.
list(PREPEND BISON_DEFAULT_OPTIONS -Wall)

find_package(BISON ${PHP_BISON_MIN_VERSION} GLOBAL)

block()
  set(type "")
  if(NOT PHP_BISON_OPTIONAL)
    set(type TYPE REQUIRED)
  endif()

  set_package_properties(BISON PROPERTIES ${type})
endblock()
