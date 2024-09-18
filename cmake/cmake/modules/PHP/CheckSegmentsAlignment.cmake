#[=============================================================================[
Check linker support for aligning segments on huge page boundary.
#]=============================================================================]

include_guard(GLOBAL)

include(CheckLinkerFlag)
include(CheckSourceRuns)
include(CMakePushCheckState)

message(
  CHECK_START
  "Checking linker support for aligning segments on huge page boundary"
)

if(
  NOT CMAKE_SYSTEM_NAME STREQUAL "Linux"
  AND NOT CMAKE_SYSTEM_PROCESSOR MATCHES "^(i[3456]86.*|x86_64)$"
)
  message(CHECK_FAIL "no")
  return()
endif()

check_linker_flag(
  C
  "LINKER:-z,common-page-size=2097152;LINKER:-z,max-page-size=2097152"
  _HAVE_ALIGNMENT_FLAGS_C
)

if(_HAVE_ALIGNMENT_FLAGS_C)
  cmake_push_check_state(RESET)
    set(
      CMAKE_REQUIRED_LINK_OPTIONS
      LINKER:-z,common-page-size=2097152
      LINKER:-z,max-page-size=2097152
    )
    check_source_runs(
      C
      [[int main(void) { return 0; }]]
      PHP_HAVE_ALIGNMENT_FLAGS_C
    )
  cmake_pop_check_state()

  if(PHP_HAVE_ALIGNMENT_FLAGS_C)
    target_link_options(
      php_configuration
      INTERFACE
        $<$<AND:$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>,$<LINK_LANGUAGE:ASM,C>>:LINKER:-z,common-page-size=2097152;LINKER:-z,max-page-size=2097152>
    )
  endif()
else()
  check_linker_flag(
    C
    "LINKER:-z,max-page-size=2097152"
    _HAVE_ZMAX_PAGE_SIZE_C
  )

  if(_HAVE_ZMAX_PAGE_SIZE_C)
    cmake_push_check_state(RESET)
      set(
        CMAKE_REQUIRED_LINK_OPTIONS
        LINKER:-z,max-page-size=2097152
      )
      check_source_runs(
        C
        [[int main(void) { return 0; }]]
        PHP_HAVE_ZMAX_PAGE_SIZE_C
      )
    cmake_pop_check_state()

    if(PHP_HAVE_ZMAX_PAGE_SIZE_C)
      target_link_options(
        php_configuration
        INTERFACE
          $<$<AND:$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>,$<LINK_LANGUAGE:ASM,C>>:LINKER:-z,max-page-size=2097152>
      )
    endif()
  endif()
endif()

check_linker_flag(
  CXX
  "LINKER:-z,common-page-size=2097152;LINKER:-z,max-page-size=2097152"
  _HAVE_ALIGNMENT_FLAGS_CXX
)

if(_HAVE_ALIGNMENT_FLAGS_CXX)
  cmake_push_check_state(RESET)
    set(
      CMAKE_REQUIRED_LINK_OPTIONS
      LINKER:-z,common-page-size=2097152
      LINKER:-z,max-page-size=2097152
    )
    check_source_runs(
      CXX
      [[int main(void) { return 0; }]]
      PHP_HAVE_ALIGNMENT_FLAGS_CXX
    )
  cmake_pop_check_state()

  if(PHP_HAVE_ALIGNMENT_FLAGS_CXX)
    target_link_options(
      php_configuration
      INTERFACE
        $<$<AND:$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>,$<LINK_LANGUAGE:CXX>>:LINKER:-z,common-page-size=2097152;LINKER:-z,max-page-size=2097152;>
    )
  endif()
else()
  check_linker_flag(
    CXX
    "LINKER:-z,max-page-size=2097152"
    _HAVE_ZMAX_PAGE_SIZE_CXX
  )

  if(_HAVE_ZMAX_PAGE_SIZE_CXX)
    cmake_push_check_state(RESET)
      set(
        CMAKE_REQUIRED_LINK_OPTIONS
        LINKER:-z,max-page-size=2097152
      )
      check_source_runs(
        CXX
        [[int main(void) { return 0; }]]
        PHP_HAVE_ZMAX_PAGE_SIZE_CXX
      )
    cmake_pop_check_state()

    if(PHP_HAVE_ZMAX_PAGE_SIZE_CXX)
      target_link_options(
        php_configuration
        INTERFACE
          $<$<AND:$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>,$<LINK_LANGUAGE:CXX>>:LINKER:-z,max-page-size=2097152>
      )
    endif()
  endif()
endif()

if(
  HAVE_ALIGNMENT_FLAGS_C
  OR HAVE_ALIGNMENT_FLAGS_CXX
  OR HAVE_ZMAX_PAGE_SIZE_C
  OR HAVE_ZMAX_PAGE_SIZE_CXX
)
  message(CHECK_PASS "done")
else()
  message(CHECK_FAIL "no")
endif()
