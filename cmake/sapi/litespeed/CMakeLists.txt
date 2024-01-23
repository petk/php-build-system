# SAPI is only for *nix systems.
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

option(SAPI_LITESPEED "Enable the LiteSpeed SAPI module" OFF)

message(CHECK_START "Checking whether to build litespeed SAPI")
if(SAPI_LITESPEED)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
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
    DESTINATION "${CMAKE_INSTALL_BINDIR}"
)
