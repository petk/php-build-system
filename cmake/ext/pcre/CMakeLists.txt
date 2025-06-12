#[=============================================================================[
# The pcre extension

Configure the `pcre` extension.

This extension provides support for (Perl-compatible) regular expressions and is
always enabled.

## PHP_EXT_PCRE_EXTERNAL

* Default: `OFF`
* Values: `ON|OFF`

Use external (system) PCRE library in pcre extension instead of the bundled PCRE
library that comes with PHP sources.

## PHP_EXT_PCRE_JIT

* Default: `ON`
* Values: `ON|OFF`

Enable PCRE JIT (just-in-time) compilation. When using the external PCRE
library, JIT support also depends on the target processor architecture and
whether the PCRE library has it enabled.
#]=============================================================================]

cmake_minimum_required(VERSION 3.27...4.0)

project(
  PhpExtensionPcre
  LANGUAGES C
)

include(CheckSourceRuns)
include(CheckSymbolExists)
include(CMakePushCheckState)
include(FeatureSummary)
include(PHP/CheckCompilerFlag)

add_feature_info(
  "ext/pcre"
  TRUE
  "Perl-compatible regular expressions"
)

option(
  PHP_EXT_PCRE_EXTERNAL
  "Use external (system) PCRE library in pcre extension instead of the bundled\
  PCRE library that comes with PHP sources"
)
mark_as_advanced(PHP_EXT_PCRE_EXTERNAL)
add_feature_info(
  "ext/pcre external PCRE"
  PHP_EXT_PCRE_EXTERNAL
  "system PCRE library instead of bundled"
)

option(
  PHP_EXT_PCRE_JIT
  "Enable PCRE JIT (just-in-time) compilation. When using the external PCRE\
  library, JIT support also depends on the target processor architecture and\
  whether the PCRE library has it enabled."
  ON
)
mark_as_advanced(PHP_EXT_PCRE_JIT)

add_library(php_ext_pcre OBJECT)

target_sources(
  php_ext_pcre
  PRIVATE
    php_pcre.c
    php_pcre.def
    php_pcre.stub.php
  PUBLIC
    FILE_SET HEADERS
      FILES
        php_pcre.h
)

# TODO: Fix this better for OBJECT libraries, which can't handle .def files.
set_source_files_properties(php_pcre.def PROPERTIES HEADER_FILE_ONLY TRUE)

target_compile_definitions(php_ext_pcre PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

set(PCRE2_CODE_UNIT_WIDTH 8)

if(PHP_EXT_PCRE_EXTERNAL)
  find_package(PCRE 10.30)
  set_package_properties(
    PCRE
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to use external PCRE library in the pcre extension."
  )

  target_link_libraries(php_ext_pcre PRIVATE PCRE::PCRE)

  if(TARGET PCRE::PCRE AND PHP_EXT_PCRE_JIT)
    message(CHECK_START "Checking for PCRE JIT support")

    if(
      NOT DEFINED HAVE_PCRE_JIT_SUPPORT_EXITCODE
      AND CMAKE_CROSSCOMPILING
      AND NOT CMAKE_CROSSCOMPILING_EMULATOR
      AND CMAKE_SYSTEM_PROCESSOR MATCHES
        "^(arm.*|i[34567]86|x86_64|amd64|mips.*|powerpc.*|sparc.*|X86|AMD64|ARM64)$"
    )
      set(HAVE_PCRE_JIT_SUPPORT_EXITCODE 0)
    endif()

    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LIBRARIES PCRE::PCRE)
      # Before including pcre2.h, the PCRE2_CODE_UNIT_WIDTH must be set.
      set(
        CMAKE_REQUIRED_DEFINITIONS
        -DPCRE2_CODE_UNIT_WIDTH=${PCRE2_CODE_UNIT_WIDTH}
      )
      set(CMAKE_REQUIRED_QUIET TRUE)

      check_source_runs(C [[
        #include <pcre2.h>
        #include <stdlib.h>

        int main(void)
        {
          uint32_t have_jit;
          pcre2_config_8(PCRE2_CONFIG_JIT, &have_jit);

          return !have_jit;
        }
      ]] HAVE_PCRE_JIT_SUPPORT)
    cmake_pop_check_state()

    if(HAVE_PCRE_JIT_SUPPORT)
      message(CHECK_PASS "yes")
    else()
      message(CHECK_FAIL "no")
    endif()
  endif()
else()
  message(STATUS "Using bundled PCRE library")

  target_sources(
    php_ext_pcre
    PRIVATE
      pcre2lib/pcre2_auto_possess.c
      pcre2lib/pcre2_chartables.c
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
        FILES
          # Exclude PCRE2 library config.h header as it uses the
          # HAVE_PCRE_VALGRIND_SUPPORT provided via compile definition by
          # generator expressions (not available in the PHP configuration
          # headers). It isn't required to use public headers. Perhaps more
          # could be filtered and synced with upstream PCRE installed headers.
          #pcre2lib/config.h
          pcre2lib/pcre2_internal.h
          pcre2lib/pcre2_intmodedep.h
          pcre2lib/pcre2_jit_neon_inc.h
          pcre2lib/pcre2_jit_simd_inc.h
          pcre2lib/pcre2_ucp.h
          pcre2lib/pcre2.h
  )

  # For pcre2lib/sljit/sljitNativeARM_64.c on ARM 64 processors build.
  php_check_compiler_flag(
    C
    -Wno-implicit-fallthrough
    _PHP_HAVE_WNO_IMPLICIT_FALLTHROUGH_C
  )
  if(_PHP_HAVE_WNO_IMPLICIT_FALLTHROUGH_C)
    set_property(
      SOURCE pcre2lib/pcre2_jit_compile.c
      APPEND
      PROPERTY
        COMPILE_OPTIONS -Wno-implicit-fallthrough
    )
  endif()

  if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(PCRE2_STATIC TRUE)
  endif()

  target_compile_definitions(
    php_ext_pcre
    PRIVATE
      # PCRE2 library uses C99 memmove() function conditionally in some files.
      HAVE_MEMMOVE
      HAVE_CONFIG_H
  )

  set(HAVE_BUNDLED_PCRE TRUE)

  message(CHECK_START "Checking whether to enable PCRE JIT support")

  if(PHP_EXT_PCRE_JIT)
    set(HAVE_PCRE_JIT_SUPPORT TRUE)

    message(CHECK_PASS "yes")

    message(CHECK_START "Checking whether Intel CET is enabled")
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_QUIET TRUE)
      check_symbol_exists(__CET__ "" _PHP_HAVE_PCRE2_INTEL_CET)
    cmake_pop_check_state()
    if(_PHP_HAVE_PCRE2_INTEL_CET)
      message(CHECK_PASS "yes")
      php_check_compiler_flag(C -mshstk _PHP_HAVE_MSHSTK_C)
      if(_PHP_HAVE_MSHSTK_C)
        target_compile_options(php_ext_pcre PRIVATE -mshstk)
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
      php_ext_pcre
      PRIVATE
        $<$<CONFIG:Debug,DebugAssertions>:HAVE_PCRE_VALGRIND_SUPPORT>
    )
  endif()
endif()

add_feature_info(
  "ext/pcre JIT"
  HAVE_PCRE_JIT_SUPPORT
  "PCRE just-in-time compilation"
)

configure_file(cmake/config.h.in config.h)
