#[=============================================================================[
# PHP/Package/RE2C

PHP-related configuration for using `re2c` to simplify setting minimum required
version at one place and use the package with common settings across the build.

## Basic usage

```cmake
# CMakeLists.txt

include(PHP/Package/RE2C)

# Check if re2c is required. PHP released archive from php.net contains
# generated lexer files, so these don't need to be regenerated. When building
# from a Git repository, re2c is required to generate files during the build.
if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/json_scanner.c)
  set_package_properties(RE2C PROPERTIES TYPE REQUIRED)
endif()

if(RE2C_FOUND)
  re2c(...)
endif()
```
#]=============================================================================]

# Minimum required re2c version.
set(RE2C_FIND_VERSION 1.0.3)

option(PHP_RE2C_COMPUTED_GOTOS "Enable computed goto GCC extension with re2c")
mark_as_advanced(PHP_RE2C_COMPUTED_GOTOS)

if(PHP_RE2C_COMPUTED_GOTOS)
  set(RE2C_COMPUTED_GOTOS TRUE)
endif()

# Add --no-debug-info (-i) option to not output line directives.
if(CMAKE_SCRIPT_MODE_FILE)
  set(RE2C_DEFAULT_OPTIONS --no-debug-info)
else()
  set(RE2C_DEFAULT_OPTIONS $<$<CONFIG:Release,MinSizeRel>:--no-debug-info>)
endif()

# Suppress date output in the generated file.
list(APPEND RE2C_DEFAULT_OPTIONS --no-generation-date)

# Set working directory for all re2c invocations.
if(PHP_SOURCE_DIR)
  set(RE2C_WORKING_DIRECTORY ${PHP_SOURCE_DIR})
else()
  set(RE2C_WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
endif()

find_package(RE2C GLOBAL)
