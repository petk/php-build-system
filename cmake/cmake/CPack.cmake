#[=============================================================================[
Initial project CPack configuration.
#]=============================================================================]

if(NOT CPACK_PACKAGE_VERSION)
  set(CPACK_PACKAGE_VERSION ${PHP_VERSION})
endif()

include(CPack)
