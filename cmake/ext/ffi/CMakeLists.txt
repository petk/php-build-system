include(CheckSourceCompiles)
include(CheckTypeSize)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(EXT_FFI "Enable the ffi extension" OFF)

add_feature_info("ext/ffi" EXT_FFI
  "Foreign Function Interface (FFI) support."
)

cmake_dependent_option(
  EXT_FFI_SHARED
  "Build the ffi extension as a shared library"
  OFF
  "EXT_FFI;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_FFI)
  return()
endif()

if(EXT_FFI_SHARED)
  add_library(php_ffi SHARED)
else()
  add_library(php_ffi)
endif()

target_sources(php_ffi PRIVATE
  ffi_parser.c
  ffi.c
)

target_compile_definitions(php_ffi PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

find_package(FFI 3.0.11)
set_package_properties(FFI PROPERTIES
  TYPE REQUIRED
  PURPOSE "Necessary to enable the ffi extension."
)

target_link_libraries(php_ffi PRIVATE FFI::FFI)

check_type_size("long double" SIZEOF_LONG_DOUBLE)
if(HAVE_SIZEOF_LONG_DOUBLE)
  set(
    HAVE_LONG_DOUBLE 1
    CACHE INTERNAL "Define to 1 if the system has the type 'long double'."
  )
else()
  message(WARNING "Cannot determine size of long double.")
endif()

message(CHECK_START "Checking for fastcall calling convention")

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_LIBRARIES FFI::FFI)
  set(CMAKE_REQUIRED_INCLUDES "${FFI_INCLUDE_DIRS}")

  check_source_compiles(C "
    #include <ffi.h>

    int main(void) {
      return FFI_FASTCALL;
    }
  " HAVE_FFI_FASTCALL)

  if(HAVE_FFI_FASTCALL)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()

  message(CHECK_START "Checking for thiscall calling convention")

  check_source_compiles(C "
    #include <ffi.h>

    int main(void) {
      return FFI_THISCALL;
    }
  " HAVE_FFI_THISCALL)

  if(HAVE_FFI_THISCALL)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()

  message(CHECK_START "Checking for stdcall calling convention")

  check_source_compiles(C "
    #include <ffi.h>

    int main(void) {
      return FFI_STDCALL;
    }
  " HAVE_FFI_STDCALL)

  if(HAVE_FFI_STDCALL)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()

  message(CHECK_START "Checking for pascal calling convention")

  check_source_compiles(C "
    #include <ffi.h>

    int main(void) {
      return FFI_PASCAL;
    }
  " HAVE_FFI_PASCAL)

  if(HAVE_FFI_PASCAL)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()

  message(CHECK_START "Checking for register calling convention")

  check_source_compiles(C "
    #include <ffi.h>

    int main(void) {
      return FFI_REGISTER;
    }
  " HAVE_FFI_REGISTER)

  if(HAVE_FFI_REGISTER)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()

  message(CHECK_START "Checking for ms_cdecl calling convention")

  check_source_compiles(C "
    #include <ffi.h>

    int main(void) {
      return FFI_MS_CDECL;
    }
  " HAVE_FFI_MS_CDECL)

  if(HAVE_FFI_MS_CDECL)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()

  message(CHECK_START "Checking for sysv calling convention")

  check_source_compiles(C "
    #include <ffi.h>

    int main(void) {
      return FFI_SYSV;
    }
  " HAVE_FFI_SYSV)

  if(HAVE_FFI_SYSV)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
cmake_pop_check_state()
