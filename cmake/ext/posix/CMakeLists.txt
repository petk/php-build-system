# Extension is only for *nix systems.
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

include(CheckStructHasMember)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(EXT_POSIX "Enable the posix extension (POSIX-like functions)" ON)

add_feature_info(
  "ext/posix"
  EXT_POSIX
  "Interface for using IEEE 1003.1 (POSIX.1) functions"
)

cmake_dependent_option(
  EXT_POSIX_SHARED
  "Build the posix extension as a shared library"
  OFF
  "EXT_POSIX;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_POSIX)
  return()
endif()

if(EXT_POSIX_SHARED)
  add_library(php_posix SHARED)
else()
  add_library(php_posix)
endif()

target_sources(
  php_posix
  PRIVATE
    posix.c
)

target_compile_definitions(php_posix PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

check_symbol_exists(ctermid "stdio.h" HAVE_CTERMID)
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(eaccess "unistd.h" HAVE_EACCESS)
cmake_pop_check_state()
check_symbol_exists(getgrgid_r "grp.h" HAVE_GETGRGID_R)
check_symbol_exists(getgroups "unistd.h" HAVE_GETGROUPS)
check_symbol_exists(getpgid "unistd.h" HAVE_GETPGID)
check_symbol_exists(getrlimit "sys/resource.h" HAVE_GETRLIMIT)
check_symbol_exists(getsid "unistd.h" HAVE_GETSID)

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

check_symbol_exists(mkfifo "sys/stat.h" HAVE_MKFIFO)
check_symbol_exists(mknod "sys/stat.h" HAVE_MKNOD)

# Skip pathconf and fpathconf check on musl libc due to limited implementation
# (first argument is not validated and has different error).
if(NOT PHP_C_STANDARD_LIBRARY STREQUAL "musl")
  check_symbol_exists(pathconf "unistd.h" HAVE_PATHCONF)
  check_symbol_exists(fpathconf "unistd.h" HAVE_FPATHCONF)
endif()

check_symbol_exists(setegid "unistd.h" HAVE_SETEGID)
check_symbol_exists(seteuid "unistd.h" HAVE_SETEUID)
check_symbol_exists(setrlimit "sys/resource.h" HAVE_SETRLIMIT)
check_symbol_exists(setsid "unistd.h" HAVE_SETSID)

include(PHP/CheckTtynameR)

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_struct_has_member(
    "struct utsname"
    domainname
    sys/utsname.h
    HAVE_STRUCT_UTSNAME_DOMAINNAME
  )
cmake_pop_check_state()
