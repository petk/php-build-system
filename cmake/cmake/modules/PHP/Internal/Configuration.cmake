#[=============================================================================[
This is an internal module and is not intended for direct usage inside projects.
It provides common PHP configuration options when building php-src and when
building PHP extensions as standalone.

Load this module in a PHP CMake project or inside a module with:

  include(PHP/Internal/Configuration)

This module provides the following cache variables:

* PHP_ENABLE_TESTING
#]=============================================================================]

include_guard(GLOBAL)

option(
  PHP_ENABLE_TESTING
  "Whether to enable and configure tests"
  ${PROJECT_IS_TOP_LEVEL}
)
mark_as_advanced(PHP_ENABLE_TESTING)
