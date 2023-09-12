option(SAPI_LITESPEED "Whether to build PHP as litespeed SAPI module" OFF)

if(NOT SAPI_LITESPEED)
  return()
endif()

add_executable(lsphp
  lsapi_main.c
  lsapilib.c
)

target_link_libraries(lsphp PRIVATE main)

if(EXTRA_LIBS)
  target_link_libraries(lsphp PRIVATE ${EXTRA_LIBS})
endif()

if(EXTRA_DEFINITIONS)
  target_compile_definitions(lsphp PRIVATE ${EXTRA_DEFINITIONS})
endif()

# TODO: Check if there's a better solution here.
set_target_properties(lsphp PROPERTIES ENABLE_EXPORTS TRUE)

install(TARGETS lsphp DESTINATION ${CMAKE_INSTALL_BINDIR})
