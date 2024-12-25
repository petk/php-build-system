#[=============================================================================[
# PHP/RE2C

Wrapper module for using `re2c`. It simplifies setting minimum required version
at one place and use the package in modular way across the PHP build system.

* `PHP_RE2C_OPTIONAL`

  Set to `TRUE` if `re2c` is optional and generated lexer file is shipped with
  the release archive, for example.

## Basic usage

```cmake
# CMakeLists.txt

# Check if re2c is required. PHP tarball packaged and released at php.net
# already contains generated lexer and parser files. In such cases these don't
# need to be generated again. When building from a Git repository, bison and
# re2c are required to be installed so files can be generated as part of the
# build process.
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/json_scanner.c)
  set(PHP_RE2C_OPTIONAL TRUE)
endif()

# Include the module.
include(PHP/RE2C)

php_re2c(
  php_ext_json_scanner
  json_scanner.re
  ${CMAKE_CURRENT_SOURCE_DIR}/json_scanner.c
  HEADER ${CMAKE_CURRENT_SOURCE_DIR}/php_json_scanner_defs.h
  OPTIONS -bc
  CODEGEN
)
```
#]=============================================================================]

include(FeatureSummary)

# Minimum required re2c version.
set(PHP_RE2C_MIN_VERSION 1.0.3)

option(PHP_RE2C_CGOTO "Enable computed goto GCC extension with re2c")
mark_as_advanced(PHP_RE2C_CGOTO)

if(PHP_RE2C_CGOTO)
  set(RE2C_USE_COMPUTED_GOTOS TRUE)
endif()

# Add --no-debug-info (-i) option to not output line directives.
if(CMAKE_SCRIPT_MODE_FILE)
  set(RE2C_DEFAULT_OPTIONS --no-debug-info)
else()
  set(RE2C_DEFAULT_OPTIONS $<$<CONFIG:Release,MinSizeRel>:--no-debug-info>)
endif()

list(
  APPEND RE2C_DEFAULT_OPTIONS
  --no-generation-date # Suppress date output in the generated file.
)

set(RE2C_NAMESPACE "php_")

find_package(RE2C ${PHP_RE2C_MIN_VERSION} GLOBAL)

block()
  set(type "")
  if(NOT PHP_RE2C_OPTIONAL)
    set(type TYPE REQUIRED)
  endif()

  set_package_properties(RE2C PROPERTIES ${type})
endblock()
