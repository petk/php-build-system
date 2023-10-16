include(CheckCSourceCompiles)
include(CheckCSourceRuns)
include(CheckIncludeFile)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)

option(EXT_POSIX "Whether to enable POSIX-like functions" ON)

cmake_dependent_option(
  EXT_POSIX_SHARED
  "Whether to build the POSIX extension as shared object"
  OFF
  "EXT_POSIX;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_POSIX)
  return()
endif()

if(EXT_POSIX_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "posix" ${_library_type})

check_include_file(sys/mkdev.h HAVE_SYS_MKDEV_H)
check_include_file(sys/sysmacros.h HAVE_SYS_SYSMACROS_H)

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
check_symbol_exists(initgroups "grp.h" HAVE_INITGROUPS)
check_symbol_exists(makedev "sys/sysmacros.h" HAVE_MAKEDEV)
check_symbol_exists(mkfifo "sys/stat.h" HAVE_MKFIFO)
check_symbol_exists(mknod "sys/stat.h" HAVE_MKNOD)
check_symbol_exists(pathconf "unistd.h" HAVE_PATHCONF)
check_symbol_exists(setegid "unistd.h" HAVE_SETEGID)
check_symbol_exists(seteuid "unistd.h" HAVE_SETEUID)
check_symbol_exists(setrlimit "sys/resource.h" HAVE_SETRLIMIT)
check_symbol_exists(setsid "unistd.h" HAVE_SETSID)

message(STATUS "Checking for working ttyname_r() implementation")
if(CMAKE_CROSSCOMPILING)
  message(STATUS "no, cannot detect working ttyname_r() when cross compiling. posix_ttyname() will be thread-unsafe")
else()
  check_c_source_runs("
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
endif()

message(STATUS "Checking for utsname.domainname")
check_c_source_compiles("
  #define _GNU_SOURCE
  #include <sys/utsname.h>

  int main(void) {
    return sizeof(((struct utsname *)0)->domainname);
  }
" HAVE_UTSNAME_DOMAINNAME)

add_library(php_posix ${_library_type}
  posix.c
)

target_compile_definitions(php_posix PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)
