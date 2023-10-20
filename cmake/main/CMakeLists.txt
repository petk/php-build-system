add_library(php_main STATIC
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

add_library(PHP::main ALIAS php_main)

target_include_directories(
  php_main
  PRIVATE ${CMAKE_SOURCE_DIR}
          ${CMAKE_BINARY_DIR}
  INTERFACE ${CMAKE_SOURCE_DIR}
            ${CMAKE_BINARY_DIR}
            ${CMAKE_CURRENT_SOURCE_DIR}
            ${CMAKE_CURRENT_BINARY_DIR}
            ${CMAKE_CURRENT_SOURCE_DIR}/../TSRM
            ${CMAKE_BINARY_DIR}/ext/date/lib
)

target_compile_definitions(php_main PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

target_link_libraries(php_main PUBLIC zend)

if(EXTRA_LIBS)
  target_link_libraries(php_main PRIVATE ${EXTRA_LIBS})
endif()

target_link_libraries(php_main PUBLIC PHP::configuration)

# Check DTrace.
if(PHP_DTRACE)
  message(STATUS "Checking for DTrace support")

  find_package(DTrace REQUIRED)

  dtrace_target(
    TARGET php_main
    INPUT ${CMAKE_SOURCE_DIR}/Zend/zend_dtrace.d
    HEADER ${CMAKE_BINARY_DIR}/Zend/zend_dtrace_gen.h
    SOURCES ${CMAKE_SOURCE_DIR}/main/main.c
            ${CMAKE_SOURCE_DIR}/Zend/zend_API.c
            ${CMAKE_SOURCE_DIR}/Zend/zend_execute.c
            ${CMAKE_SOURCE_DIR}/Zend/zend_exceptions.c
            ${CMAKE_SOURCE_DIR}/Zend/zend_dtrace.c
            ${CMAKE_SOURCE_DIR}/Zend/zend.c
  )

  message(STATUS "DTrace enabled")
endif()

get_cmake_property(extensions PHP_EXTENSIONS)
foreach(extension IN LISTS extensions)
  message(STATUS "Post-configuration of php_${extension}")

  if(NOT TARGET PHP::${extension})
    add_library(PHP::${extension} ALIAS php_${extension})
  endif()

  target_link_libraries(php_${extension} PRIVATE PHP::configuration)

  # Add configuration compile options before the extension compile options.
  target_compile_options(php_${extension}
    BEFORE PRIVATE
      $<TARGET_PROPERTY:php_configuration,INTERFACE_COMPILE_OPTIONS>
  )

  target_include_directories(
    php_${extension}
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}
            ${CMAKE_CURRENT_BINARY_DIR}
            ${CMAKE_SOURCE_DIR}
            ${CMAKE_BINARY_DIR}
            ${CMAKE_BINARY_DIR}/ext/date/lib
            ${CMAKE_SOURCE_DIR}/TSRM
            ${CMAKE_SOURCE_DIR}/Zend
            ${CMAKE_BINARY_DIR}/Zend
  )

  if(EXTRA_LIBS)
    target_link_libraries(php_${extension} PRIVATE ${EXTRA_LIBS})
  endif()

  get_target_property(extension_type php_${extension} TYPE)

  if(extension_type STREQUAL "SHARED_LIBRARY")
    set_property(TARGET php_${extension} PROPERTY POSITION_INDEPENDENT_CODE TRUE)

    # On macOS, additional linker flags need to be passed for shared libraries.
    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
      set_target_properties(
        php_${extension}
        PROPERTIES LINK_FLAGS "-undefined dynamic_lookup"
      )
    endif()
  else()
    target_link_libraries(php_main PRIVATE PHP::${extension})
  endif()
endforeach()

file(GLOB_RECURSE _main_headers "${PROJECT_SOURCE_DIR}/main/*.h")
install(FILES ${_main_headers} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/main)

file(GLOB_RECURSE _main_streams_headers "${PROJECT_SOURCE_DIR}/main/streams/*.h")
install(FILES ${_main_streams_headers} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/main/streams)
