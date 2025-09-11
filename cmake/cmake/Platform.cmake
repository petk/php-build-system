#[=============================================================================[
Platform-specific configuration.
#]=============================================================================]

include_guard(GLOBAL)

# Platform-specific configuration. When cross-compiling, the host and target can
# be different values with different configurations.
if(NOT CMAKE_HOST_SYSTEM_NAME EQUAL CMAKE_SYSTEM_NAME)
  include(
    ${CMAKE_CURRENT_LIST_DIR}/platforms/${CMAKE_HOST_SYSTEM_NAME}.cmake
    OPTIONAL
  )
endif()
include(${CMAKE_CURRENT_LIST_DIR}/platforms/${CMAKE_SYSTEM_NAME}.cmake OPTIONAL)
