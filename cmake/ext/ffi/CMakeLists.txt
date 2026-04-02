#[=============================================================================[
# The ffi extension

This extension provides Foreign Function Interface (FFI) support to run C code
through PHP.

## Configuration options

### PHP_EXT_FFI

* Default: `OFF`
* Values: `ON|OFF|shared`

Enables the extension.
#]=============================================================================]

cmake_minimum_required(VERSION 4.3...4.4)

project(
  PHP_EXT_FFI
  LANGUAGES C
)

include(CheckSymbolExists)
include(CheckTypeSize)
include(CMakePushCheckState)
include(FeatureSummary)

option(PHP_EXT_FFI "Enable the ffi extension" ${PROJECT_IS_TOP_LEVEL})

add_feature_info(
  "ext/ffi"
  PHP_EXT_FFI
  "Foreign Function Interface (FFI)"
)

if(NOT PHP_EXT_FFI)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(ffi)

if(PHP_EXT_FFI STREQUAL "shared" OR PROJECT_IS_TOP_LEVEL)
  add_library(php_ext_ffi MODULE)
else()
  add_library(php_ext_ffi OBJECT)
endif()

target_sources(
  php_ext_ffi
  PRIVATE
    ffi_parser.c
    ffi.c
    ffi.stub.php
)

target_include_directories(php_ext_ffi PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

target_compile_definitions(php_ext_ffi PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

find_package(FFI 3.0.11)
set_package_properties(
  FFI
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the ffi extension."
)

target_link_libraries(php_ext_ffi PRIVATE FFI::FFI)

check_type_size(
  "long double"
  PHP_EXT_FFI_SIZEOF_LONG_DOUBLE
  RESULT_VARIABLE PHP_EXT_FFI_HAVE_LONG_DOUBLE
)
set(HAVE_LONG_DOUBLE ${PHP_EXT_FFI_HAVE_LONG_DOUBLE})

if(TARGET FFI::FFI)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES FFI::FFI)

    check_symbol_exists(FFI_FASTCALL ffi.h PHP_EXT_FFI_HAVE_FFI_FASTCALL)
    set(HAVE_FFI_FASTCALL ${PHP_EXT_FFI_HAVE_FFI_FASTCALL})

    check_symbol_exists(FFI_MS_CDECL ffi.h PHP_EXT_FFI_HAVE_FFI_MS_CDECL)
    set(HAVE_FFI_MS_CDECL ${PHP_EXT_FFI_HAVE_FFI_MS_CDECL})

    check_symbol_exists(FFI_PASCAL ffi.h PHP_EXT_FFI_HAVE_FFI_PASCAL)
    set(HAVE_FFI_PASCAL ${PHP_EXT_FFI_HAVE_FFI_PASCAL})

    check_symbol_exists(FFI_REGISTER ffi.h PHP_EXT_FFI_HAVE_FFI_REGISTER)
    set(HAVE_FFI_REGISTER ${PHP_EXT_FFI_HAVE_FFI_REGISTER})

    check_symbol_exists(FFI_STDCALL ffi.h PHP_EXT_FFI_HAVE_FFI_STDCALL)
    set(HAVE_FFI_STDCALL ${PHP_EXT_FFI_HAVE_FFI_STDCALL})

    check_symbol_exists(FFI_SYSV ffi.h PHP_EXT_FFI_HAVE_FFI_SYSV)
    set(HAVE_FFI_SYSV ${PHP_EXT_FFI_HAVE_FFI_SYSV})

    check_symbol_exists(FFI_THISCALL ffi.h PHP_EXT_FFI_HAVE_FFI_THISCALL)
    set(HAVE_FFI_THISCALL ${PHP_EXT_FFI_HAVE_FFI_THISCALL})

    # Available only in https://github.com/winlibs/libffi fork.
    check_symbol_exists(
      FFI_VECTORCALL_PARTIAL
      ffi.h
      PHP_EXT_FFI_HAVE_FFI_VECTORCALL_PARTIAL
    )
    set(HAVE_FFI_VECTORCALL_PARTIAL ${PHP_EXT_FFI_HAVE_FFI_VECTORCALL_PARTIAL})
  cmake_pop_check_state()
endif()

set(HAVE_FFI TRUE)

configure_file(cmake/config.h.in config.h)
