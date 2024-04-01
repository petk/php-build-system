#[=============================================================================[
Project-wide configuration checks.
#]=============================================================================]

include_guard(GLOBAL)

# Include required modules.
include(CheckIncludeFile)
include(CheckIncludeFiles)
include(CheckSourceCompiles)
include(CheckStructHasMember)
include(CheckSymbolExists)
include(CheckTypeSize)
include(CMakePushCheckState)
include(FeatureSummary)
include(PHP/CheckFunctionAttribute)
include(PHP/SearchLibraries)

################################################################################
# Check headers.
################################################################################

check_include_file(alloca.h HAVE_ALLOCA_H)
check_include_file(arpa/inet.h HAVE_ARPA_INET_H)
check_include_file(arpa/nameser.h HAVE_ARPA_NAMESER_H)
check_include_file(dirent.h HAVE_DIRENT_H)
check_include_file(dlfcn.h HAVE_DLFCN_H)
check_include_file(dns.h HAVE_DNS_H)
check_include_file(fcntl.h HAVE_FCNTL_H)
check_include_file(grp.h HAVE_GRP_H)
check_include_file(ieeefp.h HAVE_IEEEFP_H)
check_include_file(langinfo.h HAVE_LANGINFO_H)
check_include_file(linux/sock_diag.h HAVE_LINUX_SOCK_DIAG_H)
check_include_file(netinet/in.h HAVE_NETINET_IN_H)
check_include_file(os/signpost.h HAVE_OS_SIGNPOST_H)
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
check_include_file(sys/types.h HAVE_SYS_TYPES_H)
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
check_struct_has_member("struct stat" st_blksize sys/stat.h HAVE_STRUCT_STAT_ST_BLKSIZE)
check_struct_has_member("struct stat" st_blocks sys/stat.h HAVE_STRUCT_STAT_ST_BLOCKS)
check_struct_has_member("struct stat" st_rdev sys/stat.h HAVE_STRUCT_STAT_ST_RDEV)

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

check_type_size("int" SIZEOF_INT)
if(NOT SIZEOF_INT)
  message(FATAL_ERROR "Cannot determine size of int.")
endif()

check_type_size("long" SIZEOF_LONG)
if(NOT SIZEOF_LONG)
  message(FATAL_ERROR "Cannot determine size of long.")
endif()

check_type_size("long long" SIZEOF_LONG_LONG)
if(NOT SIZEOF_LONG_LONG)
  message(FATAL_ERROR "Cannot determine size of long long.")
endif()

check_type_size("size_t" SIZEOF_SIZE_T)
if(NOT HAVE_SIZEOF_SIZE_T)
  message(FATAL_ERROR "Cannot determine size of size_t.")
endif()

check_type_size("off_t" SIZEOF_OFF_T)
if(NOT SIZEOF_OFF_T)
  message(FATAL_ERROR "Cannot determine size of off_t.")
endif()

check_type_size("gid_t" SIZEOF_GID_T)
if(NOT HAVE_SIZEOF_GID_T)
  set(gid_t int CACHE INTERNAL "Define as 'int' if <sys/types.h> doesn't define.")
endif()

check_type_size("uid_t" SIZEOF_UID_T)
if(NOT HAVE_SIZEOF_UID_T)
  set(uid_t int CACHE INTERNAL "Define as 'int' if <sys/types.h> doesn't define.")
endif()

check_type_size("intmax_t" SIZEOF_INTMAX_T)
if(NOT SIZEOF_INTMAX_T)
  set(SIZEOF_INTMAX_T 0 CACHE INTERNAL "Size of intmax_t")
  message(WARNING "Couldn't determine size of intmax_t, setting to 0.")
endif()

check_type_size("ssize_t" SIZEOF_SSIZE_T)
if(NOT SIZEOF_SSIZE_T)
  set(SIZEOF_SSIZE_T 8 CACHE INTERNAL "Size of ssize_t")
  message(WARNING "Couldn't determine size of ssize_t, setting to 8.")
endif()

check_type_size("ptrdiff_t" SIZEOF_PTRDIFF_T)
set(HAVE_PTRDIFF_T 1 CACHE INTERNAL "Whether ptrdiff_t is available")
if(NOT SIZEOF_PTRDIFF_T)
  set(SIZEOF_PTRDIFF_T 8 CACHE INTERNAL "Size of ptrdiff_t")
  message(WARNING "Couldn't determine size of ptrdiff_t, setting to 8.")
endif()

# Check for socklen_t type.
cmake_push_check_state(RESET)
  if(HAVE_SYS_SOCKET_H)
    set(CMAKE_EXTRA_INCLUDE_FILES sys/socket.h)
  endif()
  check_type_size("socklen_t" SIZEOF_SOCKLEN_T)
  if(HAVE_SIZEOF_SOCKLEN_T)
    set(HAVE_SOCKLEN_T 1 CACHE INTERNAL "Whether the system has the type 'socklen_t'.")
  endif()
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

# Check AVX-512.
include(PHP/CheckAVX512)

# Check AVX-512 VBMI.
include(PHP/CheckAVX512VBMI)

# Check for asm goto.
message(CHECK_START "Checking for asm goto support")
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_source_compiles(C [[
    int main(void) {
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

block()
  cmake_push_check_state(RESET)
    if(HAVE_FCNTL_H)
      list(APPEND headers "fcntl.h")
    endif()

    if(HAVE_SYS_FILE_H)
      list(APPEND headers "sys/file.h")
    endif()

    check_symbol_exists(flock "${headers}" HAVE_FLOCK)
  cmake_pop_check_state()
endblock()

check_symbol_exists(ftok "sys/ipc.h" HAVE_FTOK)
check_symbol_exists(funopen "stdio.h" HAVE_FUNOPEN)
check_symbol_exists(getcwd "unistd.h" HAVE_GETCWD)
check_symbol_exists(getloadavg "stdlib.h" HAVE_GETLOADAVG)
check_symbol_exists(getlogin "unistd.h" HAVE_GETLOGIN)
check_symbol_exists(getprotobyname "netdb.h" HAVE_GETPROTOBYNAME)
check_symbol_exists(getprotobynumber "netdb.h" HAVE_GETPROTOBYNUMBER)
check_symbol_exists(getservbyname "netdb.h" HAVE_GETSERVBYNAME)
check_symbol_exists(getservbyport "netdb.h" HAVE_GETSERVBYPORT)
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

check_symbol_exists(mempcpy "string.h" HAVE_MEMPCPY)
check_symbol_exists(mkstemp "stdlib.h" HAVE_MKSTEMP)
check_symbol_exists(mmap "sys/mman.h" HAVE_MMAP)
check_symbol_exists(nice "unistd.h" HAVE_NICE)
check_symbol_exists(nl_langinfo "langinfo.h" HAVE_NL_LANGINFO)
check_symbol_exists(prctl "sys/prctl.h" HAVE_PRCTL)
check_symbol_exists(procctl "sys/procctl.h" HAVE_PROCCTL)
check_symbol_exists(poll "poll.h" HAVE_POLL)
check_symbol_exists(pthread_jit_write_protect_np "pthread.h" HAVE_PTHREAD_JIT_WRITE_PROTECT_NP)
check_symbol_exists(putenv "stdlib.h" HAVE_PUTENV)
check_symbol_exists(scandir "dirent.h" HAVE_SCANDIR)
check_symbol_exists(setitimer "sys/time.h" HAVE_SETITIMER)
check_symbol_exists(setenv "stdlib.h" HAVE_SETENV)
check_symbol_exists(shutdown "sys/socket.h" HAVE_SHUTDOWN)
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

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_XOPEN_SOURCE)
  check_symbol_exists(strptime "time.h" HAVE_STRPTIME)
cmake_pop_check_state()

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

# Check for strerror_r, and if its a POSIX-compatible or a GNU specific version.
include(PHP/CheckStrerrorR)

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
if(PHP_FD_SETSIZE GREATER 0)
  message(CHECK_PASS "using FD_SETSIZE=${PHP_FD_SETSIZE}")
  target_compile_definitions(
    php_configuration
    INTERFACE
      $<$<COMPILE_LANGUAGE:ASM,C,CXX>:FD_SETSIZE=${PHP_FD_SETSIZE}>
  )
elseif(NOT PHP_FD_SETSIZE STREQUAL "" AND NOT PHP_FD_SETSIZE GREATER 0)
  message(FATAL_ERROR "Invalid value PHP_FD_SETSIZE=${PHP_FD_SETSIZE}")
else()
  message(CHECK_PASS "using system default")
endif()

# Check target system byte order.
include(PHP/CheckByteOrder)

# Check for IPv6 support.
if(PHP_IPV6)
  include(PHP/CheckIPv6)
endif()

# Check for aarch64 CRC32 API.
message(CHECK_START "Checking for aarch64 CRC32 API availability")
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_source_compiles(C "
    #include <arm_acle.h>
    int main(void) {
      __crc32d(0, 0);
      return 0;
    }
  " HAVE_AARCH64_CRC32)
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

# Check for __alignof__ support in the compiler.
message(CHECK_START "Checking whether the compiler supports __alignof__")
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_source_compiles(C "
    int main(void) {
      int align = __alignof__(int);
      return 0;
    }
  " HAVE_ALIGNOF)
cmake_pop_check_state()
if(HAVE_ALIGNOF)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

# Check for GCC function attributes on all systems except ones without glibc.
# Fix for these systems is already included in GCC 7, but not on GCC 6. At least
# some versions of FreeBSD seem to have buggy ifunc support, see bug #77284.
# Conservatively don't use ifuncs on FreeBSD prior to version 12.
if(
  (
    NOT CMAKE_SYSTEM_NAME MATCHES "^(Android|FreeBSD|OpenBSD)$"
    AND NOT PHP_STD_LIBRARY MATCHES "^(musl|uclibc)$"
  ) OR (
    CMAKE_SYSTEM_NAME STREQUAL "FreeBSD"
    AND CMAKE_SYSTEM_VERSION VERSION_GREATER_EQUAL 12
  )
)
  php_check_function_attribute(ifunc HAVE_FUNC_ATTRIBUTE_IFUNC)
  php_check_function_attribute(target HAVE_FUNC_ATTRIBUTE_TARGET)
endif()

include(PHP/CheckGethostbynameR)

# Check for major, minor, and makedev.
include(PHP/CheckSysMacros)

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
      "disable ccache by setting environment variable CCACHE_DISABLE=1."
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
  "dlfcn.h"
  HAVE_LIBDL
  _php_dlopen_library
  LIBRARIES
    ${CMAKE_DL_LIBS}
)
if(_php_dlopen_library)
  target_link_libraries(php_configuration INTERFACE ${_php_dlopen_library})
endif()

php_search_libraries(sin "math.h" HAVE_SIN M_LIBRARY LIBRARIES m)
if(M_LIBRARY)
  target_link_libraries(
    php_configuration
    INTERFACE
      "$<$<NOT:$<IN_LIST:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>>:${M_LIBRARY}>"
  )
endif()

if(CMAKE_SYSTEM_PROCESSOR MATCHES "^riscv64.*")
  find_package(Atomic)

  if(Atomic_FOUND)
    target_link_libraries(php_configuration INTERFACE Atomic::Atomic)
  endif()
endif()

# The socket() is in C library on most systems (Solaris 11.4...)
php_search_libraries(
  socket
  "sys/socket.h;winsock.h"
  HAVE_SOCKET
  SOCKET_LIBRARY
  LIBRARIES
    socket  # Solaris <= 11.3, illumos
    network # Haiku
    ws2_32  # Windows
)
if(SOCKET_LIBRARY)
  target_link_libraries(php_configuration INTERFACE ${SOCKET_LIBRARY})
endif()

# The socketpair() is in C library on most systems (Solaris 11.4...), except
# Windows.
php_search_libraries(
  socketpair
  "sys/socket.h"
  HAVE_SOCKETPAIR
  SOCKETPAIR_LIBRARY
  LIBRARIES
    socket  # Solaris <= 11.3, illumos
    network # Haiku
)
if(SOCKETPAIR_LIBRARY)
  target_link_libraries(php_configuration INTERFACE ${SOCKETPAIR_LIBRARY})
endif()

# The gethostname() is in C library on most systems (Solaris/illumos...).
php_search_libraries(
  gethostname
  "unistd.h;winsock.h"
  HAVE_GETHOSTNAME
  GETHOSTNAME_LIBRARY
  LIBRARIES
    network # Haiku
    ws2_32  # Windows
)
if(GETHOSTNAME_LIBRARY)
  target_link_libraries(php_configuration INTERFACE ${GETHOSTNAME_LIBRARY})
endif()

# The gethostbyaddr() is in C library on most systems (Solaris 11.4...)
php_search_libraries(
  gethostbyaddr
  "netdb.h;sys/socket.h;winsock.h"
  HAVE_GETHOSTBYADDR
  GETHOSTBYADDR_LIBRARY
  LIBRARIES
    nsl     # Solaris <= 11.3, illumos
    network # Haiku
    ws2_32  # Windows
)
if(GETHOSTBYADDR_LIBRARY)
  target_link_libraries(php_configuration INTERFACE ${GETHOSTBYADDR_LIBRARY})
endif()

php_search_libraries(
  openpty
  pty.h
  HAVE_OPENPTY
  OPENPTY_LIBRARY
  LIBRARIES util bsd
)
if(OPENPTY_LIBRARY)
  target_link_libraries(php_configuration INTERFACE ${OPENPTY_LIBRARY})
endif()

# The inet_ntop() is in C library on most systems (Solaris 11.4, illumos, BSD*,
# Linux...).
php_search_libraries(
  inet_ntop
  "arpa/inet.h;ws2tcpip.h"
  _HAVE_INET_NTOP
  _php_inet_ntop_library
  LIBRARIES
    # TODO: Update the libraries list here for Solaris. Solaris 11 has these in
    # the C library or linked explicitly already like Linux systems.
    nsl     # Solaris 8..10
    resolv  # Solaris 2.6..7
    network # Haiku
    ws2_32  # Windows
)
if(_php_inet_ntop_library)
  target_link_libraries(php_configuration INTERFACE ${_php_inet_ntop_library})
endif()
if(NOT _HAVE_INET_NTOP)
  message(FATAL_ERROR "Required inet_ntop not found.")
endif()

php_search_libraries(
  inet_pton
  "arpa/inet.h;ws2tcpip.h"
  _HAVE_INET_PTON
  _php_inet_pton_library
  LIBRARIES
    # TODO: Update the libraries list here for Solaris. Solaris 11 has these in
    # the C library or linked explicitly already like Linux systems.
    nsl     # Solaris 8..10
    resolv  # Solaris 2.6..7
    network # Haiku
    ws2_32  # Windows
)
if(_php_inet_pton_library)
  target_link_libraries(php_configuration INTERFACE ${_php_inet_pton_library})
endif()
if(NOT _HAVE_INET_PTON)
  message(FATAL_ERROR "Required inet_pton not found.")
endif()

php_search_libraries(
  nanosleep
  "time.h"
  HAVE_NANOSLEEP
  NANOSLEEP_LIBRARY
  LIBRARIES
    rt # Solaris 10
)
if(NANOSLEEP_LIBRARY)
  target_link_libraries(php_configuration INTERFACE ${NANOSLEEP_LIBRARY})
endif()

php_search_libraries(
  setsockopt
  "sys/types.h;sys/socket.h;winsock.h"
  HAVE_SETSOCKOPT
  SETSOCKOPT_LIBRARY
  LIBRARIES
    network # Haiku does not have network API in libc.
    ws2_32  # Windows
)
if(SETSOCKOPT_LIBRARY)
  target_link_libraries(php_configuration INTERFACE ${SETSOCKOPT_LIBRARY})
endif()

# Check for Solaris/illumos process mapping.
php_search_libraries(
  Pgrab
  "libproc.h"
  HAVE_PGRAB
  PROC_LIBRARY
  LIBRARIES proc
)
if(PROC_LIBRARY)
  target_link_libraries(php_configuration INTERFACE ${PROC_LIBRARY})
endif()

# The gai_strerror() is in C library on most systems (illumos, Solaris 11.4...)
php_search_libraries(
  gai_strerror
  "netdb.h"
  HAVE_GAI_STRERROR
  GAI_STRERROR_LIBRARY
  LIBRARIES
    socket  # Solaris <= 11.3
    network # Haiku
)
if(GAI_STRERROR_LIBRARY)
  target_link_libraries(php_configuration INTERFACE ${GAI_STRERROR_LIBRARY})
endif()

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
