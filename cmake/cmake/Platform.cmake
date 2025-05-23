#[=============================================================================[
Platform-specific configuration.
#]=============================================================================]

include_guard(GLOBAL)

# Check unused linked libraries on executable and shared/module library targets.
include(PHP/LinkWhatYouUse)

# Enable C and POSIX extensions.
include(PHP/SystemExtensions)

# The above system extensions will be defined in the main/php_config.h. The
# php-src code at the time of writing doesn't include C headers in order to
# utilize them. The main/php_config.h should be the first inclusion before
# including any system header. Perhaps in php.h file. Until then, the compile
# definitions also need to be added when compiling and using PHP API. Mainly the
# _GNU_SOURCE.
target_link_libraries(php_config INTERFACE PHP::SystemExtensions)

# Define GNU standard installation directories.
include(GNUInstallDirs)

# Detect C standard library implementation.
include(PHP/StandardLibrary)

# Platform-specific configuration. When cross-compiling, the host and target can
# be different values with different configurations.
if(NOT CMAKE_HOST_SYSTEM_NAME EQUAL CMAKE_SYSTEM_NAME)
  include(
    ${CMAKE_CURRENT_LIST_DIR}/platforms/${CMAKE_HOST_SYSTEM_NAME}.cmake
    OPTIONAL
  )
endif()
include(${CMAKE_CURRENT_LIST_DIR}/platforms/${CMAKE_SYSTEM_NAME}.cmake OPTIONAL)
