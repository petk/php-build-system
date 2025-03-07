#[=============================================================================[
Project-wide configuration checks.
#]=============================================================================]

include_guard(GLOBAL)

include(CheckFunctionExists)
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

check_include_files(alloca.h HAVE_ALLOCA_H)
check_include_files(arpa/inet.h HAVE_ARPA_INET_H)
check_include_files(sys/types.h HAVE_SYS_TYPES_H)

if(HAVE_SYS_TYPES_H)
  # On Solaris/illumos arpa/nameser.h depends on sys/types.h.
  check_include_files("sys/types.h;arpa/nameser.h" HAVE_ARPA_NAMESER_H)
else()
  check_include_files(arpa/nameser.h HAVE_ARPA_NAMESER_H)
endif()

check_include_files(dirent.h HAVE_DIRENT_H)
check_include_files(dlfcn.h HAVE_DLFCN_H)
check_include_files(dns.h HAVE_DNS_H)
check_include_files(fcntl.h HAVE_FCNTL_H)
check_include_files(grp.h HAVE_GRP_H)
check_include_files(ieeefp.h HAVE_IEEEFP_H)
check_include_files(langinfo.h HAVE_LANGINFO_H)
check_include_files(linux/sock_diag.h HAVE_LINUX_SOCK_DIAG_H)
check_include_files(netinet/in.h HAVE_NETINET_IN_H)
check_include_files(os/signpost.h HAVE_OS_SIGNPOST_H)
check_include_files(poll.h HAVE_POLL_H)
check_include_files(pty.h HAVE_PTY_H)
check_include_files(pwd.h HAVE_PWD_H)

# BSD-based systems (FreeBSD<=13) need also netinet/in.h for resolv.h to work.
# https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=182466
if(HAVE_NETINET_IN_H)
  check_include_files("netinet/in.h;resolv.h" HAVE_RESOLV_H)
else()
  check_include_files(resolv.h HAVE_RESOLV_H)
endif()

check_include_files(strings.h HAVE_STRINGS_H)
check_include_files(sys/file.h HAVE_SYS_FILE_H)
check_include_files(sys/ioctl.h HAVE_SYS_IOCTL_H)
check_include_files(sys/ipc.h HAVE_SYS_IPC_H)
check_include_files(sys/loadavg.h HAVE_SYS_LOADAVG_H)
check_include_files(sys/mman.h HAVE_SYS_MMAN_H)
check_include_files(sys/mount.h HAVE_SYS_MOUNT_H)
check_include_files(sys/param.h HAVE_SYS_PARAM_H)
check_include_files(sys/poll.h HAVE_SYS_POLL_H)
check_include_files(sys/procctl.h HAVE_SYS_PROCCTL_H)
check_include_files(sys/resource.h HAVE_SYS_RESOURCE_H)
check_include_files(sys/select.h HAVE_SYS_SELECT_H)
check_include_files(sys/socket.h HAVE_SYS_SOCKET_H)
check_include_files(sys/stat.h HAVE_SYS_STAT_H)
check_include_files(sys/statfs.h HAVE_SYS_STATFS_H)
check_include_files(sys/statvfs.h HAVE_SYS_STATVFS_H)
check_include_files(sys/sysexits.h HAVE_SYS_SYSEXITS_H)
check_include_files(sys/time.h HAVE_SYS_TIME_H)
check_include_files(sys/uio.h HAVE_SYS_UIO_H)
check_include_files(sys/utsname.h HAVE_SYS_UTSNAME_H)
# Solaris <= 10, other systems have sys/statvfs.h.
check_include_files(sys/vfs.h HAVE_SYS_VFS_H)
check_include_files(sys/wait.h HAVE_SYS_WAIT_H)
check_include_files(sysexits.h HAVE_SYSEXITS_H)
check_include_files(syslog.h HAVE_SYSLOG_H)
check_include_files(unistd.h HAVE_UNISTD_H)
# QNX requires unix.h to allow functions in libunix to work properly.
check_include_files(unix.h HAVE_UNIX_H)
check_include_files(utime.h HAVE_UTIME_H)

# Intel Intrinsics headers.
check_include_files(tmmintrin.h HAVE_TMMINTRIN_H)
check_include_files(nmmintrin.h HAVE_NMMINTRIN_H)
check_include_files(wmmintrin.h HAVE_WMMINTRIN_H)
check_include_files(immintrin.h HAVE_IMMINTRIN_H)

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
  check_type_size("struct sockaddr_storage" SOCKADDR_STORAGE)
  check_struct_has_member(
    "struct sockaddr"
    sa_len
    "sys/socket.h"
    HAVE_SOCKADDR_SA_LEN
  )
cmake_pop_check_state()

################################################################################
# Check types.
################################################################################

check_type_size("gid_t" SIZEOF_GID_T)
if(NOT HAVE_SIZEOF_GID_T)
  set(
    gid_t
    int
    CACHE INTERNAL
    "Define as 'int' if not defined in <sys/types.h>."
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
set(HAVE_PTRDIFF_T TRUE)

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
    uid_t
    int
    CACHE INTERNAL
    "Define as 'int' if not defined in <sys/types.h>."
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
php_check_builtin(__builtin_usub_overflow PHP_HAVE_BUILTIN_USUB_OVERFLOW)

################################################################################
# Check compiler characteristics.
################################################################################

# Check compiler inline keyword.
include(PHP/CheckInline)

# Check AVX-512 extensions.
include(PHP/CheckAVX512)

################################################################################
# Check functions.
################################################################################

check_symbol_exists(alphasort "dirent.h" HAVE_ALPHASORT)
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
  set(HAVE_BROKEN_GETCWD TRUE)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

# Check getaddrinfo().
include(PHP/CheckGetaddrinfo)
if(TARGET PHP::CheckGetaddrinfoLibrary)
  target_link_libraries(php_config INTERFACE PHP::CheckGetaddrinfoLibrary)
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
    php_config
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
include(PHP/CheckIPv6)

# Check how flush should be called.
include(PHP/CheckFlushIo)

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
  target_link_libraries(php_config INTERFACE PHP::CheckGethostbynameR)
endif()

################################################################################
# Check for required libraries.
################################################################################

php_search_libraries(
  dlopen
  HEADERS dlfcn.h
  LIBRARIES ${CMAKE_DL_LIBS}
  VARIABLE HAVE_LIBDL
  TARGET php_config INTERFACE
)

php_search_libraries(
  sin
  HEADERS math.h
  LIBRARIES m
  TARGET php_config INTERFACE
)

if(CMAKE_SYSTEM_PROCESSOR MATCHES "^riscv64.*")
  find_package(Atomic)

  if(Atomic_FOUND)
    target_link_libraries(php_config INTERFACE Atomic::Atomic)
  endif()
endif()

# The socket() is mostly in C library (Solaris 11.4...)
php_search_libraries(
  socket
  HEADERS
    sys/socket.h
    winsock.h
  LIBRARIES
    socket  # Solaris <= 11.3, illumos
    network # Haiku
    ws2_32  # Windows
  TARGET php_config INTERFACE
)

# The socketpair() is mostly in C library (Solaris 11.4...), except Windows.
php_search_libraries(
  socketpair
  HEADERS sys/socket.h
  LIBRARIES
    socket  # Solaris <= 11.3, illumos
    network # Haiku
  VARIABLE HAVE_SOCKETPAIR
  TARGET php_config INTERFACE
)

# The gethostname() is mostly in C library (Solaris/illumos...)
php_search_libraries(
  gethostname
  HEADERS
    unistd.h
    winsock.h
  LIBRARIES
    network # Haiku
    ws2_32  # Windows
  VARIABLE HAVE_GETHOSTNAME
  TARGET php_config INTERFACE
)

# The gethostbyaddr() is mostly in C library (Solaris 11.4...)
php_search_libraries(
  gethostbyaddr
  HEADERS
    netdb.h
    sys/socket.h
    winsock.h
  LIBRARIES
    nsl     # Solaris <= 11.3, illumos
    network # Haiku
    ws2_32  # Windows
  TARGET php_config INTERFACE
)

# The openpty() can be in C library (Solaris 11.4+, Linux, etc). Solaris <= 11.3
# and illumos don't have it.
php_search_libraries(
  openpty
  HEADERS
    pty.h
    libutil.h # FreeBSD
    util.h    # macOS
    termios.h # Solaris, illumos, some BSD-based systems
  LIBRARIES
    util # Some BSD-based systems
    bsd  # Haiku
  VARIABLE HAVE_OPENPTY
  TARGET php_config INTERFACE
)

# The inet_ntoa() is mostly in C library (Solaris 11.4, illumos...)
php_search_libraries(
  inet_ntoa
  HEADERS arpa/inet.h
  LIBRARIES
    nsl     # Solaris <= 11.3
    network # Haiku
  VARIABLE HAVE_INET_NTOA
  TARGET php_config INTERFACE
)

# The inet_ntop() is mostly in C library (Solaris 11.4, illumos, BSD*, Linux...)
php_search_libraries(
  inet_ntop
  HEADERS
    arpa/inet.h
    ws2tcpip.h
  LIBRARIES
    nsl     # Solaris <= 11.3
    resolv  # Solaris 2.6..7
    network # Haiku
    ws2_32  # Windows
  VARIABLE HAVE_INET_NTOP
  TARGET php_config INTERFACE
)
if(NOT HAVE_INET_NTOP)
  message(FATAL_ERROR "Cannot find 'inet_ntop()' which is required.")
endif()

# The inet_pton() is mostly in C library (Solaris 11.4, illumos...)
php_search_libraries(
  inet_pton
  HEADERS
    arpa/inet.h
    ws2tcpip.h
  LIBRARIES
    nsl     # Solaris <= 11.3
    resolv  # Solaris 2.6..7
    network # Haiku
    ws2_32  # Windows
  VARIABLE HAVE_INET_PTON
  TARGET php_config INTERFACE
)

# The inet_aton() is mostly in C library (Solaris 11.4, illumos...)
php_search_libraries(
  inet_aton
  HEADERS
    sys/socket.h
    netinet/in.h
    arpa/inet.h
  LIBRARIES
    nsl     # Solaris <= 11.3
    resolv  # Solaris 2.6..7
    network # Haiku
  VARIABLE HAVE_INET_ATON
  TARGET php_config INTERFACE
)

# The nanosleep is mostly in C library (Solaris 11, illumos...)
php_search_libraries(
  nanosleep
  HEADERS
    time.h
  LIBRARIES
    rt # Solaris <= 10
  VARIABLE HAVE_NANOSLEEP
  TARGET php_config INTERFACE
)

# The setsockopt() is mostly in C library (Solaris 11.4...)
php_search_libraries(
  setsockopt
  HEADERS
    sys/types.h
    sys/socket.h
    winsock.h
  LIBRARIES
    socket  # Solaris <= 11.3, illumos
    network # Haiku
    ws2_32  # Windows
  TARGET php_config INTERFACE
)

# The gai_strerror() is mostly in C library (Solaris 11.4...)
php_search_libraries(
  gai_strerror
  HEADERS netdb.h
  LIBRARIES
    socket  # Solaris <= 11.3, illumos
    network # Haiku
  VARIABLE HAVE_GAI_STRERROR
  TARGET php_config INTERFACE
)

# The getprotobyname() is mostly in C library (Solaris 11.4...)
php_search_libraries(
  getprotobyname
  HEADERS
    netdb.h
    winsock.h
  LIBRARIES
    socket  # Solaris <= 11.3, illumos
    network # Haiku
    ws2_32  # Windows
  VARIABLE HAVE_GETPROTOBYNAME
  TARGET php_config INTERFACE
)

# The getprotobynumber() is mostly in C library (Solaris 11.4...)
php_search_libraries(
  getprotobynumber
  HEADERS
    netdb.h
    winsock.h
  LIBRARIES
    socket  # Solaris <= 11.3, illumos
    network # Haiku
    ws2_32  # Windows
  VARIABLE HAVE_GETPROTOBYNUMBER
  TARGET php_config INTERFACE
)

# The getservbyname() is mostly in C library (Solaris 11.4...)
php_search_libraries(
  getservbyname
  HEADERS
    netdb.h
    winsock.h
  LIBRARIES
    socket  # Solaris <= 11.3, illumos
    network # Haiku
    ws2_32  # Windows
  VARIABLE HAVE_GETSERVBYNAME
  TARGET php_config INTERFACE
)

# The getservbyport() is mostly in C library (Solaris 11.4...)
php_search_libraries(
  getservbyport
  HEADERS
    netdb.h
    winsock.h
  LIBRARIES
    socket  # Solaris <= 11.3, illumos
    network # Haiku
    ws2_32  # Windows
  VARIABLE HAVE_GETSERVBYPORT
  TARGET php_config INTERFACE
)

# The shutdown() is mostly in C library (Solaris 11.4...)
php_search_libraries(
  shutdown
  HEADERS
    sys/socket.h
    winsock.h
  LIBRARIES
    socket  # Solaris <= 11.3, illumos
    network # Haiku
    ws2_32  # Windows
  VARIABLE HAVE_SHUTDOWN
  TARGET php_config INTERFACE
)

block()
  if(PHP_LIBGCC)
    execute_process(
      COMMAND gcc --print-libgcc-file-name
      OUTPUT_VARIABLE path
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(NOT EXISTS "${path}")
      message(FATAL_ERROR "The libgcc path not found ${path}")
    endif()

    message(STATUS "Explicitly linking against libgcc (${path})")

    target_link_libraries(php_config INTERFACE ${path})
  endif()
endblock()

################################################################################
# Check for additional tools.
################################################################################

if(PHP_CCACHE)
  find_package(Ccache)
endif()

# Check GCOV.
if(PHP_GCOV)
  if(NOT CMAKE_C_COMPILER_ID MATCHES "^(.*Clang|GNU)$")
    message(
      FATAL_ERROR
      "GNU-compatible compiler is required for using PHP_GCOV='ON'."
    )
  endif()

  if(CMAKE_C_COMPILER_LAUNCHER MATCHES "ccache")
    message(
      WARNING
      "When 'PHP_GCOV' is enabled, ccache should be disabled by setting the "
      "'PHP_CCACHE' to 'OFF' or by setting the 'CCACHE_DISABLE' environment "
      "variable."
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
    target_link_libraries(php_config INTERFACE Gcov::Gcov)
    gcov_generate_report()
    set(HAVE_GCOV TRUE)
  endif()
endif()

# Valgrind.
if(PHP_VALGRIND)
  find_package(Valgrind)
  set_package_properties(
    Valgrind
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable Valgrind support."
  )

  target_link_libraries(php_config INTERFACE Valgrind::Valgrind)

  set(HAVE_VALGRIND TRUE)
endif()
add_feature_info(
  "Valgrind"
  HAVE_VALGRIND
  "dynamic analysis"
)

# DTrace.
if(PHP_DTRACE)
  find_package(DTrace)
  set_package_properties(
    DTrace
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the DTrace support."
  )

  if(DTrace_FOUND)
    dtrace_target(
      php_dtrace
      INPUT ${PHP_SOURCE_DIR}/Zend/zend_dtrace.d
      HEADER ${PHP_BINARY_DIR}/Zend/zend_dtrace_gen.h
      SOURCES
        ${PHP_SOURCE_DIR}/main/main.c
        ${PHP_SOURCE_DIR}/Zend/zend_API.c
        ${PHP_SOURCE_DIR}/Zend/zend_dtrace.c
        ${PHP_SOURCE_DIR}/Zend/zend_exceptions.c
        ${PHP_SOURCE_DIR}/Zend/zend_execute.c
        ${PHP_SOURCE_DIR}/Zend/zend.c
      INCLUDES
        $<TARGET_PROPERTY:PHP::config,INTERFACE_INCLUDE_DIRECTORIES>
    )

    target_link_libraries(php_config INTERFACE DTrace::DTrace)
    target_link_libraries(php_sapi INTERFACE php_dtrace)

    set(HAVE_DTRACE TRUE)
  endif()
endif()
add_feature_info(
  "DTrace"
  HAVE_DTRACE
  "performance analysis and troubleshooting"
)

# Dmalloc.
if(PHP_DMALLOC)
  find_package(Dmalloc)
  set_package_properties(
    Dmalloc
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to use Dmalloc memory debugger."
  )

  target_compile_definitions(
    php_config
    INTERFACE
      $<$<COMPILE_LANGUAGE:ASM,C,CXX>:DMALLOC_FUNC_CHECK>
  )

  target_link_libraries(php_config INTERFACE Dmalloc::Dmalloc)

  set(HAVE_DMALLOC TRUE)
endif()
add_feature_info(
  "Dmalloc"
  HAVE_DMALLOC
  "memory debugging"
)
