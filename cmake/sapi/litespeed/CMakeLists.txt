option(SAPI_LITESPEED "Whether to build PHP as litespeed SAPI module" OFF)

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

install(TARGETS php_litespeed DESTINATION ${CMAKE_INSTALL_BINDIR})
