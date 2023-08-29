include(CheckCSourceCompiles)
include(CheckTypeSize)
include(PHPFindPackage)
include(CMakeDependentOption)

option(EXT_FFI "Whether to build the FFI extension" OFF)

cmake_dependent_option(EXT_FFI_SHARED "Whether to build the FFI extension as shared object" OFF "EXT_FFI;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_FFI)
  return()
endif()

check_type_size("long double" LONG_DOUBLE)
if(NOT HAVE_LONG_DOUBLE)
  message(FATAL_ERROR "Cannot determine size of long double.")
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

if(EXT_FFI_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME ffi ${_library_type})

add_library(ext_ffi ${_library_type}
  ffi.c
  ffi_parser.c
)

php_find_package(NAME libffi VERSION 3.0.11)

target_link_libraries(ext_ffi PRIVATE ${libffi_LIBRARIES})
target_compile_options(ext_ffi PRIVATE ${libffi_CFLAGS})

target_compile_definitions(ext_ffi PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)
