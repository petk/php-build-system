option(SAPI_LITESPEED "Enable the LiteSpeed SAPI module" OFF)

message(CHECK_START "Checking whether to build litespeed SAPI")
if(SAPI_LITESPEED)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

if(NOT SAPI_LITESPEED)
  return()
endif()

add_executable(php_litespeed
  lsapi_main.c
  lsapilib.c
)

set_target_properties(php_litespeed PROPERTIES OUTPUT_NAME lsphp)

target_link_libraries(php_litespeed PRIVATE PHP::main)

# TODO: Check if there's a better solution here.
set_target_properties(php_litespeed PROPERTIES ENABLE_EXPORTS TRUE)

# TODO: Add prefix and suffix to installed executable file.
install(
  TARGETS php_litespeed
  RUNTIME
    DESTINATION "${CMAKE_INSTALL_BINDIR}"
)
