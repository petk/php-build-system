#[=============================================================================[
# The posix extension

Configure the `posix` extension.

This extension provides support for POSIX-like functions.

> [!NOTE]
> This extension is available only on \*nix systems.

## PHP_EXT_POSIX

* Default: `ON`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_POSIX_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.25...3.31)

project(
  PhpExtensionPosix
  LANGUAGES C
)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

include(CheckStructHasMember)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(PHP_EXT_POSIX "Enable the posix extension (POSIX-like functions)" ON)

add_feature_info(
  "ext/posix"
  PHP_EXT_POSIX
  "IEEE 1003.1 (POSIX.1) interface"
)

cmake_dependent_option(
  PHP_EXT_POSIX_SHARED
  "Build the posix extension as a shared library"
  OFF
  "PHP_EXT_POSIX;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT PHP_EXT_POSIX)
  return()
endif()

if(PHP_EXT_POSIX_SHARED)
  add_library(php_ext_posix SHARED)
else()
  add_library(php_ext_posix)
endif()

target_sources(
  php_ext_posix
  PRIVATE
    posix.c
    posix.stub.php
)

target_compile_definitions(php_ext_posix PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

check_symbol_exists(ctermid stdio.h HAVE_CTERMID)
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(eaccess unistd.h HAVE_EACCESS)
cmake_pop_check_state()
check_symbol_exists(getgrgid_r grp.h HAVE_GETGRGID_R)
check_symbol_exists(getgroups unistd.h HAVE_GETGROUPS)
check_symbol_exists(getpgid unistd.h HAVE_GETPGID)
check_symbol_exists(getrlimit sys/resource.h HAVE_GETRLIMIT)
check_symbol_exists(getsid unistd.h HAVE_GETSID)

# BSD-based systems have initgroups in unistd.h but still have grp.h file.
block()
  set(headers "")

  if(HAVE_GRP_H)
    list(APPEND headers "grp.h")
  endif()

  if(HAVE_UNISTD_H)
    list(APPEND headers "unistd.h")
  endif()

  check_symbol_exists(initgroups "${headers}" HAVE_INITGROUPS)
endblock()

check_symbol_exists(mkfifo sys/stat.h HAVE_MKFIFO)
check_symbol_exists(mknod sys/stat.h HAVE_MKNOD)

# Skip pathconf and fpathconf check on musl libc due to limited implementation
# (first argument is not validated and has different error).
if(NOT PHP_C_STANDARD_LIBRARY STREQUAL "musl")
  check_symbol_exists(pathconf unistd.h HAVE_PATHCONF)
  check_symbol_exists(fpathconf unistd.h HAVE_FPATHCONF)
endif()

check_symbol_exists(setegid unistd.h HAVE_SETEGID)
check_symbol_exists(seteuid unistd.h HAVE_SETEUID)
check_symbol_exists(setrlimit sys/resource.h HAVE_SETRLIMIT)
check_symbol_exists(setsid unistd.h HAVE_SETSID)

# Check for major, minor, and makedev.
include(PHP/CheckSysMacros)

include(cmake/CheckTtynameR.cmake)

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_struct_has_member(
    "struct utsname"
    domainname
    sys/utsname.h
    HAVE_UTSNAME_DOMAINNAME
  )
cmake_pop_check_state()

set(HAVE_POSIX TRUE)

configure_file(cmake/config.h.in config.h)
