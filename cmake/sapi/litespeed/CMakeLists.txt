option(litespeed "Whether to use the PHP LiteSpeed SAPI module" OFF)

if(NOT litespeed)
  return()
endif()

add_executable(lsphp
  lsapi_main.c
  lsapilib.c
)
