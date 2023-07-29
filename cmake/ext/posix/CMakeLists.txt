include(CheckCSourceCompiles)
include(CheckCSourceRuns)
include(CheckIncludeFile)
include(CheckSymbolExists)
include(CMakePushCheckState)

option(posix "Whether to enable POSIX-like functions" ON)

if(posix)
  project(ext_posix VERSION ${CMAKE_PROJECT_VERSION} DESCRIPTION "POSIX PHP extension")

  string(TOLOWER ${posix} posix_lower)
  set(posix_library_type "STATIC")
  if(posix_lower STREQUAL "shared")
    set(posix_library_type "SHARED")
  endif()

  php_extension(NAME "posix" ${posix_library_type})

  check_include_file(sys/mkdev.h HAVE_SYS_MKDEV_H)
  check_include_file(sys/sysmacros.h HAVE_SYS_SYSMACROS_H)

  check_symbol_exists(ctermid "stdio.h" HAVE_CTERMID)

  cmake_push_check_state()
    set(CMAKE_REQUIRED_DEFINITIONS "${CMAKE_REQUIRED_DEFINITIONS} -D_GNU_SOURCE")
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
    try_run(
      RUN_RESULT_VAR
      COMPILE_RESULT_VAR
      ${CMAKE_BINARY_DIR}
      "${CMAKE_SOURCE_DIR}/cmake/posix_ttyname_test.c"
    )

    if(RUN_RESULT_VAR EQUAL 0 AND COMPILE_RESULT_VAR)
      set(HAVE_TTYNAME_R 1 CACHE STRING "Whether you have a working ttyname_r")
      message(STATUS "yes")
    else()
      message(STATUS "no, posix_ttyname() will be thread-unsafe")
    endif()
  endif()

  message(STATUS "Checking for utsname.domainname")
  if(CMAKE_CROSSCOMPILING)
    message(STATUS "no (cross compiling)")
  else()
    check_c_source_compiles("
      #define _GNU_SOURCE
      #include <sys/utsname.h>

      int main()
      {
        return sizeof(((struct utsname *)0)->domainname);
      }
    " HAVE_UTSNAME_DOMAINNAME)

    if(HAVE_UTSNAME_DOMAINNAME)
      set(HAVE_UTSNAME_DOMAINNAME 1 CACHE STRING "Whether struct utsname has domainname")
      message(STATUS "yes")
    else()
      message(STATUS "no")
    endif()
  endif()

  add_library(ext_posix ${posix_library_type}
    posix.c
  )

  target_compile_definitions(ext_posix PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

  target_include_directories(
    ext_posix
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
  )
endif()
