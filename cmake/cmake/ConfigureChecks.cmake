# Include required modules.
include(CheckIncludeFile)
include(CheckLibraryExists)
include(CheckSymbolExists)
include(CheckTypeSize)
include(CheckIPv6)
include(CMakePushCheckState)
include(FindSendmail)

# Check whether the system byte ordering is bigendian - requires CMake 3.20.
if(CMAKE_C_BYTE_ORDER STREQUAL "BIG_ENDIAN")
  set(WORDS_BIGENDIAN 1)
endif()

check_include_file(alloca.h HAVE_ALLOCA_H)
check_include_file(arpa/inet.h HAVE_ARPA_INET_H)
check_include_file(arpa/nameser.h HAVE_ARPA_NAMESER_H)
check_include_file(crypt.h HAVE_CRYPT_H)
check_include_file(dirent.h HAVE_DIRENT_H)
check_include_file(dlfcn.h HAVE_DLFCN_H)
check_include_file(dns.h HAVE_DNS_H)
check_include_file(fcntl.h HAVE_FCNTL_H)
check_include_file(grp.h HAVE_GRP_H)
check_include_file(ieeefp.h HAVE_IEEEFP_H)
check_include_file(langinfo.h HAVE_LANGINFO_H)
check_include_file(linux/filter.h HAVE_LINUX_FILTER_H)
check_include_file(linux/sock_diag.h HAVE_LINUX_SOCK_DIAG_H)
check_include_file(malloc.h HAVE_MALLOC_H)
check_include_file(netinet/in.h HAVE_NETINET_IN_H)
check_include_file(net/if.h HAVE_NET_IF_H)
check_include_file(os/signpost.h HAVE_OS_SIGNPOST_H)
check_include_file(poll.h HAVE_POLL_H)
check_include_file(pty.h HAVE_PTY_H)
check_include_file(pwd.h HAVE_PWD_H)
check_include_file(resolv.h HAVE_RESOLV_H)
check_include_file(stdint.h HAVE_STDINT_H)
check_include_file(strings.h HAVE_STRINGS_H)
check_include_file(sys/file.h HAVE_SYS_FILE_H)
check_include_file(sys/ioctl.h HAVE_SYS_IOCTL_H)
check_include_file(sys/ipc.h HAVE_SYS_IPC_H)
check_include_file(sys/loadavg.h HAVE_SYS_LOADAVG_H)
check_include_file(sys/mman.h HAVE_SYS_MMAN_H)
check_include_file(sys/mount.h HAVE_SYS_MOUNT_H)
check_include_file(sys/param.h HAVE_SYS_PARAM_H)
check_include_file(sys/poll.h HAVE_SYS_POLL_H)
check_include_file(sys/procctl.h HAVE_SYS_PROCCTL_H)
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
check_include_file(sys/vfs.h HAVE_SYS_VFS_H)
check_include_file(sys/wait.h HAVE_SYS_WAIT_H)
check_include_file(sysexits.h HAVE_SYSEXITS_H)
check_include_file(syslog.h HAVE_SYSLOG_H)
check_include_file(unistd.h HAVE_UNISTD_H)
check_include_file(unix.h HAVE_UNIX_H)
check_include_file(utime.h HAVE_UTIME_H)

# Intel Intrinsics headers.
check_include_file(tmmintrin.h HAVE_TMMINTRIN_H)
check_include_file(nmmintrin.h HAVE_NMMINTRIN_H)
check_include_file(wmmintrin.h HAVE_WMMINTRIN_H)
check_include_file(immintrin.h HAVE_IMMINTRIN_H)

# Check for missing declarations of reentrant functions.
include(PHPCheckMissingTimeR)

# Check size of symbols - these are defined elsewhere than stdio.h.
check_type_size("intmax_t" SIZEOF_INTMAX_T)
if(NOT SIZEOF_INTMAX_T)
  set(SIZEOF_INTMAX_T 0 CACHE STRING "Size of intmax_t")
  message(WARNING "Couldn't determine size of intmax_t, setting to 0.")
endif()

check_type_size("ssize_t" SIZEOF_SSIZE_T)
if(NOT SIZEOF_SSIZE_T)
  set(SIZEOF_SSIZE_T 8 CACHE STRING "Size of ssize_t")
  message(WARNING "Couldn't determine size of ssize_t, setting to 8.")
endif()

check_type_size("ptrdiff_t" SIZEOF_PTRDIFF_T)
set(HAVE_PTRDIFF_T 1 CACHE STRING "Whether ptrdiff_t is available")
if(NOT SIZEOF_PTRDIFF_T)
  set(SIZEOF_PTRDIFF_T 8 CACHE STRING "Size of ptrdiff_t")
  message(WARNING "Couldn't determine size of ptrdiff_t, setting to 8.")
endif()

# Check stdint types.
check_type_size("short" SIZEOF_SHORT)
if(NOT SIZEOF_SHORT)
  message(FATAL_ERROR "Cannot determine size of short.")
endif()

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

# Check fopencookie.
include(PHPCheckFopencookie)

# Check for broken getcwd().
include(PHPCheckBrokenGetCwd)

# Check for missing fclose declaration.
include(PHPCheckMissingFcloseDeclaration)

# Check struct flock.
include(PHPCheckStructFlock)

# Check for __builtin_expect.
include(PHPCheckBuiltinExpect)

# Check for __builtin_clz.
include(PHPCheckBuiltinClz)

# Check for __builtin_clzl.
include(PHPCheckBuiltinClzl)

# Check for __builtin_clzll.
include(PHPCheckBuiltinClzll)

# Check for __builtin_ctzl.
include(PHPCheckBuiltinCtzl)

# Check for __builtin_ctzll.
include(PHPCheckBuiltinCtzll)

# Check for __builtin_smull_overflow.
include(PHPCheckBuiltinSmullOverflow)

# Check for __builtin_smulll_overflow.
include(PHPCheckBuiltinSmulllOverflow)

# Check for __builtin_saddl_overflow.
include(PHPCheckBuiltinSaddlOverflow)

# Check for __builtin_saddll_overflow.
include(PHPCheckBuiltinSaddllOverflow)

# Check for __builtin_usub_overflow.
include(PHPCheckBuiltinUsubOverflow)

# Check for __builtin_ssubl_overflow.
include(PHPCheckBuiltinSsublOverflow)

# Check for __builtin_ssubll_overflow.
include(PHPCheckBuiltinSsubllOverflow)

# Check for __builtin_cpu_init.
include(PHPCheckBuiltinCpuInit)

# Check for __builtin_cpu_supports.
include(PHPCheckBuiltinCpuSupports)

# Check for __builtin_frame_address.
include(PHPCheckBuiltinFrameAddress)

# Check AVX512.
include(PHPCheckAVX512)

# Check AVX512 VBMI.
include(PHPCheckAVX512VBMI)

# Check prctl.
include(PHPCheckPrctl)

# Check procctl.
include(PHPCheckProcctl)

# Check for __alignof__.
include(PHPCheckAlignof)

# Check functions and symbols.
check_symbol_exists(alphasort "dirent.h" HAVE_ALPHASORT)
check_symbol_exists(asctime_r "time.h" HAVE_ASCTIME_R)
check_symbol_exists(chroot "unistd.h" HAVE_CHROOT)
check_symbol_exists(ctime_r "time.h" HAVE_CTIME_R)
check_symbol_exists(explicit_memset "string.h" HAVE_EXPLICIT_MEMSET)
check_symbol_exists(fdatasync "unistd.h" HAVE_FDATASYNC)
check_symbol_exists(flock "fcntl.h" HAVE_FLOCK)
check_symbol_exists(ftok "sys/ipc.h" HAVE_FTOK)
check_symbol_exists(funopen "stdio.h" HAVE_FUNOPEN)
check_symbol_exists(gai_strerror "netdb.h" HAVE_GAI_STRERROR)
check_symbol_exists(getcwd "unistd.h" HAVE_GETCWD)
check_symbol_exists(getloadavg "unistd.h" HAVE_GETLOADAVG)
check_symbol_exists(getlogin "unistd.h" HAVE_GETLOGIN)
check_symbol_exists(getprotobyname "netdb.h" HAVE_GETPROTOBYNAME)
check_symbol_exists(getprotobynumber "netdb.h" HAVE_GETPROTOBYNUMBER)
check_symbol_exists(getservbyname "netdb.h" HAVE_GETSERVBYNAME)
check_symbol_exists(getservbyport "netdb.h" HAVE_GETSERVBYPORT)
check_symbol_exists(getrusage "sys/resource.h" HAVE_GETRUSAGE)
check_symbol_exists(gettimeofday "sys/time.h" HAVE_GETTIMEOFDAY)
check_symbol_exists(gmtime_r "time.h" HAVE_GMTIME_R)
check_symbol_exists(getpwnam_r "pwd.h" HAVE_GETPWNAM_R)
check_symbol_exists(getgrnam_r "grp.h" HAVE_GETGRNAM_R)
check_symbol_exists(getpwuid_r "pwd.h" HAVE_GETPWUID_R)
check_symbol_exists(getwd "unistd.h" HAVE_GETWD)
check_symbol_exists(glob "glob.h" HAVE_GLOB)
check_symbol_exists(inet_ntoa "arpa/inet.h" HAVE_INET_NTOA)
check_symbol_exists(inet_ntop "arpa/inet.h" HAVE_INET_NTOP)
check_symbol_exists(inet_pton "arpa/inet.h" HAVE_INET_PTON)
check_symbol_exists(localtime_r "time.h" HAVE_LOCALTIME_R)
check_symbol_exists(lchown "unistd.h" HAVE_LCHOWN)
check_symbol_exists(memcntl "sys/mman.h" HAVE_MEMCNTL)
check_symbol_exists(memmove "string.h" HAVE_MEMMOVE)
check_symbol_exists(mkstemp "stdlib.h" HAVE_MKSTEMP)
check_symbol_exists(mmap "sys/mman.h" HAVE_MMAP)
check_symbol_exists(nice "unistd.h" HAVE_NICE)
check_symbol_exists(nl_langinfo "langinfo.h" HAVE_NL_LANGINFO)
check_symbol_exists(poll "poll.h" HAVE_POLL)
check_symbol_exists(pthread_jit_write_protect_np "pthread.h" HAVE_PTHREAD_JIT_WRITE_PROTECT_NP)
check_symbol_exists(putenv "stdlib.h" HAVE_PUTENV)
check_symbol_exists(scandir "dirent.h" HAVE_SCANDIR)
check_symbol_exists(setitimer "sys/time.h" HAVE_SETITIMER)
check_symbol_exists(setenv "stdlib.h" HAVE_SETENV)
check_symbol_exists(shutdown "sys/socket.h" HAVE_SHUTDOWN)
check_symbol_exists(sigprocmask "signal.h" HAVE_SIGPROCMASK)
check_symbol_exists(statfs "sys/statfs.h" HAVE_STATFS)
check_symbol_exists(statvfs "sys/statvfs.h" HAVE_STATVFS)
check_symbol_exists(std_syslog "sys/syslog.h" HAVE_STD_SYSLOG)
check_symbol_exists(strcasecmp "strings.h" HAVE_STRCASECMP)
check_symbol_exists(strnlen "string.h" HAVE_STRNLEN)

cmake_push_check_state()
  set(CMAKE_REQUIRED_DEFINITIONS "${CMAKE_REQUIRED_DEFINITIONS} -D_XOPEN_SOURCE")
  check_symbol_exists(strptime "time.h" HAVE_STRPTIME)
cmake_pop_check_state()

check_symbol_exists(strtok_r "string.h" HAVE_STRTOK_R)
check_symbol_exists(symlink "unistd.h" HAVE_SYMLINK)
check_symbol_exists(tzset "time.h" HAVE_TZSET)
check_symbol_exists(unsetenv "stdlib.h" HAVE_UNSETENV)
check_symbol_exists(usleep "unistd.h" HAVE_USLEEP)
check_symbol_exists(utime "utime.h" HAVE_UTIME)
check_symbol_exists(vasprintf "stdio.h" HAVE_VASPRINTF)
check_symbol_exists(asprintf "stdio.h" HAVE_ASPRINTF)
check_symbol_exists(nanosleep "time.h" HAVE_NANOSLEEP)
check_symbol_exists(memmem "string.h" HAVE_MEMMEM)
check_symbol_exists(memrchr "string.h" HAVE_MEMRCHR)
check_symbol_exists(strerror_r "string.h" HAVE_STRERROR_R)
check_symbol_exists(strlcat "string.h" HAVE_STRLCAT)
check_symbol_exists(strlcpy "string.h" HAVE_STRLCPY)
check_symbol_exists(explicit_bzero "string.h" HAVE_EXPLICIT_BZERO)

# Check whether writing to stdout works.
include(PHPCheckWriteStdout)

# Check for required libraries.
check_library_exists(m sin "" HAVE_LIB_M)

if(HAVE_LIB_M)
  set(EXTRA_LIBS ${EXTRA_LIBS} m)
endif()

# Check for IPv6 support.
ipv6()

# Find sendmail binary.
php_prog_sendmail()

# Check for aarch64 CRC32 API.
include(PHPCheckAarch64CRC32)
