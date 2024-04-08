#[=============================================================================[
Specific configuration for HP-UX platform.
]=============================================================================]#

include_guard(GLOBAL)

if(CMAKE_SYSTEM_NAME STREQUAL "HP-UX")
  target_compile_definitions(
    php_configuration
    INTERFACE
      $<$<COMPILE_LANG_AND_ID:ASM,GNU>:_XOPEN_SOURCE_EXTENDED>
      $<$<COMPILE_LANG_AND_ID:C,GNU>:_XOPEN_SOURCE_EXTENDED>
      $<$<COMPILE_LANG_AND_ID:CXX,GNU>:_XOPEN_SOURCE_EXTENDED>
  )
endif()
