include(CheckCompilerFlag)
include(CheckSourceCompiles)
include(CheckSourceRuns)
include(CMakePushCheckState)
include(FeatureSummary)

option(
  EXT_PCRE_EXTERNAL
  "Use external (system) PCRE library in ext/pcre instead of the bundled library"
  OFF
)

add_feature_info(
  "ext/pcre external library"
  EXT_PCRE_EXTERNAL
  "Using system PCRE library instead of the bundled library."
)

option(EXT_PCRE_JIT "Enable PCRE JIT functionality" ON)

mark_as_advanced(EXT_PCRE_EXTERNAL EXT_PCRE_JIT)

add_library(php_pcre STATIC)

target_sources(
  php_pcre
  PRIVATE
    php_pcre.c
    php_pcre.def
  PUBLIC
    FILE_SET HEADERS
      BASE_DIRS "${PHP_SOURCE_DIR}"
      FILES
        php_pcre.h
)

target_compile_definitions(php_pcre PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

set(
  PCRE2_CODE_UNIT_WIDTH 8
  CACHE INTERNAL "Number of bits in non-UTF mode for PCRE library."
)

if(EXT_PCRE_EXTERNAL)
  find_package(PCRE 10.30)
  set_package_properties(
    PCRE
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to use external PCRE library in the pcre extension."
  )

  target_link_libraries(php_pcre PRIVATE PCRE::PCRE)

  if(TARGET PCRE::PCRE AND EXT_PCRE_JIT)
    message(CHECK_START "Checking for JIT support in PCRE2")

    if(CMAKE_CROSSCOMPILING)
      if(
        CMAKE_SYSTEM_PROCESSOR
        MATCHES
        "^(arm.*|i[34567]86|x86_64|amd64|mips.*|powerpc.*|sparc.*|X86|AMD64|ARM64)$"
      )
        set(
          HAVE_PCRE_JIT_SUPPORT 1
          CACHE INTERNAL "Whether to enable the PCRE JIT support"
        )
      endif()
    else()
      cmake_push_check_state(RESET)
        set(CMAKE_REQUIRED_LIBRARIES PCRE::PCRE)
        # Before including pcre2.h, the PCRE2_CODE_UNIT_WIDTH must be set.
        set(
          CMAKE_REQUIRED_DEFINITIONS
          -DPCRE2_CODE_UNIT_WIDTH=${PCRE2_CODE_UNIT_WIDTH}
        )
        set(CMAKE_REQUIRED_QUIET TRUE)

        check_source_runs(C "
          #include <pcre2.h>
          #include <stdlib.h>

          int main(void) {
            uint32_t have_jit;
            pcre2_config_8(PCRE2_CONFIG_JIT, &have_jit);

            return !have_jit;
          }
        " HAVE_PCRE_JIT_SUPPORT)
      cmake_pop_check_state()
    endif()

    if(HAVE_PCRE_JIT_SUPPORT)
      message(CHECK_PASS "yes")
    else()
      message(CHECK_FAIL "no")
    endif()
  endif()
else()
  message(STATUS "Using bundled PCRE library")

  file(GLOB _php_pcre_headers ${CMAKE_CURRENT_SOURCE_DIR}/pcre2lib/*.h)

  target_sources(
    php_pcre
    PRIVATE
      pcre2lib/pcre2_auto_possess.c
      pcre2lib/pcre2_chartables.c
      pcre2lib/pcre2_chkdint.c
      pcre2lib/pcre2_compile.c
      pcre2lib/pcre2_config.c
      pcre2lib/pcre2_context.c
      pcre2lib/pcre2_convert.c
      pcre2lib/pcre2_dfa_match.c
      pcre2lib/pcre2_error.c
      pcre2lib/pcre2_extuni.c
      pcre2lib/pcre2_find_bracket.c
      pcre2lib/pcre2_jit_compile.c
      pcre2lib/pcre2_maketables.c
      pcre2lib/pcre2_match_data.c
      pcre2lib/pcre2_match.c
      pcre2lib/pcre2_newline.c
      pcre2lib/pcre2_ord2utf.c
      pcre2lib/pcre2_pattern_info.c
      pcre2lib/pcre2_script_run.c
      pcre2lib/pcre2_serialize.c
      pcre2lib/pcre2_string_utils.c
      pcre2lib/pcre2_study.c
      pcre2lib/pcre2_substitute.c
      pcre2lib/pcre2_substring.c
      pcre2lib/pcre2_tables.c
      pcre2lib/pcre2_ucd.c
      pcre2lib/pcre2_valid_utf.c
      pcre2lib/pcre2_xclass.c
    PUBLIC
      FILE_SET HEADERS
        BASE_DIRS "${PHP_SOURCE_DIR}"
        FILES
          ${_php_pcre_headers}
  )

  check_compiler_flag(C -Wno-implicit-fallthrough _HAVE_WNO_IMPLICIT_FALLTHROUGH_C)
  if(_HAVE_WNO_IMPLICIT_FALLTHROUGH_C)
    target_compile_options(php_pcre PRIVATE -Wno-implicit-fallthrough)
  endif()

  if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(PCRE2_STATIC 1 CACHE INTERNAL "Whether a static PCRE library is linked")
  endif()

  target_compile_definitions(
    php_pcre
    PRIVATE
      # PCRE2 library uses C99 memmove() function conditionally in some files.
      HAVE_MEMMOVE
      HAVE_CONFIG_H
  )

  set(
    HAVE_BUNDLED_PCRE 1
    CACHE INTERNAL "Whether the bundled PCRE library is used"
  )

  message(CHECK_START "Checking whether to enable PCRE JIT functionality")

  if(EXT_PCRE_JIT)
    set(
      HAVE_PCRE_JIT_SUPPORT 1
      CACHE INTERNAL "Whether to enable the PCRE JIT support"
    )

    message(CHECK_PASS "yes")

    message(CHECK_START "Checking whether Intel CET is enabled")
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_QUIET TRUE)
      check_source_compiles(C "
        #ifndef __CET__
        # error CET is not enabled
        #endif
        int main(void) { return 0; }"
        _HAVE_PCRE2_INTEL_CET
      )
    cmake_pop_check_state()
    if(_HAVE_PCRE2_INTEL_CET)
      message(CHECK_PASS "yes")
      check_compiler_flag(C -mshstk _HAVE_MSHSTK_C)
      if(_HAVE_MSHSTK_C)
        target_compile_options(php_pcre PRIVATE -mshstk)
      endif()
    else()
      message(CHECK_FAIL "no")
    endif()
  else()
    message(CHECK_FAIL "no")
  endif()

  # Enable pcre Valgrind support only in Debug build (it affects performance).
  if(PHP_VALGRIND)
    target_compile_definitions(
      php_pcre
      PRIVATE
        $<$<CONFIG:Debug,DebugAssertions>:HAVE_PCRE_VALGRIND_SUPPORT=1>
    )
  endif()
endif()

add_feature_info(
  "ext/pcre JIT"
  HAVE_PCRE_JIT_SUPPORT
  "PCRE JIT support"
)

install(
  TARGETS php_pcre
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET HEADERS
)
