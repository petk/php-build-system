add_library(main STATIC
  main.c
  snprintf.c
  spprintf.c
  fopen_wrappers.c
  php_scandir.c
  php_ini_builder.c
  php_ini.c
  SAPI.c
  rfc1867.c
  php_content_types.c
  strlcpy.c
  strlcat.c
  explicit_bzero.c
  reentrancy.c
  php_variables.c
  php_ticks.c
  network.c
  php_open_temporary_file.c
  php_odbc_utils.c
  safe_bcmp.c
  output.c getopt.c
  php_syslog.c
  fastcgi.c
  internal_functions.c
  internal_functions_cli.c
  streams/streams.c
  streams/cast.c
  streams/memory.c
  streams/filter.c
  streams/plain_wrapper.c
  streams/userspace.c
  streams/transports.c
  streams/xp_socket.c
  streams/mmap.c
  streams/glob_wrapper.c
)

target_include_directories(
  main
  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}
          ${CMAKE_CURRENT_SOURCE_DIR}/../Zend
  INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}
)

target_compile_definitions(main PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

if(HAVE_DTRACE)
  add_dependencies(main zend_dtrace)
endif()

target_link_libraries(main PRIVATE Zend)

if(EXTRA_LIBS)
  target_link_libraries(main PRIVATE ${EXTRA_LIBS})
endif()

if(EXTRA_DEFINITIONS)
  target_compile_definitions(main PRIVATE ${EXTRA_DEFINITIONS})
endif()

foreach(item IN LISTS PHP_EXTENSIONS_STATIC)
  message(STATUS "Linking ${item}")
  target_include_directories(
    ext_${item}
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}
            ${CMAKE_SOURCE_DIR}
            ${CMAKE_SOURCE_DIR}/TSRM
            ${CMAKE_SOURCE_DIR}/Zend
  )
  target_link_libraries(main PRIVATE ext_${item})

  if(EXTRA_LIBS)
    target_link_libraries(ext_${item} PRIVATE ${EXTRA_LIBS})
  endif()

  if(EXTRA_DEFINITIONS)
    target_compile_definitions(ext_${item} PRIVATE ${EXTRA_DEFINITIONS})
  endif()
endforeach()

foreach(item IN LISTS PHP_EXTENSIONS_SHARED)
  target_include_directories(
    ext_${item}
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}
            ${CMAKE_SOURCE_DIR}
            ${CMAKE_SOURCE_DIR}/main
            ${CMAKE_SOURCE_DIR}/TSRM
            ${CMAKE_CURRENT_SOURCE_DIR}/../Zend
  )

  set_property(TARGET ext_${item} PROPERTY POSITION_INDEPENDENT_CODE TRUE)

  if(EXTRA_LIBS)
    target_link_libraries(ext_${item} PRIVATE ${EXTRA_LIBS})
  endif()

  if(EXTRA_DEFINITIONS)
    target_compile_definitions(ext_${item} PRIVATE ${EXTRA_DEFINITIONS})
  endif()
endforeach()

file(GLOB_RECURSE _main_headers "${PROJECT_SOURCE_DIR}/main/*.h")
install(FILES ${_main_headers} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/main)

file(GLOB_RECURSE _main_streams_headers "${PROJECT_SOURCE_DIR}/main/streams/*.h")
install(FILES ${_main_streams_headers} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/main/streams)
