option(SAPI_LITESPEED "Whether to build PHP as litespeed SAPI module" OFF)

if(NOT SAPI_LITESPEED)
  return()
endif()

add_executable(lsphp
  lsapi_main.c
  lsapilib.c
)

target_link_libraries(lsphp PUBLIC main)
target_link_libraries(lsphp PUBLIC TSRM)
target_link_libraries(lsphp PUBLIC Zend)

foreach(item IN LISTS PHP_EXTENSIONS)
  message(STATUS "Linking ${item}")
  target_link_libraries(lsphp PUBLIC ext_${item})
endforeach()

if(EXTRA_LIBS)
  target_link_libraries(lsphp PUBLIC ${EXTRA_LIBS})
endif()

if(EXTRA_DEFINITIONS)
  target_compile_definitions(lsphp PUBLIC ${EXTRA_DEFINITIONS})
endif()

install(TARGETS lsphp DESTINATION ${CMAKE_INSTALL_BINDIR})
