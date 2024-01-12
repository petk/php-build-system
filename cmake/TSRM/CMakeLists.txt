add_library(php_tsrm STATIC)

target_sources(php_tsrm PRIVATE
  $<$<PLATFORM_ID:Windows>:tsrm_win32.c>
  TSRM.c
)

add_library(PHP::TSRM ALIAS php_tsrm)

target_link_libraries(php_tsrm PRIVATE PHP::configuration)

target_include_directories(php_tsrm INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}")

target_compile_definitions(php_tsrm PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

# Check POSIX Threads.
function(_php_tsrm_thread_safety)
  message(CHECK_START "Checking whether to enable thread safety")

  if(NOT PHP_THREAD_SAFETY)
    message(CHECK_FAIL "no")
    return()
  endif()

  set(THREADS_PREFER_PTHREAD_FLAG TRUE)
  find_package(Threads)
  set_package_properties(Threads PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable PHP thread safety."
  )

  if(Threads_FOUND)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "failed")
  endif()

  target_link_libraries(php_configuration INTERFACE Threads::Threads)

  if(CMAKE_HOST_SYSTEM_NAME STREQUAL "SunOS")
    target_compile_definitions(
      php_configuration
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C,CXX>:_POSIX_PTHREAD_SEMANTICS;_REENTRANT>
    )
  elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "FreeBSD")
    target_compile_definitions(
      php_configuration
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C,CXX>:_REENTRANT;_THREAD_SAFE>
    )
  elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
    target_compile_definitions(
      php_configuration
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C,CXX>:_REENTRANT>
    )
  elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "AIX")
    target_compile_definitions(
      php_configuration
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C,CXX>:_THREAD_SAFE>
    )
  elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "HP-UX")
    target_compile_definitions(
      php_configuration
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C,CXX>:_REENTRANT>
    )
  elseif(CMAKE_HOST_SYSTEM_NAME MATCHES "^(SCO_SV|UNIX_SV|UnixWare)$")
    target_compile_definitions(
      php_configuration
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C,CXX>:_REENTRANT>
    )
  endif()
endfunction()

# Run at the end of the configuration.
cmake_language(
  DEFER
    DIRECTORY ${PROJECT_SOURCE_DIR}
  CALL _php_tsrm_thread_safety
)

target_sources(
  php_tsrm
  PUBLIC FILE_SET HEADERS
    BASE_DIRS "${PROJECT_SOURCE_DIR}"
    FILES
      $<$<PLATFORM_ID:Windows>:tsrm_win32.h>
      TSRM.h
)

install(
  TARGETS php_tsrm
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET HEADERS
)
