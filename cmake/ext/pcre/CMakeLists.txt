include(CheckCSourceCompiles)
include(CheckCSourceRuns)
include(PHPFindPackage)

option(EXT_PCRE_EXTERNAL "Use external library for PCRE support" OFF)
option(EXT_PCRE_JIT "Whether to enable PCRE JIT functionality" ON)

php_extension(NAME "pcre" STATIC)

if(EXT_PCRE_EXTERNAL)
  php_find_package(NAME libpcre2-8 VERSION 10.30)

  if(NOT libpcre2-8_FOUND)
    message(FATAL_ERROR "libpcre2-8 not found")
  endif()

  set(PCRE2_CODE_UNIT_WIDTH 8 CACHE INTERNAL "Number of bits in non-UTF mode for PCRE library")

  if(EXT_PCRE_JIT)
    message(STATUS "Checking for JIT support in PCRE2")

    if(CMAKE_CROSSCOMPILING)
      string(TOLOWER "${CMAKE_HOST_SYSTEM_NAME}" host_os)

      if(${host_os} MATCHES "arm.*|i[34567]86|x86_64|mips.*|powerpc.*|sparc")
        set(successful ON)
      else()
        set(successful OFF)
      endif()
    else()
      check_c_source_runs("
        #include <pcre2.h>
        #include <stdlib.h>
        int main(void) {
          uint32_t have_jit;
          pcre2_config_8(PCRE2_CONFIG_JIT, &have_jit);
          return !have_jit;
        }
      " successful)
    endif()

    if(successful)
      set(HAVE_PCRE_JIT_SUPPORT 1 CACHE INTERNAL "Whether to enable the PCRE JIT support")
    endif()

    unset(successful)
  endif()

  add_library(ext_pcre STATIC
    php_pcre.c
  )

  target_compile_definitions(ext_pcre
    PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
  )

  set_target_properties(ext_pcre PROPERTIES PUBLIC_HEADER "php_pcre.h")

  target_link_libraries(ext_pcre ${libpcre2-8_LIBRARIES})
  target_compile_options(ext_pcre PRIVATE ${libpcre2-8_CFLAGS})
else()
  message(STATUS "Using bundled PCRE library")

  add_library(ext_pcre STATIC
    pcre2lib/pcre2_auto_possess.c
    pcre2lib/pcre2_chartables.c
    pcre2lib/pcre2_compile.c
    pcre2lib/pcre2_config.c
    pcre2lib/pcre2_context.c
    pcre2lib/pcre2_dfa_match.c
    pcre2lib/pcre2_error.c
    pcre2lib/pcre2_jit_compile.c
    pcre2lib/pcre2_maketables.c
    pcre2lib/pcre2_match.c
    pcre2lib/pcre2_match_data.c
    pcre2lib/pcre2_newline.c
    pcre2lib/pcre2_ord2utf.c
    pcre2lib/pcre2_pattern_info.c
    pcre2lib/pcre2_serialize.c
    pcre2lib/pcre2_string_utils.c
    pcre2lib/pcre2_study.c
    pcre2lib/pcre2_substitute.c
    pcre2lib/pcre2_substring.c
    pcre2lib/pcre2_tables.c
    pcre2lib/pcre2_ucd.c
    pcre2lib/pcre2_valid_utf.c
    pcre2lib/pcre2_xclass.c
    pcre2lib/pcre2_find_bracket.c
    pcre2lib/pcre2_convert.c
    pcre2lib/pcre2_extuni.c
    pcre2lib/pcre2_script_run.c
    php_pcre.c
  )

  target_include_directories(
    ext_pcre
    PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}"
    PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/pcre2lib"
    PUBLIC "${CMAKE_SOURCE_DIR}"
  )

  target_compile_options(ext_pcre
    PRIVATE -Wno-implicit-fallthrough
  )

  target_compile_definitions(ext_pcre
    PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
    PRIVATE HAVE_CONFIG_H
  )

  set(HAVE_BUNDLED_PCRE 1 CACHE INTERNAL "Whether the bundled PCRE library is used")
  set(PCRE2_CODE_UNIT_WIDTH 8 CACHE INTERNAL "Number of bits in non-UTF mode for PCRE library")

  message(STATUS "Checking whether to enable PCRE JIT functionality")

  if(EXT_PCRE_JIT)
    set(HAVE_PCRE_JIT_SUPPORT 1 CACHE INTERNAL "Whether to enable the PCRE JIT support")

    message(STATUS "PCRE JIT enabled")

    message(STATUS "Checking whether Intel CET is enabled")

    check_c_source_compiles("
      #ifndef __CET__
      # error CET is not enabled
      #endif
      int main()
      {
        ;
        return 0;
      }
      " have_pcre2_intel_cet
    )

    if(have_pcre2_intel_cet)
      message(STATUS "Intel CET is enabled")
      target_compile_options(ext_pcre PRIVATE -mshstk)
    else()
      message(STATUS "Intel CET is disabled")
    endif()

    unset(have_pcre2_intel_cet)
  else()
    message(STATUS "PCRE JIT disabled")
  endif()

  file(GLOB PCRE_HEADER_FILES "${CMAKE_CURRENT_SOURCE_DIR}/pcre2lib/*.h")
  list(APPEND PCRE_HEADER_FILES "${CMAKE_CURRENT_SOURCE_DIR}/php_pcre.h")
  set_target_properties(ext_pcre PROPERTIES PUBLIC_HEADER "${PCRE_HEADER_FILES}")

  if(VALGRIND AND ZEND_DEBUG)
    set(HAVE_PCRE_VALGRIND_SUPPORT 1 CACHE INTERNAL "Whether to enable the Valgrind support in PCRE")
  endif()
endif()
