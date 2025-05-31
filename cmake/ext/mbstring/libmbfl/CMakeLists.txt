#[=============================================================================[
# libmbfl

Simplified CMake-based build system for the libmbfl library. Since libmbfl is
closely integrated and intertwined with PHP sources, the `target_sources()`
approach is used, with no alternative implementations provided at this stage.

## Usage

Adding libmbfl with `add_subdirectory()`:

```cmake
set(LIBMBFL_TARGET php_ext_mbstring)
add_subdirectory(libmbfl)
```
#]=============================================================================]

include(CheckIncludeFiles)
include(CheckSymbolExists)

if(NOT LIBMBFL_TARGET)
  set(LIBMBFL_TARGET libmbfl)
  add_library(${LIBMBFL_TARGET})
endif()

target_sources(
  ${LIBMBFL_TARGET}
  PRIVATE
    filters/html_entities.c
    filters/mbfilter_7bit.c
    filters/mbfilter_base64.c
    filters/mbfilter_cjk.c
    filters/mbfilter_htmlent.c
    filters/mbfilter_qprint.c
    filters/mbfilter_singlebyte.c
    filters/mbfilter_ucs2.c
    filters/mbfilter_ucs4.c
    filters/mbfilter_utf16.c
    filters/mbfilter_utf32.c
    filters/mbfilter_utf7.c
    filters/mbfilter_utf7imap.c
    filters/mbfilter_utf8.c
    filters/mbfilter_uuencode.c
    mbfl/mbfilter_8bit.c
    mbfl/mbfilter_pass.c
    mbfl/mbfilter_wchar.c
    mbfl/mbfilter.c
    mbfl/mbfl_convert.c
    mbfl/mbfl_encoding.c
    mbfl/mbfl_filter_output.c
    mbfl/mbfl_language.c
    mbfl/mbfl_memory_device.c
    mbfl/mbfl_string.c
    nls/nls_de.c
    nls/nls_en.c
    nls/nls_hy.c
    nls/nls_ja.c
    nls/nls_kr.c
    nls/nls_neutral.c
    nls/nls_ru.c
    nls/nls_tr.c
    nls/nls_ua.c
    nls/nls_uni.c
    nls/nls_zh.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        mbfl/eaw_table.h
        mbfl/mbfilter_8bit.h
        mbfl/mbfilter_pass.h
        mbfl/mbfilter_wchar.h
        mbfl/mbfilter.h
        mbfl/mbfl_consts.h
        mbfl/mbfl_convert.h
        mbfl/mbfl_defs.h
        mbfl/mbfl_encoding.h
        mbfl/mbfl_filter_output.h
        mbfl/mbfl_language.h
        mbfl/mbfl_memory_device.h
        mbfl/mbfl_string.h
  PUBLIC
    FILE_SET generated
      TYPE HEADERS
      BASE_DIRS $<TARGET_PROPERTY:${LIBMBFL_TARGET},BINARY_DIR>
      FILES
        ${CMAKE_CURRENT_BINARY_DIR}/config.h
)

target_include_directories(
  ${LIBMBFL_TARGET}
  PRIVATE
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/mbfl
)

target_compile_definitions(
  ${LIBMBFL_TARGET}
  PRIVATE
    $<$<AND:$<PLATFORM_ID:Windows>,$<IN_LIST:$<TARGET_PROPERTY:${LIBMBFL_TARGET},TYPE>,MODULE_LIBRARY$<SEMICOLON>SHARED_LIBRARY>>:MBFL_DLL_EXPORT>
)

# The libmbfl configuration header.
check_include_files(strings.h HAVE_STRINGS_H)
check_symbol_exists(strcasecmp strings.h HAVE_STRCASECMP)

cmake_path(
  RELATIVE_PATH
  CMAKE_CURRENT_BINARY_DIR
  BASE_DIRECTORY ${CMAKE_BINARY_DIR}
  OUTPUT_VARIABLE relativeDir
)
message(STATUS "Creating ${relativeDir}/config.h")
file(CONFIGURE OUTPUT config.h CONTENT [[
/* Define to 1 if you have the 'strcasecmp' function. */
#cmakedefine HAVE_STRCASECMP 1

/* Define to 1 if you have the <strings.h> header file. */
#cmakedefine HAVE_STRINGS_H 1
]])
