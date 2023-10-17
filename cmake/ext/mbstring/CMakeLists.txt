include(CheckCSourceCompiles)
include(CMakeDependentOption)
include(CMakePushCheckState)

option(EXT_MBSTRING "Whether to enable the multibyte string support extension" OFF)

cmake_dependent_option(
  EXT_MBSTRING_SHARED
  "Whether to build the mbstring extension as shared object"
  OFF
  "EXT_MBSTRING;NOT BUILD_SHARED_LIBS"
  OFF
)

cmake_dependent_option(EXT_MBSTRING_MBREGEX "Whether to enable multibyte regex support (requires Oniguruma)" ON "EXT_MBSTRING" OFF)

if(NOT EXT_MBSTRING)
  return()
endif()

if(EXT_MBSTRING_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

add_library(php_mbstring ${_library_type}
  mbstring.c
  php_unicode.c
  mb_gpc.c
  libmbfl/filters/html_entities.c
  libmbfl/filters/mbfilter_7bit.c
  libmbfl/filters/mbfilter_base64.c
  libmbfl/filters/mbfilter_cjk.c
  libmbfl/filters/mbfilter_htmlent.c
  libmbfl/filters/mbfilter_qprint.c
  libmbfl/filters/mbfilter_singlebyte.c
  libmbfl/filters/mbfilter_ucs2.c
  libmbfl/filters/mbfilter_ucs4.c
  libmbfl/filters/mbfilter_utf16.c
  libmbfl/filters/mbfilter_utf32.c
  libmbfl/filters/mbfilter_utf7.c
  libmbfl/filters/mbfilter_utf7imap.c
  libmbfl/filters/mbfilter_utf8.c
  libmbfl/filters/mbfilter_utf8_mobile.c
  libmbfl/filters/mbfilter_uuencode.c
  libmbfl/mbfl/mbfilter.c
  libmbfl/mbfl/mbfilter_8bit.c
  libmbfl/mbfl/mbfilter_pass.c
  libmbfl/mbfl/mbfilter_wchar.c
  libmbfl/mbfl/mbfl_convert.c
  libmbfl/mbfl/mbfl_encoding.c
  libmbfl/mbfl/mbfl_filter_output.c
  libmbfl/mbfl/mbfl_language.c
  libmbfl/mbfl/mbfl_memory_device.c
  libmbfl/mbfl/mbfl_string.c
  libmbfl/nls/nls_de.c
  libmbfl/nls/nls_en.c
  libmbfl/nls/nls_ja.c
  libmbfl/nls/nls_kr.c
  libmbfl/nls/nls_neutral.c
  libmbfl/nls/nls_ru.c
  libmbfl/nls/nls_uni.c
  libmbfl/nls/nls_zh.c
  libmbfl/nls/nls_hy.c
  libmbfl/nls/nls_tr.c
  libmbfl/nls/nls_ua.c
)

message(STATUS "Creating ext/mbstring/libmbfl/config.h")
file(WRITE
  "${CMAKE_CURRENT_BINARY_DIR}/libmbfl/config.h"
  "#include \"php_config.h\"\n"
)

set(_mbstring_headers_files
  libmbfl/mbfl/eaw_table.h
  libmbfl/mbfl/mbfilter.h
  libmbfl/mbfl/mbfilter_8bit.h
  libmbfl/mbfl/mbfilter_pass.h
  libmbfl/mbfl/mbfilter_wchar.h
  libmbfl/mbfl/mbfl_consts.h
  libmbfl/mbfl/mbfl_convert.h
  libmbfl/mbfl/mbfl_defs.h
  libmbfl/mbfl/mbfl_encoding.h
  libmbfl/mbfl/mbfl_filter_output.h
  libmbfl/mbfl/mbfl_language.h
  libmbfl/mbfl/mbfl_memory_device.h
  libmbfl/mbfl/mbfl_string.h
)
list(APPEND _mbstring_headers_files "${CMAKE_CURRENT_BINARY_DIR}/libmbfl/config.h")
list(APPEND _mbstring_headers_files "${CMAKE_CURRENT_SOURCE_DIR}/mbstring.h")

if(EXT_MBSTRING_MBREGEX)
  find_package(Oniguruma REQUIRED)

  target_link_libraries(php_mbstring PRIVATE Oniguruma::Oniguruma)

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
    set(CMAKE_REQUIRED_LIBRARIES Oniguruma::Oniguruma)

    check_c_source_compiles("
      #include <oniguruma.h>

      int main(void) {
        return (int)(ONIG_ENCODING_KOI8 + 1);
      }
    " _has_invalid_entry)
  cmake_pop_check_state()

  if(NOT _has_invalid_entry)
    set(PHP_ONIG_BAD_KOI8_ENTRY 1 CACHE INTERNAL "Define to 1 if Oniguruma has an invalid entry for KOI8 encoding")
  endif()

  target_compile_definitions(
    php_mbstring
    PRIVATE
      ONIG_ESCAPE_UCHAR_COLLISION=1
      UChar=OnigUChar
  )

  set(HAVE_MBREGEX 1 CACHE INTERNAL "Whether to have multibyte regex support")

  target_sources(php_mbstring PRIVATE php_mbregex.c)

  list(APPEND _mbstring_headers_files "php_mbregex.h;php_onig_compat.h")
endif()

target_compile_definitions(php_mbstring PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

target_include_directories(
  php_mbstring
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/libmbfl
    ${CMAKE_CURRENT_BINARY_DIR}/libmbfl
    ${CMAKE_CURRENT_SOURCE_DIR}/libmbfl/mbfl
)

target_sources(
  php_mbstring
  PUBLIC FILE_SET mbstring_headers
  TYPE HEADERS
  BASE_DIRS "${CMAKE_CURRENT_BINARY_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}"
  FILES ${_mbstring_headers_files}
)

install(
  TARGETS php_mbstring
  FILE_SET mbstring_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/mbstring
)
