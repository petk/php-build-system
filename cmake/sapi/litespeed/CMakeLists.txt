# SAPI is only for *nix systems.
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

include(FeatureSummary)

option(SAPI_LITESPEED "Enable the LiteSpeed SAPI module" OFF)

add_feature_info(
  "sapi/litespeed"
  SAPI_LITESPEED
  "LiteSpeed SAPI module"
)

message(CHECK_START "Checking litespeed SAPI")
if(SAPI_LITESPEED)
  message(CHECK_PASS "enabled")
else()
  message(CHECK_FAIL "disabled")
  return()
endif()

add_executable(php_litespeed
  lsapi_main.c
  lsapilib.c
)

target_link_libraries(php_litespeed PRIVATE PHP::main)

set_target_properties(
  php_litespeed
  PROPERTIES
    OUTPUT_NAME lsphp
    # TODO: Check if there's a better solution here.
    ENABLE_EXPORTS TRUE
)

# TODO: Add prefix and suffix to installed executable file.
install(
  TARGETS php_litespeed
  RUNTIME
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)
