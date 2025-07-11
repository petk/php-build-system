#[=============================================================================[
# The ffi extension

Configure the `ffi` extension.

This extension provides Foreign Function Interface (FFI) support to run C code
through PHP.

## PHP_EXT_FFI

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_FFI_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.1)

project(
  PhpExtensionFfi
  LANGUAGES C
)

include(CheckSymbolExists)
include(CheckTypeSize)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(PHP_EXT_FFI "Enable the ffi extension")

add_feature_info(
  "ext/ffi"
  PHP_EXT_FFI
  "Foreign Function Interface (FFI)"
)

cmake_dependent_option(
  PHP_EXT_FFI_SHARED
  "Build the ffi extension as a shared library"
  OFF
  PHP_EXT_FFI
  OFF
)

if(NOT PHP_EXT_FFI)
  return()
endif()

if(PHP_EXT_FFI_SHARED)
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

target_compile_definitions(php_ext_ffi PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

find_package(FFI 3.0.11)
set_package_properties(
  FFI
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the ffi extension."
)

target_link_libraries(php_ext_ffi PRIVATE FFI::FFI)

check_type_size("long double" LONG_DOUBLE)

if(TARGET FFI::FFI)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES FFI::FFI)

    check_symbol_exists(FFI_FASTCALL ffi.h HAVE_FFI_FASTCALL)
    check_symbol_exists(FFI_MS_CDECL ffi.h HAVE_FFI_MS_CDECL)
    check_symbol_exists(FFI_PASCAL ffi.h HAVE_FFI_PASCAL)
    check_symbol_exists(FFI_REGISTER ffi.h HAVE_FFI_REGISTER)
    check_symbol_exists(FFI_STDCALL ffi.h HAVE_FFI_STDCALL)
    check_symbol_exists(FFI_SYSV ffi.h HAVE_FFI_SYSV)
    check_symbol_exists(FFI_THISCALL ffi.h HAVE_FFI_THISCALL)

    # Available only in https://github.com/winlibs/libffi fork.
    check_symbol_exists(FFI_VECTORCALL_PARTIAL ffi.h HAVE_FFI_VECTORCALL_PARTIAL)
  cmake_pop_check_state()
endif()

set(HAVE_FFI TRUE)

configure_file(cmake/config.h.in config.h)
