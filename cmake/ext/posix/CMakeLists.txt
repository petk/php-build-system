# Extension is only for *nix systems.
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

include(CheckIncludeFile)
include(CheckSourceCompiles)
include(CheckSourceRuns)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(EXT_POSIX "Enable the posix extension (POSIX-like functions)" ON)

add_feature_info(
  "ext/posix"
  EXT_POSIX
  "Interface for using IEEE 1003.1 (POSIX.1) functions."
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

check_include_file(sys/mkdev.h HAVE_SYS_MKDEV_H)
check_include_file(sys/sysmacros.h HAVE_SYS_SYSMACROS_H)

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(eaccess "unistd.h" HAVE_EACCESS)
cmake_pop_check_state()

check_symbol_exists(ctermid "stdio.h" HAVE_CTERMID)
check_symbol_exists(getgrgid_r "grp.h" HAVE_GETGRGID_R)
check_symbol_exists(getgroups "unistd.h" HAVE_GETGROUPS)
check_symbol_exists(getpgid "unistd.h" HAVE_GETPGID)
check_symbol_exists(getrlimit "sys/resource.h" HAVE_GETRLIMIT)
check_symbol_exists(getsid "unistd.h" HAVE_GETSID)
check_symbol_exists(initgroups "grp.h" HAVE_INITGROUPS)
check_symbol_exists(makedev "sys/sysmacros.h" HAVE_MAKEDEV)
check_symbol_exists(mkfifo "sys/stat.h" HAVE_MKFIFO)
check_symbol_exists(mknod "sys/stat.h" HAVE_MKNOD)

# Skip pathconf and fpathconf check on musl libc due to limited implementation
# (first argument is not validated and has different error).
if(NOT PHP_STD_LIBRARY STREQUAL "musl")
  check_symbol_exists(pathconf "unistd.h" HAVE_PATHCONF)
  check_symbol_exists(fpathconf "unistd.h" HAVE_FPATHCONF)
endif()

check_symbol_exists(setegid "unistd.h" HAVE_SETEGID)
check_symbol_exists(seteuid "unistd.h" HAVE_SETEUID)
check_symbol_exists(setrlimit "sys/resource.h" HAVE_SETRLIMIT)
check_symbol_exists(setsid "unistd.h" HAVE_SETSID)

message(CHECK_START "Checking for working ttyname_r() implementation")
if(CMAKE_CROSSCOMPILING)
  message(CHECK_FAIL "no (cross-compiling), posix_ttyname() will be thread-unsafe")
else()
  check_source_runs(C "
    #include <unistd.h>

    int main(int argc, char *argv[]) {
      char buf[64];

      /*
        Autoconf implementation uses a different return due to Autoconf's
        configure using the file descriptor 0 which results below in an error.
        The file descriptor 0 with CMake script execution is available and
        doesn't result in an error when calling ttyname_r().
      */
      return ttyname_r(0, buf, 64) ? 1 : 0;
    }
  " HAVE_TTYNAME_R)

  if(HAVE_TTYNAME_R)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
endif()

message(CHECK_START "Checking for utsname.domainname")

check_source_compiles(C "
  #ifndef _GNU_SOURCE
  #define _GNU_SOURCE
  #endif
  #include <sys/utsname.h>

  int main(void) {
    return sizeof(((struct utsname *)0)->domainname);
  }
" HAVE_UTSNAME_DOMAINNAME)

if(HAVE_UTSNAME_DOMAINNAME)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
