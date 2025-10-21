#[=============================================================================[
Check linker support for aligning .text segments on huge page boundary.

Usually, the CheckLinkerFlag module is used to check linker flags, however due
to the LLD bug present in versions before 18.1 the run check needs to be
performed. When cross-compiling, the CheckLinkerFlag module is used and the LDD
bug bypassed for versions prior to 18.1.

See also:
- https://github.com/llvm/llvm-project/issues/57618
- https://releases.llvm.org/18.1.0/tools/lld/docs/ReleaseNotes.html
- https://bugs.php.net/79092
- https://github.com/php/php-src/pull/5123
#]=============================================================================]

include(CheckLinkerFlag)
include(CheckSourceRuns)
include(CMakePushCheckState)

message(
  CHECK_START
  "Checking linker support for aligning segments on huge page boundary"
)

if(
  NOT CMAKE_SYSTEM_NAME STREQUAL "Linux"
  OR NOT CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "(i[3456]86|x86_64)"
)
  message(CHECK_FAIL "no")
  return()
endif()

if(CMAKE_CROSSCOMPILING AND NOT CMAKE_CROSSCOMPILING_EMULATOR)
  if(
    CMAKE_C_COMPILER_LINKER_ID STREQUAL "LLD"
    AND CMAKE_C_COMPILER_LINKER_VERSION
    AND CMAKE_C_COMPILER_LINKER_VERSION VERSION_LESS 18.1
  )
    set(PHP_HAS_ALIGNMENT_FLAGS_C FALSE)
  endif()

  if(
    CMAKE_CXX_COMPILER_LINKER_ID STREQUAL "LLD"
    AND CMAKE_CXX_COMPILER_LINKER_VERSION
    AND CMAKE_CXX_COMPILER_LINKER_VERSION VERSION_LESS 18.1
  )
    set(PHP_HAS_ALIGNMENT_FLAGS_CXX FALSE)
  endif()
endif()

# Checks given linker flags and adds them to the php_config interface target.
function(_php_check_segments_alignment lang flags result)
  if(NOT DEFINED ${result})
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_QUIET TRUE)

      if(CMAKE_CROSSCOMPILING AND NOT CMAKE_CROSSCOMPILING_EMULATOR)
        check_linker_flag(${lang} "${flags}" ${result})
      else()
        set(CMAKE_REQUIRED_LINK_OPTIONS ${flags})
        check_source_runs(${lang} [[int main(void) { return 0; }]] ${result})
      endif()
    cmake_pop_check_state()
  endif()

  if(${result})
    target_link_options(
      php_config
      INTERFACE
        $<$<AND:$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>,$<LINK_LANGUAGE:${lang}>>:${flags}>
    )
  endif()
endfunction()

set(flags LINKER:-z,common-page-size=2097152 LINKER:-z,max-page-size=2097152)
_php_check_segments_alignment(C "${flags}" PHP_HAS_ALIGNMENT_FLAGS_C)

if(NOT PHP_HAS_ALIGNMENT_FLAGS_C)
  set(flags LINKER:-z,max-page-size=2097152)
  _php_check_segments_alignment(C "${flags}" PHP_HAS_MAX_PAGE_SIZE_C)
endif()

get_property(enabledLanguages GLOBAL PROPERTY ENABLED_LANGUAGES)

if(CXX IN_LIST enabledLanguages)
  set(flags LINKER:-z,common-page-size=2097152 LINKER:-z,max-page-size=2097152)
  _php_check_segments_alignment(CXX "${flags}" PHP_HAS_ALIGNMENT_FLAGS_CXX)

  if(NOT PHP_HAS_ALIGNMENT_FLAGS_CXX)
    set(flags LINKER:-z,max-page-size=2097152)
    _php_check_segments_alignment(CXX "${flags}" PHP_HAS_MAX_PAGE_SIZE_CXX)
  endif()
endif()

if(
  PHP_HAS_ALIGNMENT_FLAGS_C
  OR PHP_HAS_ALIGNMENT_FLAGS_CXX
  OR PHP_HAS_MAX_PAGE_SIZE_C
  OR PHP_HAS_MAX_PAGE_SIZE_CXX
)
  message(CHECK_PASS "done")
else()
  message(CHECK_FAIL "no")
endif()
