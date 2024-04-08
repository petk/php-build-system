#[=============================================================================[
Specific configuration for SunOS patform (Solaris, illumos, etc.).
]=============================================================================]#

include_guard(GLOBAL)

if(CMAKE_SYSTEM_NAME STREQUAL "SunOS")
  target_compile_definitions(
    php_configuration
    INTERFACE
      $<$<COMPILE_LANGUAGE:ASM,C,CXX>:_POSIX_PTHREAD_SEMANTICS>
  )
endif()
