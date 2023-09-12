include(CheckCSourceCompiles)
include(CheckCSourceRuns)

option(EXT_PCRE_EXTERNAL "Use external library for PCRE support" OFF)
option(EXT_PCRE_JIT "Whether to enable PCRE JIT functionality" ON)

php_extension(NAME "pcre" STATIC)

add_library(ext_pcre STATIC
  php_pcre.c
)

target_compile_definitions(ext_pcre
  PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
)

set(PCRE2_CODE_UNIT_WIDTH 8 CACHE INTERNAL "Number of bits in non-UTF mode for PCRE library")

if(EXT_PCRE_EXTERNAL)
  find_package(PCRE 10.30 REQUIRED)

  if(PCRE_LIBRARIES)
    target_link_libraries(ext_pcre PRIVATE ${PCRE_LIBRARIES})
  endif()

  if(PCRE_INCLUDE_DIRS)
    target_include_directories(ext_pcre PRIVATE ${PCRE_INCLUDE_DIRS})
  endif()

  if(EXT_PCRE_JIT)
    message(STATUS "Checking for JIT support in PCRE2")

    if(CMAKE_CROSSCOMPILING)
      if(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "arm.*|i[34567]86|x86_64|mips.*|powerpc.*|sparc")
        set(_successful ON)
      else()
        set(_successful OFF)
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
      " _successful)
    endif()

    if(_successful)
      set(HAVE_PCRE_JIT_SUPPORT 1 CACHE INTERNAL "Whether to enable the PCRE JIT support")
    endif()

    unset(_successful)
  endif()
else()
  message(STATUS "Using bundled PCRE library")

  target_sources(ext_pcre PRIVATE
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
  )

  target_include_directories(
    ext_pcre
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/pcre2lib
  )

  target_compile_options(ext_pcre
    PRIVATE -Wno-implicit-fallthrough
  )

  target_compile_definitions(ext_pcre
    PRIVATE HAVE_CONFIG_H
  )

  set(HAVE_BUNDLED_PCRE 1 CACHE INTERNAL "Whether the bundled PCRE library is used")

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

  if(VALGRIND AND PHP_DEBUG)
    set(HAVE_PCRE_VALGRIND_SUPPORT 1 CACHE INTERNAL "Whether to enable the Valgrind support in PCRE")
  endif()

  file(GLOB _ext_pcre_headers "${CMAKE_CURRENT_SOURCE_DIR}/pcre2lib/*.h")
endif()

list(APPEND _ext_pcre_headers "${CMAKE_CURRENT_SOURCE_DIR}/php_pcre.h")

target_sources(
  ext_pcre
  PUBLIC FILE_SET ext_pcre_headers
  TYPE HEADERS
  FILES ${_ext_pcre_headers}
)

install(
  TARGETS ext_pcre
  FILE_SET ext_pcre_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/pcre
)
