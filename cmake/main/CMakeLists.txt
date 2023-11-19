add_library(php_main STATIC
  explicit_bzero.c
  fastcgi.c
  fopen_wrappers.c
  internal_functions_cli.c
  internal_functions.c
  main.c
  network.c
  output.c getopt.c
  php_content_types.c
  php_ini_builder.c
  php_ini.c
  php_odbc_utils.c
  php_open_temporary_file.c
  php_scandir.c
  php_syslog.c
  php_ticks.c
  php_variables.c
  reentrancy.c
  rfc1867.c
  safe_bcmp.c
  SAPI.c
  snprintf.c
  spprintf.c
  streams/cast.c
  streams/filter.c
  streams/glob_wrapper.c
  streams/memory.c
  streams/mmap.c
  streams/plain_wrapper.c
  streams/streams.c
  streams/transports.c
  streams/userspace.c
  streams/xp_socket.c
  strlcat.c
  strlcpy.c
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

target_link_libraries(php_main PUBLIC Zend::Zend)

target_link_libraries(php_main PUBLIC PHP::configuration)

# Add DTrace.
if(PHP_DTRACE)
  message(CHECK_START "Checking for DTrace support")

  find_package(DTrace)
  set_package_properties(DTrace PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the DTrace support."
  )

  if(DTrace_FOUND)
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

    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
endif()

# Add Dmalloc.
if(PHP_DMALLOC)
  message(CHECK_START "Checking for Dmalloc support")

  find_package(Dmalloc)
  set_package_properties(Dmalloc PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to use Dmalloc memory debugger."
  )

  target_compile_definitions(
    php_configuration
    INTERFACE $<$<COMPILE_LANGUAGE:ASM,C,CXX>:MALLOC_FUNC_CHECK>
  )

  target_link_libraries(php_main PRIVATE Dmalloc::Dmalloc)

  if(Dmalloc_FOUND)
    message(CHECK_PASS "yes")
    set(HAVE_DMALLOC 1 CACHE INTERNAL "Whether the Dmalloc library is available")
  else()
    message(CHECK_FAIL "no")
  endif()
endif()

get_cmake_property(extensions PHP_EXTENSIONS)
foreach(extension IN LISTS extensions)
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
