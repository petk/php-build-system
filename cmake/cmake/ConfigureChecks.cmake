#[=============================================================================[
Project-wide configuration checks.
#]=============================================================================]

include_guard(GLOBAL)

include(CheckFunctionExists)
include(CheckIncludeFile)
include(CheckIncludeFiles)
include(CheckSourceCompiles)
include(CheckStructHasMember)
include(CheckSymbolExists)
include(CheckTypeSize)
include(CMakePushCheckState)
include(FeatureSummary)
include(PHP/CheckAttribute)
include(PHP/SearchLibraries)

################################################################################
# Check headers.
################################################################################

check_include_file(alloca.h HAVE_ALLOCA_H)
check_include_file(arpa/inet.h HAVE_ARPA_INET_H)
check_include_file(sys/types.h HAVE_SYS_TYPES_H)

if(HAVE_SYS_TYPES_H)
  # On Solaris/illumos arpa/nameser.h depends on sys/types.h.
  check_include_files("sys/types.h;arpa/nameser.h" HAVE_ARPA_NAMESER_H)
else()
  check_include_file(arpa/nameser.h HAVE_ARPA_NAMESER_H)
endif()

check_include_file(dirent.h HAVE_DIRENT_H)
check_include_file(dlfcn.h HAVE_DLFCN_H)
check_include_file(dns.h HAVE_DNS_H)
check_include_file(fcntl.h HAVE_FCNTL_H)
check_include_file(grp.h HAVE_GRP_H)
check_include_file(ieeefp.h HAVE_IEEEFP_H)
check_include_file(langinfo.h HAVE_LANGINFO_H)
check_include_file(linux/sock_diag.h HAVE_LINUX_SOCK_DIAG_H)
check_include_file(netinet/in.h HAVE_NETINET_IN_H)
check_include_file(poll.h HAVE_POLL_H)
check_include_file(pty.h HAVE_PTY_H)
check_include_file(pwd.h HAVE_PWD_H)

# BSD-based systems (FreeBSD<=13) need also netinet/in.h for resolv.h to work.
# https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=182466
if(HAVE_NETINET_IN_H)
  check_include_files("netinet/in.h;resolv.h" HAVE_RESOLV_H)
else()
  check_include_file(resolv.h HAVE_RESOLV_H)
endif()

check_include_file(strings.h HAVE_STRINGS_H)
check_include_file(sys/file.h HAVE_SYS_FILE_H)
check_include_file(sys/ioctl.h HAVE_SYS_IOCTL_H)
check_include_file(sys/ipc.h HAVE_SYS_IPC_H)
check_include_file(sys/loadavg.h HAVE_SYS_LOADAVG_H)
check_include_file(sys/mman.h HAVE_SYS_MMAN_H)
check_include_file(sys/mount.h HAVE_SYS_MOUNT_H)
check_include_file(sys/param.h HAVE_SYS_PARAM_H)
check_include_file(sys/poll.h HAVE_SYS_POLL_H)
check_include_file(sys/resource.h HAVE_SYS_RESOURCE_H)
check_include_file(sys/select.h HAVE_SYS_SELECT_H)
check_include_file(sys/socket.h HAVE_SYS_SOCKET_H)
check_include_file(sys/stat.h HAVE_SYS_STAT_H)
check_include_file(sys/statfs.h HAVE_SYS_STATFS_H)
check_include_file(sys/statvfs.h HAVE_SYS_STATVFS_H)
check_include_file(sys/sysexits.h HAVE_SYS_SYSEXITS_H)
check_include_file(sys/time.h HAVE_SYS_TIME_H)
check_include_file(sys/uio.h HAVE_SYS_UIO_H)
check_include_file(sys/utsname.h HAVE_SYS_UTSNAME_H)
# Solaris <= 10, other systems have sys/statvfs.h.
check_include_file(sys/vfs.h HAVE_SYS_VFS_H)
check_include_file(sys/wait.h HAVE_SYS_WAIT_H)
check_include_file(sysexits.h HAVE_SYSEXITS_H)
check_include_file(syslog.h HAVE_SYSLOG_H)
check_include_file(unistd.h HAVE_UNISTD_H)
# QNX requires unix.h to allow functions in libunix to work properly.
check_include_file(unix.h HAVE_UNIX_H)
check_include_file(utime.h HAVE_UTIME_H)

# Intel Intrinsics headers.
check_include_file(tmmintrin.h HAVE_TMMINTRIN_H)
check_include_file(nmmintrin.h HAVE_NMMINTRIN_H)
check_include_file(wmmintrin.h HAVE_WMMINTRIN_H)
check_include_file(immintrin.h HAVE_IMMINTRIN_H)

################################################################################
# Check structs.
################################################################################

check_struct_has_member("struct tm" tm_gmtoff time.h HAVE_STRUCT_TM_TM_GMTOFF)
check_struct_has_member("struct tm" tm_zone time.h HAVE_STRUCT_TM_TM_ZONE)
check_struct_has_member(
  "struct stat"
  st_blksize
  sys/stat.h
  HAVE_STRUCT_STAT_ST_BLKSIZE
)
check_struct_has_member(
  "struct stat"
  st_blocks
  sys/stat.h
  HAVE_STRUCT_STAT_ST_BLOCKS
)
check_struct_has_member(
  "struct stat"
  st_rdev
  sys/stat.h
  HAVE_STRUCT_STAT_ST_RDEV
)

cmake_push_check_state(RESET)
  set(CMAKE_EXTRA_INCLUDE_FILES "fcntl.h")
  check_type_size("struct flock" STRUCT_FLOCK)
cmake_pop_check_state()

# Check for sockaddr_storage and sockaddr.sa_len.
cmake_push_check_state(RESET)
  set(CMAKE_EXTRA_INCLUDE_FILES "sys/socket.h")
  check_type_size("struct sockaddr_storage" STRUCT_SOCKADDR_STORAGE)
  check_struct_has_member(
    "struct sockaddr"
    sa_len
    "sys/socket.h"
    HAVE_STRUCT_SOCKADDR_SA_LEN
  )
cmake_pop_check_state()

################################################################################
# Check types.
################################################################################

check_type_size("gid_t" SIZEOF_GID_T)
if(NOT HAVE_SIZEOF_GID_T)
  set(
    gid_t int
    CACHE INTERNAL "Define as 'int' if <sys/types.h> doesn't define."
  )
endif()

check_type_size("int" SIZEOF_INT)
if(SIZEOF_INT STREQUAL "")
  set(SIZEOF_INT_CODE "#define SIZEOF_INT 0")
endif()

# TODO: PHP on Windows sets the SIZEOF_INTMAX_T to 0 to skip certain checks,
# otherwise the intmax_t type and its size are available. Windows-related C code
# should probably be rechecked and fixed at some point.
check_type_size("intmax_t" SIZEOF_INTMAX_T)
if(SIZEOF_INTMAX_T STREQUAL "" OR CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(SIZEOF_INTMAX_T_CODE "#define SIZEOF_INTMAX_T 0")
endif()

check_type_size("long" SIZEOF_LONG)
if(SIZEOF_LONG STREQUAL "")
  set(SIZEOF_LONG_CODE "#define SIZEOF_LONG 0")
endif()

check_type_size("long long" SIZEOF_LONG_LONG)
if(SIZEOF_LONG_LONG STREQUAL "")
  set(SIZEOF_LONG_LONG_CODE "#define SIZEOF_LONG_LONG 0")
endif()

check_type_size("off_t" SIZEOF_OFF_T)
if(SIZEOF_OFF_T STREQUAL "")
  set(SIZEOF_OFF_T_CODE "#define SIZEOF_OFF_T 0")
endif()

# TODO: The ptrdiff_t is always available by C89 standard and its size varies
# between 32-bit and 64-bit target platforms. Checking whether the ptrdiff_t
# exists is redundant and is left here as PHP still checks it conditionally in
# the intl extension.
check_type_size("ptrdiff_t" SIZEOF_PTRDIFF_T)
if(SIZEOF_PTRDIFF_T STREQUAL "")
  if(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(SIZEOF_PTRDIFF_T 4)
  else()
    set(SIZEOF_PTRDIFF_T 8)
  endif()
  set(SIZEOF_PTRDIFF_T_CODE "#define SIZEOF_PTRDIFF_T ${SIZEOF_PTRDIFF_T}")

  message(
    WARNING
    "Couldn't determine the ptrdiff_t size, setting it to ${SIZEOF_PTRDIFF_T}."
  )
endif()
set(HAVE_PTRDIFF_T 1)

check_type_size("size_t" SIZEOF_SIZE_T)
if(SIZEOF_SIZE_T STREQUAL "")
  set(SIZEOF_SIZE_T_CODE "#define SIZEOF_SIZE_T 0")
endif()

check_type_size("ssize_t" SIZEOF_SSIZE_T)
if(SIZEOF_SSIZE_T STREQUAL "")
  set(SIZEOF_SSIZE_T_CODE "#define SIZEOF_SSIZE_T 0")
endif()

check_type_size("uid_t" SIZEOF_UID_T)
if(NOT HAVE_SIZEOF_UID_T)
  set(
    uid_t int
    CACHE INTERNAL "Define as 'int' if <sys/types.h> doesn't define."
  )
endif()

# Check for socklen_t type.
cmake_push_check_state(RESET)
  if(HAVE_SYS_SOCKET_H)
    set(CMAKE_EXTRA_INCLUDE_FILES sys/socket.h)
  endif()
  check_type_size("socklen_t" SOCKLEN_T)
cmake_pop_check_state()

################################################################################
# Check builtins.
################################################################################

# Import builtins checker function.
include(PHP/CheckBuiltin)

php_check_builtin(__builtin_clz PHP_HAVE_BUILTIN_CLZ)
php_check_builtin(__builtin_clzl PHP_HAVE_BUILTIN_CLZL)
php_check_builtin(__builtin_clzll PHP_HAVE_BUILTIN_CLZLL)
php_check_builtin(__builtin_cpu_init PHP_HAVE_BUILTIN_CPU_INIT)
php_check_builtin(__builtin_cpu_supports PHP_HAVE_BUILTIN_CPU_SUPPORTS)
php_check_builtin(__builtin_ctzl PHP_HAVE_BUILTIN_CTZL)
php_check_builtin(__builtin_ctzll PHP_HAVE_BUILTIN_CTZLL)
php_check_builtin(__builtin_expect PHP_HAVE_BUILTIN_EXPECT)
php_check_builtin(__builtin_frame_address PHP_HAVE_BUILTIN_FRAME_ADDRESS)
php_check_builtin(__builtin_saddl_overflow PHP_HAVE_BUILTIN_SADDL_OVERFLOW)
php_check_builtin(__builtin_saddll_overflow PHP_HAVE_BUILTIN_SADDLL_OVERFLOW)
php_check_builtin(__builtin_smull_overflow PHP_HAVE_BUILTIN_SMULL_OVERFLOW)
php_check_builtin(__builtin_smulll_overflow PHP_HAVE_BUILTIN_SMULLL_OVERFLOW)
php_check_builtin(__builtin_ssubl_overflow PHP_HAVE_BUILTIN_SSUBL_OVERFLOW)
php_check_builtin(__builtin_ssubll_overflow PHP_HAVE_BUILTIN_SSUBLL_OVERFLOW)
php_check_builtin(__builtin_unreachable PHP_HAVE_BUILTIN_UNREACHABLE)
php_check_builtin(__builtin_usub_overflow PHP_HAVE_BUILTIN_USUB_OVERFLOW)

################################################################################
# Check compiler characteristics.
################################################################################

# Check AVX-512 extensions.
include(PHP/CheckAVX512)

# Check for asm goto.
message(CHECK_START "Checking for asm goto support")
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_source_compiles(C [[
    int main(void)
    {
      #if defined(__x86_64__) || defined(__i386__)
        __asm__ goto("jmp %l0\n" :::: end);
      #elif defined(__aarch64__)
        __asm__ goto("b %l0\n" :::: end);
      #endif
      end:
        return 0;
    }
  ]] HAVE_ASM_GOTO)
cmake_pop_check_state()
if(HAVE_ASM_GOTO)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

################################################################################
# Check functions.
################################################################################

check_symbol_exists(alphasort "dirent.h" HAVE_ALPHASORT)
check_symbol_exists(chroot "unistd.h" HAVE_CHROOT)
check_symbol_exists(explicit_memset "string.h" HAVE_EXPLICIT_MEMSET)
check_symbol_exists(fdatasync "unistd.h" HAVE_FDATASYNC)
# The fdatasync declaration on macOS is missing in headers, yet is in C library.
if(NOT HAVE_FDATASYNC)
  unset(HAVE_FDATASYNC CACHE)
  check_function_exists(fdatasync HAVE_FDATASYNC)
endif()

block()
  if(HAVE_FCNTL_H)
    list(APPEND headers "fcntl.h")
  endif()

  if(HAVE_SYS_FILE_H)
    list(APPEND headers "sys/file.h")
  endif()

  check_symbol_exists(flock "${headers}" HAVE_FLOCK)
endblock()

check_symbol_exists(ftok "sys/ipc.h" HAVE_FTOK)
check_symbol_exists(funopen "stdio.h" HAVE_FUNOPEN)
check_symbol_exists(getcwd "unistd.h" HAVE_GETCWD)

block()
  set(headers stdlib.h)

  # illumos: https://www.illumos.org/issues/9021
  if(HAVE_SYS_TYPES_H)
    list(APPEND headers sys/types.h)
  endif()

  # Solaris, illumos.
  if(HAVE_SYS_LOADAVG_H)
    list(APPEND headers sys/loadavg.h)
  endif()

  check_symbol_exists(getloadavg "${headers}" HAVE_GETLOADAVG)
endblock()

check_symbol_exists(getlogin "unistd.h" HAVE_GETLOGIN)
check_symbol_exists(getrusage "sys/resource.h" HAVE_GETRUSAGE)
check_symbol_exists(gettimeofday "sys/time.h" HAVE_GETTIMEOFDAY)
check_symbol_exists(getpwnam_r "pwd.h" HAVE_GETPWNAM_R)
check_symbol_exists(getgrnam_r "grp.h" HAVE_GETGRNAM_R)
check_symbol_exists(getpwuid_r "pwd.h" HAVE_GETPWUID_R)
check_symbol_exists(getwd "unistd.h" HAVE_GETWD)
check_symbol_exists(glob "glob.h" HAVE_GLOB)
check_symbol_exists(lchown "unistd.h" HAVE_LCHOWN)
check_symbol_exists(memcntl "sys/mman.h" HAVE_MEMCNTL)

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(memfd_create "sys/mman.h" HAVE_MEMFD_CREATE)
cmake_pop_check_state()

check_symbol_exists(mkstemp "stdlib.h" HAVE_MKSTEMP)
check_symbol_exists(mmap "sys/mman.h" HAVE_MMAP)
check_symbol_exists(nice "unistd.h" HAVE_NICE)
check_symbol_exists(nl_langinfo "langinfo.h" HAVE_NL_LANGINFO)
check_symbol_exists(prctl "sys/prctl.h" HAVE_PRCTL)
check_symbol_exists(procctl "sys/procctl.h" HAVE_PROCCTL)
check_symbol_exists(poll "poll.h" HAVE_POLL)
check_symbol_exists(
  pthread_jit_write_protect_np
  "pthread.h"
  HAVE_PTHREAD_JIT_WRITE_PROTECT_NP
)
check_symbol_exists(putenv "stdlib.h" HAVE_PUTENV)
check_symbol_exists(scandir "dirent.h" HAVE_SCANDIR)
check_symbol_exists(setitimer "sys/time.h" HAVE_SETITIMER)
check_symbol_exists(setenv "stdlib.h" HAVE_SETENV)
check_symbol_exists(sigprocmask "signal.h" HAVE_SIGPROCMASK)

# Check for statfs().
block()
  set(headers "")

  # BSD-based systems have statfs in sys/mount.h.
  if(HAVE_SYS_MOUNT_H)
    list(APPEND headers "sys/mount.h")
  endif()

  if(HAVE_SYS_STATFS_H)
    list(APPEND headers "sys/statfs.h")
  endif()

  check_symbol_exists(statfs "${headers}" HAVE_STATFS)
endblock()

check_symbol_exists(statvfs "sys/statvfs.h" HAVE_STATVFS)
check_symbol_exists(std_syslog "sys/syslog.h" HAVE_STD_SYSLOG)
check_symbol_exists(strcasecmp "strings.h" HAVE_STRCASECMP)
check_symbol_exists(strnlen "string.h" HAVE_STRNLEN)
check_symbol_exists(symlink "unistd.h" HAVE_SYMLINK)
check_symbol_exists(tzset "time.h" HAVE_TZSET)
check_symbol_exists(unsetenv "stdlib.h" HAVE_UNSETENV)
check_symbol_exists(usleep "unistd.h" HAVE_USLEEP)
check_symbol_exists(utime "utime.h" HAVE_UTIME)

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(vasprintf "stdio.h" HAVE_VASPRINTF)
cmake_pop_check_state()

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(asprintf "stdio.h" HAVE_ASPRINTF)
cmake_pop_check_state()

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(memmem "string.h" HAVE_MEMMEM)
cmake_pop_check_state()

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(memrchr "string.h" HAVE_MEMRCHR)
cmake_pop_check_state()

check_symbol_exists(strlcat "string.h" HAVE_STRLCAT)
check_symbol_exists(strlcpy "string.h" HAVE_STRLCPY)
check_symbol_exists(explicit_bzero "string.h" HAVE_EXPLICIT_BZERO)

# Check reentrant functions.
include(PHP/CheckReentrantFunctions)

# Check fopencookie.
include(PHP/CheckFopencookie)

# Some systems, notably Solaris, cause getcwd() or realpath to fail if a
# component of the path has execute but not read permissions.
message(CHECK_START "Checking for broken getcwd()")
if(CMAKE_SYSTEM_NAME STREQUAL "SunOS")
  set(HAVE_BROKEN_GETCWD 1 CACHE INTERNAL "Define if system has broken getcwd")
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

# Check getaddrinfo().
include(PHP/CheckGetaddrinfo)
if(TARGET PHP::CheckGetaddrinfoLibrary)
  target_link_libraries(
    php_configuration
    INTERFACE
      PHP::CheckGetaddrinfoLibrary
  )
endif()

# Check copy_file_range().
include(PHP/CheckCopyFileRange)

# Check type of reentrant time-related functions.
include(PHP/CheckTimeR)

# Check whether writing to stdout works.
include(PHP/CheckWrite)

################################################################################
# Miscellaneous checks.
################################################################################

# Checking file descriptor sets.
message(CHECK_START "Checking file descriptor sets size")
if(PHP_FD_SETSIZE MATCHES "^[0-9]+$" AND PHP_FD_SETSIZE GREATER 0)
  message(CHECK_PASS "using FD_SETSIZE=${PHP_FD_SETSIZE}")
  target_compile_definitions(
    php_configuration
    INTERFACE
      $<$<COMPILE_LANGUAGE:ASM,C,CXX>:FD_SETSIZE=${PHP_FD_SETSIZE}>
  )
elseif(NOT PHP_FD_SETSIZE STREQUAL "")
  message(
    FATAL_ERROR
    "Invalid value of PHP_FD_SETSIZE=${PHP_FD_SETSIZE}. Pass integer greater "
    "than 0."
  )
else()
  message(CHECK_PASS "using system default")
endif()

# Check target system byte order.
include(PHP/CheckByteOrder)

# Check for IPv6 support.
if(PHP_IPV6)
  include(PHP/CheckIPv6)
endif()

# Check how flush should be called.
include(PHP/CheckFlushIo)

# Check for aarch64 CRC32 API.
message(CHECK_START "Checking for aarch64 CRC32 API availability")
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_source_compiles(C [[
    #include <arm_acle.h>
    # if defined(__GNUC__)
    #  if!defined(__clang__)
    #   pragma GCC push_options
    #   pragma GCC target ("+nothing+crc")
    #  elif defined(__APPLE__)
    #   pragma clang attribute push(__attribute__((target("crc"))), apply_to=function)
    #  else
    #   pragma clang attribute push(__attribute__((target("+nothing+crc"))), apply_to=function)
    #  endif
    # endif
    int main(void)
    {
      __crc32d(0, 0);
      return 0;
    }
  ]] HAVE_AARCH64_CRC32)
cmake_pop_check_state()
if(HAVE_AARCH64_CRC32)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

if(HAVE_ALLOCA_H)
  # Most *.nix systems.
  check_symbol_exists(alloca "alloca.h" HAVE_ALLOCA)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  check_symbol_exists(alloca "malloc.h" HAVE_ALLOCA)
else()
  # BSD-based systems.
  check_symbol_exists(alloca "stdlib.h" HAVE_ALLOCA)
endif()

message(CHECK_START "Checking whether the compiler supports __alignof__")
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_source_compiles(C [[
    int main(void)
    {
      int align = __alignof__(int);
      (void)align;
      return 0;
    }
  ]] HAVE_ALIGNOF)
cmake_pop_check_state()
if(HAVE_ALIGNOF)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

# Check for GCC function attributes on all systems except ones without glibc.
# Fix for these systems is already included in GCC 7, but not on GCC 6. At least
# some versions of FreeBSD seem to have buggy ifunc support, see
# https://bugs.php.net/77284. Conservatively don't use ifuncs on FreeBSD prior
# to version 12.
if(
  (
    NOT CMAKE_SYSTEM_NAME MATCHES "^(Android|FreeBSD|OpenBSD)$"
    AND NOT PHP_C_STANDARD_LIBRARY MATCHES "^(musl|uclibc)$"
  ) OR (
    CMAKE_SYSTEM_NAME STREQUAL "FreeBSD"
    AND CMAKE_SYSTEM_VERSION VERSION_GREATER_EQUAL 12
  )
)
  php_check_function_attribute(ifunc HAVE_FUNC_ATTRIBUTE_IFUNC)
  php_check_function_attribute(target HAVE_FUNC_ATTRIBUTE_TARGET)
endif()

# Check for variable __attribute__((aligned)) support in the compiler.
php_check_variable_attribute(aligned HAVE_ATTRIBUTE_ALIGNED)

include(PHP/CheckGethostbynameR)
if(TARGET PHP::CheckGethostbynameR)
  target_link_libraries(php_configuration INTERFACE PHP::CheckGethostbynameR)
endif()

if(PHP_CCACHE)
  find_package(Ccache)
endif()

# Check GCOV.
if(PHP_GCOV)
  if(NOT CMAKE_C_COMPILER_ID STREQUAL "GNU")
    message(FATAL_ERROR "GCC is required for using PHP_GCOV='ON'")
  endif()

  # Check if ccache is being used.
  if(CMAKE_C_COMPILER_LAUNCHER MATCHES "ccache")
    message(
      WARNING
      "ccache should be disabled when PHP_GCOV='ON' option is used. You can "
      "disable ccache by setting option PHP_CCACHE='OFF' or environment "
      "variable CCACHE_DISABLE=1."
    )
  endif()

  find_package(Gcov)
  set_package_properties(
    Gcov
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable GCOV coverage report and symbols."
  )

  if(TARGET Gcov::Gcov)
    target_link_libraries(php_configuration INTERFACE Gcov::Gcov)

    gcov_generate_report()
  endif()
endif()

################################################################################
# Check for required libraries.
################################################################################

php_search_libraries(
  dlopen
  HAVE_LIBDL
  HEADERS dlfcn.h
  LIBRARIES
    ${CMAKE_DL_LIBS}
  TARGET php_configuration INTERFACE
)

php_search_libraries(
  sin
  HAVE_SIN
  HEADERS math.h
  LIBRARIES m
  TARGET php_configuration INTERFACE
)

if(CMAKE_SYSTEM_PROCESSOR MATCHES "^riscv64.*")
  find_package(Atomic)

  if(Atomic_FOUND)
    target_link_libraries(php_configuration INTERFACE Atomic::Atomic)
  endif()
endif()

# The socket() is mostly in C library (Solaris 11.4...)
php_search_libraries(
  socket
  HAVE_SOCKET
  HEADERS
    sys/socket.h
    winsock.h
  LIBRARIES
    socket  # Solaris <= 11.3, illumos
    network # Haiku
    ws2_32  # Windows
  TARGET php_configuration INTERFACE
)

# The socketpair() is mostly in C library (Solaris 11.4...), except Windows.
php_search_libraries(
  socketpair
  HAVE_SOCKETPAIR
  HEADERS sys/socket.h
  LIBRARIES
    socket  # Solaris <= 11.3, illumos
    network # Haiku
  TARGET php_configuration INTERFACE
)

# The gethostname() is mostly in C library (Solaris/illumos...)
php_search_libraries(
  gethostname
  HAVE_GETHOSTNAME
  HEADERS
    unistd.h
    winsock.h
  LIBRARIES
    network # Haiku
    ws2_32  # Windows
  TARGET php_configuration INTERFACE
)

# The gethostbyaddr() is mostly in C library (Solaris 11.4...)
php_search_libraries(
  gethostbyaddr
  HAVE_GETHOSTBYADDR
  HEADERS
    netdb.h
    sys/socket.h
    winsock.h
  LIBRARIES
    nsl     # Solaris <= 11.3, illumos
    network # Haiku
    ws2_32  # Windows
  TARGET php_configuration INTERFACE
)

# The openpty() can be in C library (Solaris 11.4+, Linux, etc). Solaris <= 11.3
# and illumos don't have it.
php_search_libraries(
  openpty
  HAVE_OPENPTY
  HEADERS
    pty.h
    libutil.h # FreeBSD
    util.h    # macOS
    termios.h # Solaris, illumos, some BSD-based systems
  LIBRARIES
    util # Some BSD-based systems
    bsd  # Haiku
  TARGET php_configuration INTERFACE
)

# The inet_ntop() is mostly in C library (Solaris 11.4, illumos, BSD*, Linux...)
php_search_libraries(
  inet_ntop
  _HAVE_INET_NTOP
  HEADERS
    arpa/inet.h
    ws2tcpip.h
  LIBRARIES
    nsl     # Solaris <= 11.3
    resolv  # Solaris 2.6..7
    network # Haiku
    ws2_32  # Windows
  TARGET php_configuration INTERFACE
)
if(NOT _HAVE_INET_NTOP)
  message(FATAL_ERROR "Required inet_ntop not found.")
endif()

# The inet_pton() is mostly in C library (Solaris 11.4, illumos...)
php_search_libraries(
  inet_pton
  _HAVE_INET_PTON
  HEADERS
    arpa/inet.h
    ws2tcpip.h
  LIBRARIES
    nsl     # Solaris <= 11.3
    resolv  # Solaris 2.6..7
    network # Haiku
    ws2_32  # Windows
  TARGET php_configuration INTERFACE
)
if(NOT _HAVE_INET_PTON)
  message(FATAL_ERROR "Required inet_pton not found.")
endif()

# The nanosleep is mostly in C library (Solaris 11, illumos...)
php_search_libraries(
  nanosleep
  HAVE_NANOSLEEP
  HEADERS
    time.h
  LIBRARIES
    rt # Solaris <= 10
  TARGET php_configuration INTERFACE
)

# The setsockopt() is mostly in C library (Solaris 11.4...)
php_search_libraries(
  setsockopt
  HAVE_SETSOCKOPT
  HEADERS
    sys/types.h
    sys/socket.h
    winsock.h
  LIBRARIES
    socket  # Solaris <= 11.3, illumos
    network # Haiku
    ws2_32  # Windows
  TARGET php_configuration INTERFACE
)

# Check for Solaris/illumos process mapping.
php_search_libraries(
  Pgrab
  HAVE_PGRAB
  HEADERS libproc.h
  LIBRARIES proc
  TARGET php_configuration INTERFACE
)

# The gai_strerror() is mostly in C library (Solaris 11.4...)
php_search_libraries(
  gai_strerror
  HAVE_GAI_STRERROR
  HEADERS netdb.h
  LIBRARIES
    socket  # Solaris <= 11.3, illumos
    network # Haiku
  TARGET php_configuration INTERFACE
)

# The getprotobyname() is mostly in C library (Solaris 11.4...)
php_search_libraries(
  getprotobyname
  HAVE_GETPROTOBYNAME
  HEADERS
    netdb.h
    winsock.h
  LIBRARIES
    socket  # Solaris <= 11.3, illumos
    network # Haiku
    ws2_32  # Windows
  TARGET php_configuration INTERFACE
)

# The getprotobynumber() is mostly in C library (Solaris 11.4...)
php_search_libraries(
  getprotobynumber
  HAVE_GETPROTOBYNUMBER
  HEADERS
    netdb.h
    winsock.h
  LIBRARIES
    socket  # Solaris <= 11.3, illumos
    network # Haiku
    ws2_32  # Windows
  TARGET php_configuration INTERFACE
)

# The getservbyname() is mostly in C library (Solaris 11.4...)
php_search_libraries(
  getservbyname
  HAVE_GETSERVBYNAME
  HEADERS
    netdb.h
    winsock.h
  LIBRARIES
    socket  # Solaris <= 11.3, illumos
    network # Haiku
    ws2_32  # Windows
  TARGET php_configuration INTERFACE
)

# The getservbyport() is mostly in C library (Solaris 11.4...)
php_search_libraries(
  getservbyport
  HAVE_GETSERVBYPORT
  HEADERS
    netdb.h
    winsock.h
  LIBRARIES
    socket  # Solaris <= 11.3, illumos
    network # Haiku
    ws2_32  # Windows
  TARGET php_configuration INTERFACE
)

# The shutdown() is mostly in C library (Solaris 11.4...)
php_search_libraries(
  shutdown
  HAVE_SHUTDOWN
  HEADERS
    sys/socket.h
    winsock.h
  LIBRARIES
    socket  # Solaris <= 11.3, illumos
    network # Haiku
    ws2_32  # Windows
  TARGET php_configuration INTERFACE
)

block()
  if(PHP_LIBGCC)
    execute_process(
      COMMAND gcc --print-libgcc-file-name
      OUTPUT_VARIABLE libgcc_path
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(NOT EXISTS "${libgcc_path}")
      message(FATAL_ERROR "Cannot locate libgcc.")
    endif()

    message(STATUS "Explicitly linking against libgcc (${libgcc_path})")

    target_link_libraries(php_configuration INTERFACE ${libgcc_path})
  endif()
endblock()
