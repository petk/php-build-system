#[=============================================================================[
Specific configuration for HP-UX platform.
#]=============================================================================]

include_guard(GLOBAL)

if(CMAKE_SYSTEM_NAME STREQUAL "HP-UX")
  if(CMAKE_C_COMPILER_ID MATCHES "^(.*Clang|GNU)$")
    target_compile_definitions(
      php_config
      INTERFACE $<$<COMPILE_LANGUAGE:C>:_XOPEN_SOURCE_EXTENDED>
    )
  endif()

  if(CMAKE_CXX_COMPILER_ID MATCHES "^(.*Clang|GNU)$")
    target_compile_definitions(
      php_config
      INTERFACE $<$<COMPILE_LANGUAGE:CXX>:_XOPEN_SOURCE_EXTENDED>
    )
  endif()
endif()
