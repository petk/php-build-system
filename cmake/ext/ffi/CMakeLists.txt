include(CheckCSourceCompiles)
include(CheckTypeSize)
include(CMakeDependentOption)

option(EXT_FFI "Whether to build the FFI extension" OFF)

cmake_dependent_option(EXT_FFI_SHARED "Whether to build the FFI extension as shared object" OFF "EXT_FFI;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_FFI)
  return()
endif()

if(EXT_FFI_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "ffi" ${_library_type})

add_library(php_ffi ${_library_type}
  ffi.c
  ffi_parser.c
)

check_type_size("long double" SIZEOF_LONG_DOUBLE)
if(HAVE_SIZEOF_LONG_DOUBLE)
  set(HAVE_LONG_DOUBLE 1 CACHE INTERNAL "Define to 1 if the system has the type `long double'.")
else()
  message(WARNING "Cannot determine size of long double.")
endif()

message(STATUS "Checking for fastcall calling convention")

check_c_source_compiles("
  #include <ffi.h>

  int main(void) {
    return FFI_FASTCALL;
  }
" HAVE_FFI_FASTCALL)

message(STATUS "Checking for thiscall calling convention")

check_c_source_compiles("
  #include <ffi.h>

  int main(void) {
    return FFI_THISCALL;
  }
" HAVE_FFI_THISCALL)

message(STATUS "Checking for stdcall calling convention")

check_c_source_compiles("
  #include <ffi.h>

  int main(void) {
    return FFI_STDCALL;
  }
" HAVE_FFI_STDCALL)

message(STATUS "Checking for pascal calling convention")

check_c_source_compiles("
  #include <ffi.h>

  int main(void) {
    return FFI_PASCAL;
  }
" HAVE_FFI_PASCAL)

message(STATUS "Checking for register calling convention")

check_c_source_compiles("
  #include <ffi.h>

  int main(void) {
    return FFI_REGISTER;
  }
" HAVE_FFI_REGISTER)

message(STATUS "Checking for ms_cdecl calling convention")

check_c_source_compiles("
  #include <ffi.h>

  int main(void) {
    return FFI_MS_CDECL;
  }
" HAVE_FFI_MS_CDECL)

message(STATUS "Checking for sysv calling convention")

check_c_source_compiles("
  #include <ffi.h>

  int main(void) {
    return FFI_SYSV;
  }
" HAVE_FFI_SYSV)

find_package(FFI 3.0.11 REQUIRED)

if(TARGET FFI::FFI)
  target_link_libraries(php_ffi PRIVATE FFI::FFI)
endif()

set_property(TARGET php_ffi PROPERTY OUTPUT_NAME ffi)

target_compile_definitions(php_ffi PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

add_library(PHP::ffi ALIAS php_ffi)
