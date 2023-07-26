option(EXTERNAL_PCRE "Use external library for PCRE support" OFF)
option(PCRE_JIT "Whether to enable PCRE JIT functionality" ON)

if(EXTERNAL_PCRE)
  # TODO: implement external PCRE library usage.
else()
  message(STATUS "Checking for PCRE library to use")
  message(STATUS "Bundled PCRE library")

  php_extension(NAME "pcre")

  add_library(ext_pcre
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
  )

  target_compile_options(ext_pcre
    PRIVATE -Wno-implicit-fallthrough
  )

  target_compile_definitions(ext_pcre
    PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
    PRIVATE HAVE_CONFIG_H
  )

  set(HAVE_BUNDLED_PCRE 1 CACHE STRING "Whether the bundled PCRE library is used")
  set(PCRE2_CODE_UNIT_WIDTH 8 CACHE STRING "Number of bits in non-UTF mode for PCRE library")

  message(STATUS "Checking whether to enable PCRE JIT functionality")

  if(PCRE_JIT)
    set(HAVE_PCRE_JIT_SUPPORT 1 CACHE STRING "Whether to enable the PCRE JIT support")

    message(STATUS "PCRE JIT enabled")

    message(STATUS "Checking whether Intel CET is enabled")
    include(CheckCSourceCompiles)
    check_c_source_compiles("
      #ifndef __CET__
      # error CET is not enabled
      #endif
      int main()
      {
        ;
        return 0;
      }
      " HAVE_PCRE2_INTEL_CET
    )

    if(HAVE_PCRE2_INTEL_CET)
      message(STATUS "Intel CET is enabled")
      target_compile_options(ext_pcre PRIVATE -mshstk)
    else()
      message(STATUS "Intel CET is disabled")
    endif()
  else()
    message(STATUS "PCRE JIT disabled")
  endif()

  # TODO: Add all headers of the bundled PCRE library.
  set_target_properties(ext_pcre PROPERTIES PUBLIC_HEADER "php_pcre.h;pcre2lib/")

  # TODO: ADD valgrind.
endif()
