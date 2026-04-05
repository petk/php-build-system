#[=============================================================================[
This is an internal module and is not intended for direct usage inside projects.
It provides common PHP configuration options when building php-src and when
building PHP extensions as self-contained.

Load this module in a CMake project with:

  include(PHP/Internal/Configuration)

This module provides the following cache variables:

* PHP_CCACHE
* PHP_TESTING
#]=============================================================================]

include_guard(GLOBAL)

option(PHP_CCACHE "Use ccache if available on the system" ON)
mark_as_advanced(PHP_CCACHE)

option(
  PHP_TESTING
  "Whether to enable and configure tests"
  ${PROJECT_IS_TOP_LEVEL}
)
mark_as_advanced(PHP_TESTING)

# Set base directory for ExternalProject CMake module.
set_directory_properties(
  PROPERTIES EP_BASE ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/PHP/ExternalProject
)

define_property(
  TARGET
  PROPERTY PHP_CLI
  BRIEF_DOCS "Whether the PHP SAPI or extension is CLI-based"
)

define_property(
  TARGET
  PROPERTY PHP_ZEND_EXTENSION
  BRIEF_DOCS "Whether the PHP extension target is Zend extension"
)

define_property(
  TARGET
  PROPERTY PHP_REQUIRED_EXTENSIONS
  BRIEF_DOCS "A list of required PHP extensions"
)

define_property(
  TARGET
  PROPERTY PHP_OPTIONAL_EXTENSIONS
  BRIEF_DOCS "A list of optional PHP extensions"
)

define_property(
  TARGET
  PROPERTY PHP_RECOMMENDED_EXTENSIONS
  BRIEF_DOCS "A list of optional recommended PHP extensions"
)

define_property(
  TARGET
  PROPERTY PHP_CONFLICTING_EXTENSIONS
  BRIEF_DOCS "A list of conflicting PHP extensions"
)
