include(CheckCSourceCompiles)
include(CheckTypeSize)
include(PHPFindPackage)

option(ffi "Whether to build the ffi extension" OFF)

if(ffi)
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

  string(TOLOWER ${ffi} extension_lower)
  set(extension_library_type "STATIC")
  if(extension_lower STREQUAL "shared")
    set(extension_library_type "SHARED")
  endif()

  php_extension(NAME ffi ${extension_library_type})

  add_library(ext_ffi ${extension_library_type}
    ffi.c
    ffi_parser.c
  )

  php_find_package(NAME libffi VERSION 3.0.11)

  target_link_libraries(ext_ffi PRIVATE ${libffi_LIBRARIES})
  target_compile_options(ext_ffi PRIVATE ${libffi_CFLAGS})

  target_compile_definitions(ext_ffi PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)
endif()
