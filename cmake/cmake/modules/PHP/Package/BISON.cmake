#[=============================================================================[
# PHP/Package/BISON

PHP-related configuration for using `bison`.

## Basic usage

```cmake
# CMakeLists.txt

include(PHP/Package/BISON)

# Check if bison is required. PHP released archive from php.net contains
# generated parser files, so these don't need to be regenerated. When building
# from a Git repository, bison is required to generate files during the build.
if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/json_parser.tab.c)
  set_package_properties(BISON PROPERTIES TYPE REQUIRED)
endif()

if(BISON_FOUND)
  bison(...)
endif()
```
#]=============================================================================]

# Minimum required bison version.
set(BISON_FIND_VERSION 3.0.0)

# Add Bison --no-lines (-l) option to not generate '#line' directives based on
# this module usage and build type.
if(CMAKE_SCRIPT_MODE_FILE)
  set(BISON_DEFAULT_OPTIONS --no-lines)
else()
  set(BISON_DEFAULT_OPTIONS $<$<CONFIG:Release,MinSizeRel>:--no-lines>)
endif()

# Report all warnings.
list(PREPEND BISON_DEFAULT_OPTIONS -Wall)

# Set working directory for all bison invocations.
if(PHP_SOURCE_DIR)
  set(BISON_WORKING_DIRECTORY ${PHP_SOURCE_DIR})
else()
  set(BISON_WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
endif()

find_package(BISON GLOBAL)
