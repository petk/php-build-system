#[=============================================================================[
Specific configuration for Windows platform.
#]=============================================================================]

include_guard(GLOBAL)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  ##############################################################################
  # Emulated functionality by php-src/win32.
  ##############################################################################

  # PHP has fnmatch() emulation implemented on Windows.
  set(HAVE_FNMATCH TRUE)

  # PHP has ftok() emulation implemented on Windows.
  set(HAVE_FTOK TRUE)

  # PHP has unconditional support for getcwd() on Windows.
  set(HAVE_GETCWD TRUE)

  # PHP defines getpid as _getpid on Windows.
  set(HAVE_GETPID TRUE)

  # PHP has getrusage() emulation implemented on Windows.
  set(HAVE_GETRUSAGE TRUE)

  # PHP has gettimeofday() emulation implemented on Windows.
  set(HAVE_GETTIMEOFDAY TRUE)

  # PHP has glob() emulation implemented on Windows.
  set(HAVE_GLOB TRUE)

  # Windows has LoadLibrary().
  set(HAVE_LIBDL TRUE)

  # PHP has nanosleep() emulation implemented on Windows.
  set(HAVE_NANOSLEEP TRUE)

  # PHP has nice() emulation implemented on Windows.
  set(HAVE_NICE TRUE)

  # PHP has socketpair() emulation implemented on Windows.
  set(HAVE_SOCKETPAIR TRUE)

  # PHP defines strcasecmp in Zend/zend_config.w32.h.
  set(HAVE_STRCASECMP TRUE)

  # PHP has syslog.h emulation implemented on Windows.
  set(HAVE_SYSLOG_H TRUE)

  # PHP has usleep() emulation implemented on Windows.
  set(HAVE_USLEEP TRUE)

  ##############################################################################
  # To speed up the Windows build experience with Visual Studio generators,
  # these are always known on Windows systems.
  ##############################################################################

  # Whether system has <alloca.h> header.
  set(HAVE_ALLOCA_H FALSE)

  # Whether system has <dirent.h> header.
  set(HAVE_DIRENT_H FALSE)

  # Whether system has flock().
  set(HAVE_FLOCK FALSE)

  # Whether system has <grp.h> header.
  set(HAVE_GRP_H FALSE)

  # Whether system has kill().
  set(HAVE_KILL FALSE)

  # Whether system has <pwd.h> header.
  set(HAVE_PWD_H FALSE)

  # Whether systems has setitimer().
  set(HAVE_SETITIMER FALSE)

  # Windows has setjmp() in <setjmp.h> instead.
  set(HAVE_SIGSETJMP FALSE)

  # Whether system has symlink().
  set(HAVE_SYMLINK FALSE)

  # Whether system has <sys/file.h> header.
  set(HAVE_SYS_FILE_H FALSE)

  # Whether system has <sys/socket.h> header.
  set(HAVE_SYS_SOCKET_H FALSE)

  # Whether system has <sys/time.h> header.
  set(HAVE_SYS_TIME_H FALSE)

  # Whether system has <sys/wait.h> header.
  set(HAVE_SYS_WAIT_H FALSE)

  # Whether 'st_blksize' is a member of 'struct stat'.
  set(HAVE_STRUCT_STAT_ST_BLKSIZE FALSE)

  # Whether 'st_blocks' is a member of 'struct stat'.
  set(HAVE_STRUCT_STAT_ST_BLOCKS FALSE)

  # Whether system has <unistd.h>.
  set(HAVE_UNISTD_H FALSE)

  set(GWINSZ_IN_SYS_IOCTL FALSE)

  #Test HAVE_ALIGNOF
  set(HAVE_ALIGNOF FALSE)

  #Have symbol alloca
  set(HAVE_ALLOCA TRUE)

  #Have symbol alphasort
  set(HAVE_ALPHASORT FALSE)

  #Have symbol arc4random_buf
  set(HAVE_ARC4RANDOM_BUF FALSE)

  #Have includes arpa/inet.h
  set(HAVE_ARPA_INET_H FALSE)

  #Have includes sys/types.h;arpa/nameser.h
  set(HAVE_ARPA_NAMESER_H FALSE)

  #Have function asctime_r
  set(HAVE_ASCTIME_R FALSE)

  #Test HAVE_ASM_GOTO
  set(HAVE_ASM_GOTO TRUE)

  #Have symbol asprintf
  set(HAVE_ASPRINTF FALSE)

  #Test HAVE_ATTRIBUTE_ALIGNED
  set(HAVE_ATTRIBUTE_ALIGNED FALSE)

  #Have symbol chroot
  set(HAVE_CHROOT FALSE)

  #Have symbol clock_gettime_nsec_np
  set(HAVE_CLOCK_GETTIME_NSEC_NP FALSE)

  #Have includes sys/types.h;Availability.h;CommonCrypto/CommonCryptoError.h;CommonCrypto/CommonRandom.h
  set(HAVE_COMMONCRYPTO_COMMONRANDOM_H FALSE)

  #Test HAVE_COPY_FILE_RANGE
  set(HAVE_COPY_FILE_RANGE FALSE)

  #Test HAVE_CPUID_COUNT
  set(HAVE_CPUID_COUNT FALSE)

  #Have includes cpuid.h
  set(HAVE_CPUID_H FALSE)

  #Have function ctime_r
  set(HAVE_CTIME_R FALSE)

  #Have includes dlfcn.h
  set(HAVE_DLFCN_H FALSE)

  #Have includes dns.h
  set(HAVE_DNS_H FALSE)

  #Have symbol dns_search
  set(HAVE_DNS_SEARCH FALSE)

  #Have symbol dn_expand
  set(HAVE_DN_EXPAND FALSE)

  #Have symbol dn_skipname
  set(HAVE_DN_SKIPNAME FALSE)

  #Have symbol elf_aux_info
  set(HAVE_ELF_AUX_INFO FALSE)

  #Have symbol explicit_bzero
  set(HAVE_EXPLICIT_BZERO FALSE)

  #Have symbol explicit_memset
  set(HAVE_EXPLICIT_MEMSET FALSE)

  #Have include fcntl.h
  set(HAVE_FCNTL_H TRUE)

  #Have function fdatasync
  set(HAVE_FDATASYNC FALSE)

  #Whether flush should be called explicitly after a buffered io.
  set(HAVE_FLUSHIO FALSE)

  #Have symbol fork
  set(HAVE_FORK FALSE)

  #Test HAVE_FPSETPREC
  set(HAVE_FPSETPREC FALSE)

  #Test HAVE_FPU_INLINE_ASM_X86
  set(HAVE_FPU_INLINE_ASM_X86 FALSE)

  #Test HAVE_FUNC_ATTRIBUTE_IFUNC
  set(HAVE_FUNC_ATTRIBUTE_IFUNC FALSE)

  #Test HAVE_FUNC_ATTRIBUTE_TARGET
  set(HAVE_FUNC_ATTRIBUTE_TARGET FALSE)

  #Test HAVE_FUNC_ATTRIBUTE_VISIBILITY
  set(HAVE_FUNC_ATTRIBUTE_VISIBILITY FALSE)

  #Have symbol funopen
  set(HAVE_FUNOPEN FALSE)

  #Have symbol gai_strerror
  set(HAVE_GAI_STRERROR TRUE)

  #Test HAVE_GCC_GLOBAL_REGS
  set(HAVE_GCC_GLOBAL_REGS FALSE)

  #Have symbol getgrnam_r
  set(HAVE_GETGRNAM_R FALSE)

  #Have symbol gethostname
  set(HAVE_GETHOSTNAME TRUE)

  #Have symbol getloadavg
  set(HAVE_GETLOADAVG FALSE)

  #Have symbol getlogin
  set(HAVE_GETLOGIN FALSE)

  #Have symbol getprotobyname
  set(HAVE_GETPROTOBYNAME TRUE)

  #Have symbol getprotobynumber
  set(HAVE_GETPROTOBYNUMBER TRUE)

  #Have symbol getpwnam_r
  set(HAVE_GETPWNAM_R FALSE)

  #Have symbol getpwuid_r
  set(HAVE_GETPWUID_R FALSE)

  #Have symbol getrandom
  set(HAVE_GETRANDOM FALSE)

  #Have symbol getservbyname
  set(HAVE_GETSERVBYNAME TRUE)

  #Have symbol getservbyport
  set(HAVE_GETSERVBYPORT TRUE)

  #Have symbol gettid
  set(HAVE_GETTID FALSE)

  #Have symbol getwd
  set(HAVE_GETWD FALSE)

  #Have function gmtime_r
  set(HAVE_GMTIME_R FALSE)

  #Have symbol hstrerror
  set(HAVE_HSTRERROR FALSE)

  #Have includes ieeefp.h
  set(HAVE_IEEEFP_H FALSE)

  #Have includes ;ifaddrs.h
  set(HAVE_IFADDRS_H FALSE)

  #Have symbol if_indextoname
  set(HAVE_IF_INDEXTONAME FALSE)

  #Have symbol if_nametoindex
  set(HAVE_IF_NAMETOINDEX FALSE)

  #Have include immintrin.h
  set(HAVE_IMMINTRIN_H TRUE)
  #Have include io.h
  set(HAVE_IO_H TRUE)
  #Have symbol issetugid
  set(HAVE_ISSETUGID FALSE)
  #Have includes langinfo.h
  set(HAVE_LANGINFO_H FALSE)
  #Have symbol lchown
  set(HAVE_LCHOWN FALSE)
  #Have includes libproc.h
  set(HAVE_LIBPROC_H FALSE)
  #Have includes ;libutil.h
  set(HAVE_LIBUTIL_H FALSE)
  #Have includes linux/filter.h
  set(HAVE_LINUX_FILTER_H FALSE)
  #Have includes linux/if_ether.h
  set(HAVE_LINUX_IF_ETHER_H FALSE)
  #Have includes linux/if_packet.h
  set(HAVE_LINUX_IF_PACKET_H FALSE)
  #Have includes linux/sock_diag.h
  set(HAVE_LINUX_SOCK_DIAG_H FALSE)
  #Have includes linux/udp.h
  set(HAVE_LINUX_UDP_H FALSE)
  #Have function localtime_r
  set(HAVE_LOCALTIME_R FALSE)
  #Have symbol makedev
  set(HAVE_MAKEDEV FALSE)
  #Have include ;math.h
  set(HAVE_MATH_H TRUE)
  #Have symbol memcntl
  set(HAVE_MEMCNTL FALSE)
  #Have symbol memfd_create
  set(HAVE_MEMFD_CREATE FALSE)
  #Have symbol memmem
  set(HAVE_MEMMEM FALSE)
  #Have symbol mempcpy
  set(HAVE_MEMPCPY FALSE)
  #Have symbol memrchr
  set(HAVE_MEMRCHR FALSE)
  #Have symbol mkstemp
  set(HAVE_MKSTEMP FALSE)
  #Have symbol mmap
  set(HAVE_MMAP FALSE)
  #Have symbol mprotect
  set(HAVE_MPROTECT FALSE)
  #Have symbol mremap
  set(HAVE_MREMAP FALSE)
  #Have include mscoree.h
  set(HAVE_MSCOREE_H TRUE)
  #Have includes ;netdb.h
  set(HAVE_NETDB_H FALSE)
  #Have includes netinet/in.h
  set(HAVE_NETINET_IN_H FALSE)
  #Have includes net/if.h
  set(HAVE_NET_IF_H FALSE)
  #Have symbol nl_langinfo
  set(HAVE_NL_LANGINFO FALSE)
  #Have include nmmintrin.h
  set(HAVE_NMMINTRIN_H TRUE)
  #Have symbol openpty
  set(HAVE_OPENPTY FALSE)
  #Have symbol poll
  set(HAVE_POLL FALSE)
  #Have includes poll.h
  set(HAVE_POLL_H FALSE)
  #Have symbol posix_spawn_file_actions_addchdir_np
  set(HAVE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR_NP FALSE)
  #Have symbol prctl
  set(HAVE_PRCTL FALSE)
  #Have symbol procctl
  set(HAVE_PROCCTL FALSE)
  #Test HAVE_PS_STRINGS
  set(HAVE_PS_STRINGS FALSE)
  #Have symbol pthread_attr_getstack
  set(HAVE_PTHREAD_ATTR_GETSTACK FALSE)
  #Have symbol pthread_attr_get_np
  set(HAVE_PTHREAD_ATTR_GET_NP FALSE)
  #Have symbol pthread_getattr_np
  set(HAVE_PTHREAD_GETATTR_NP FALSE)
  #Have symbol pthread_get_stackaddr_np
  set(HAVE_PTHREAD_GET_STACKADDR_NP FALSE)
  #Have symbol pthread_jit_write_protect_np
  set(HAVE_PTHREAD_JIT_WRITE_PROTECT_NP FALSE)
  #Have symbol pthread_stackseg_np
  set(HAVE_PTHREAD_STACKSEG_NP FALSE)
  #Have includes pty.h
  set(HAVE_PTY_H FALSE)
  #Have symbol putenv
  set(HAVE_PUTENV TRUE)
  #Have symbol reallocarray
  set(HAVE_REALLOCARRAY FALSE)
  #Have includes resolv.h
  set(HAVE_RESOLV_H FALSE)
  #Have symbol res_ndestroy
  set(HAVE_RES_NDESTROY FALSE)
  #Have symbol res_nsearch
  set(HAVE_RES_NSEARCH FALSE)
  #Have symbol res_search
  set(HAVE_RES_SEARCH FALSE)
  #Have symbol scandir
  set(HAVE_SCANDIR FALSE)
  #Have symbol setenv
  set(HAVE_SETENV FALSE)
  #Have symbol setproctitle
  set(HAVE_SETPROCTITLE FALSE)
  #Have symbol shm_create_largepage
  set(HAVE_SHM_CREATE_LARGEPAGE FALSE)
  #Have symbol shutdown
  set(HAVE_SHUTDOWN TRUE)
  #Have symbol sigaction
  set(HAVE_SIGACTION FALSE)
  #Have symbol sigprocmask
  set(HAVE_SIGPROCMASK FALSE)
  #Result of TRY_COMPILE
  set(HAVE_SIZEOF_GID_T FALSE)
  #Result of TRY_COMPILE
  #set(HAVE_SIZEOF_INT TRUE)
  #Result of TRY_COMPILE
  #set(HAVE_SIZEOF_INTMAX_T TRUE)
  #Result of TRY_COMPILE
  #set(HAVE_SIZEOF_LONG TRUE)
  #Result of TRY_COMPILE
  #set(HAVE_SIZEOF_LONG_LONG TRUE)
  #Result of TRY_COMPILE
  #set(HAVE_SIZEOF_OFF_T TRUE)
  #Result of TRY_COMPILE
  #set(HAVE_SIZEOF_PTRDIFF_T TRUE)
  #Result of TRY_COMPILE
  #set(HAVE_SIZEOF_SIZE_T TRUE)
  #Result of TRY_COMPILE
  set(HAVE_SIZEOF_SSIZE_T FALSE)
  #Result of TRY_COMPILE
  set(HAVE_SIZEOF_UID_T FALSE)
  #Have symbol sockatmark
  set(HAVE_SOCKATMARK FALSE)
  #Result of TRY_COMPILE
  set(HAVE_SOCKLEN_T TRUE)
  #Have symbol statfs
  set(HAVE_STATFS FALSE)
  #Have symbol statvfs
  set(HAVE_STATVFS FALSE)
  #Have include stddef.h
  set(HAVE_STDDEF_H TRUE)
  #Have include stdint.h
  set(HAVE_STDINT_H TRUE)
  #Have symbol std_syslog
  set(HAVE_STD_SYSLOG FALSE)
  #Have symbol strcasestr
  set(HAVE_STRCASESTR FALSE)
  #Have symbol strerror_r
  set(HAVE_STRERROR_R FALSE)
  #Have includes strings.h
  set(HAVE_STRINGS_H FALSE)
  #Have symbol strlcat
  set(HAVE_STRLCAT FALSE)
  #Have symbol strlcpy
  set(HAVE_STRLCPY FALSE)
  #Have symbol strndup
  set(HAVE_STRNDUP FALSE)
  #Have symbol strnlen
  set(HAVE_STRNLEN TRUE)
  #Have function strtok_r
  set(HAVE_STRTOK_R FALSE)
  #Result of TRY_COMPILE
  set(HAVE_STRUCT_CMSGCRED FALSE)
  #Result of TRY_COMPILE
  set(HAVE_STRUCT_FLOCK FALSE)
  #Test HAVE_STRUCT_SOCKADDR_SA_LEN
  set(HAVE_STRUCT_SOCKADDR_SA_LEN FALSE)
  #Result of TRY_COMPILE
  set(HAVE_STRUCT_SOCKADDR_STORAGE FALSE)
  #Test HAVE_STRUCT_SOCKADDR_STORAGE_SS_FAMILY
  set(HAVE_STRUCT_SOCKADDR_STORAGE_SS_FAMILY FALSE)
  #Test HAVE_STRUCT_SOCKADDR_UN_SUN_LEN
  set(HAVE_STRUCT_SOCKADDR_UN_SUN_LEN FALSE)
  #Test HAVE_STRUCT_STAT_ST_RDEV
  set(HAVE_STRUCT_STAT_ST_RDEV TRUE)
  #Test HAVE_STRUCT_TM_TM_GMTOFF
  set(HAVE_STRUCT_TM_TM_GMTOFF FALSE)
  #Test HAVE_STRUCT_TM_TM_ZONE
  set(HAVE_STRUCT_TM_TM_ZONE FALSE)
  #Result of TRY_COMPILE
  set(HAVE_STRUCT_UCRED FALSE)
  #Have includes sysexits.h
  set(HAVE_SYSEXITS_H FALSE)
  #Have includes sys/ioctl.h
  set(HAVE_SYS_IOCTL_H FALSE)
  #Have includes sys/ipc.h
  set(HAVE_SYS_IPC_H FALSE)
  #Have includes sys/loadavg.h
  set(HAVE_SYS_LOADAVG_H FALSE)
  #Have includes sys/mkdev.h
  set(HAVE_SYS_MKDEV_H FALSE)
  #Have includes sys/mman.h
  set(HAVE_SYS_MMAN_H FALSE)
  #Have includes sys/mount.h
  set(HAVE_SYS_MOUNT_H FALSE)
  #Have includes sys/param.h
  set(HAVE_SYS_PARAM_H FALSE)
  #Have includes sys/poll.h
  set(HAVE_SYS_POLL_H FALSE)
  #Have includes sys/pstat.h
  set(HAVE_SYS_PSTAT_H FALSE)
  #Have includes sys/resource.h
  set(HAVE_SYS_RESOURCE_H FALSE)
  #Have includes sys/select.h
  set(HAVE_SYS_SELECT_H FALSE)
  #Have includes sys/sockio.h
  set(HAVE_SYS_SOCKIO_H FALSE)
  #Have includes sys/statfs.h
  set(HAVE_SYS_STATFS_H FALSE)
  #Have includes sys/statvfs.h
  set(HAVE_SYS_STATVFS_H FALSE)
  #Have include sys/stat.h
  set(HAVE_SYS_STAT_H TRUE)
  #Have includes sys/sysexits.h
  set(HAVE_SYS_SYSEXITS_H FALSE)
  #Have includes sys/sysmacros.h
  set(HAVE_SYS_SYSMACROS_H FALSE)
  #Have include sys/types.h
  set(HAVE_SYS_TYPES_H TRUE)
  #Have includes sys/uio.h
  set(HAVE_SYS_UIO_H FALSE)
  #Have includes sys/utsname.h
  set(HAVE_SYS_UTSNAME_H FALSE)
  #Have includes sys/vfs.h
  set(HAVE_SYS_VFS_H FALSE)
  #Have includes ;termios.h
  set(HAVE_TERMIOS_H FALSE)
  #Have include tmmintrin.h
  set(HAVE_TMMINTRIN_H TRUE)
  #Have symbol tzset
  set(HAVE_TZSET TRUE)
  #Have includes unix.h
  set(HAVE_UNIX_H FALSE)
  #Have symbol unsetenv
  set(HAVE_UNSETENV FALSE)
  #Have includes ;util.h
  set(HAVE_UTIL_H FALSE)
  #Have symbol utime
  set(HAVE_UTIME TRUE)
  #Have symbol utimes
  set(HAVE_UTIMES FALSE)
  #Have includes utime.h
  set(HAVE_UTIME_H FALSE)
  #Have symbol vasprintf
  set(HAVE_VASPRINTF FALSE)
  #Have include ;winsock.h
  set(HAVE_WINSOCK_H TRUE)
  #Have include wmmintrin.h
  set(HAVE_WMMINTRIN_H TRUE)
  #Have include ;ws2tcpip.h
  set(HAVE_WS2TCPIP_H TRUE)
  #Test HAVE__CONTROLFP
  set(HAVE__CONTROLFP TRUE)
  #Test HAVE__CONTROLFP_S
  set(HAVE__CONTROLFP_S TRUE)
  #Test HAVE__FPU_SETCW
  set(HAVE__FPU_SETCW FALSE)

  #Have symbol CreateProcess
  set(PHP_HAS_CREATEPROCESS TRUE)

  #Have symbol __ELF__
  set(PHP_HAS_ELF FALSE)

  #Test PHP_HPUX_TIME_R
  set(PHP_HPUX_TIME_R FALSE)

  #Test PHP_IRIX_TIME_R
  set(PHP_IRIX_TIME_R FALSE)

  #Test PHP_IS_EBCDIC
  set(PHP_IS_EBCDIC FALSE)

  #Test PHP_HAS_FFP_CONTRACT_OFF_C
  set(PHP_HAS_FFP_CONTRACT_OFF_C FALSE)
  #Test PHP_HAS_FNO_COMMON_C
  set(PHP_HAS_FNO_COMMON_C FALSE)
  #Test PHP_HAS_FNO_COMMON_CXX
  set(PHP_HAS_FNO_COMMON_CXX FALSE)
  #Have symbol fopencookie
  set(PHP_HAS_FOPENCOOKIE FALSE)
  #Have symbol gethostbyname_r
  set(PHP_HAS_GETHOSTBYNAME_R FALSE)
  #Have symbol getifaddrs
  set(PHP_HAS_GETIFADDRS FALSE)
  #Have symbol inet_ntop
  #set(PHP_HAS_INET_NTOP TRUE)
  #Have symbol inet_pton
  #set(PHP_HAS_INET_PTON TRUE)
  #Have function pread
  set(PHP_HAS_PREAD FALSE)
  #Have includes pthread_np.h
  set(PHP_HAS_PTHREAD_NP_H FALSE)
  #Have function pwrite
  set(PHP_HAS_PWRITE FALSE)
  #Have symbol TIOCGWINSZ
  set(PHP_HAS_TIOCGWINSZ_IN_TERMIOS_H FALSE)
  #Test PHP_HAS_VERBOSE_LINKER_FLAG_C
  set(PHP_HAS_VERBOSE_LINKER_FLAG_C TRUE)
  #Test PHP_HAS_VERBOSE_LINKER_FLAG_CXX
  set(PHP_HAS_VERBOSE_LINKER_FLAG_CXX TRUE)
  #Test PHP_HAS_WDUPLICATED_COND_C
  set(PHP_HAS_WDUPLICATED_COND_C FALSE)
  #Test PHP_HAS_WDUPLICATED_COND_CXX
  set(PHP_HAS_WDUPLICATED_COND_CXX FALSE)
  #Test PHP_HAS_WEXTRA_C
  seT(PHP_HAS_WEXTRA_C FALSE)
  #Test PHP_HAS_WEXTRA_CXX
  set(PHP_HAS_WEXTRA_CXX FALSE)
  #Test PHP_HAS_WFORMAT_TRUNCATION_C
  seT(PHP_HAS_WFORMAT_TRUNCATION_C FALSE)
  #Test PHP_HAS_WFORMAT_TRUNCATION_CXX
  set(PHP_HAS_WFORMAT_TRUNCATION_CXX FALSE)
  #Test PHP_HAS_WIMPLICIT_FALLTHROUGH_1_C
  set(PHP_HAS_WIMPLICIT_FALLTHROUGH_1_C FALSE)
  #Test PHP_HAS_WIMPLICIT_FALLTHROUGH_1_CXX
  set(PHP_HAS_WIMPLICIT_FALLTHROUGH_1_CXX FALSE)
  #Test PHP_HAS_WLOGICAL_OP_C
  set(PHP_HAS_WLOGICAL_OP_C FALSE)
  #Test PHP_HAS_WLOGICAL_OP_CXX
  set(PHP_HAS_WLOGICAL_OP_CXX FALSE)
  #Test PHP_HAS_WNO_CLOBBERED_C
  set(PHP_HAS_WNO_CLOBBERED_C FALSE)
  #Test PHP_HAS_WNO_CLOBBERED_CXX
  set(PHP_HAS_WNO_CLOBBERED_CXX FALSE)
  #Test PHP_HAS_WNO_IMPLICIT_FALLTHROUGH_C
  seT(PHP_HAS_WNO_IMPLICIT_FALLTHROUGH_C FALSE)
  #Test PHP_HAS_WNO_SIGN_COMPARE_C
  set(PHP_HAS_WNO_SIGN_COMPARE_C FALSE)
  #Test PHP_HAS_WNO_SIGN_COMPARE_CXX
  set(PHP_HAS_WNO_SIGN_COMPARE_CXX FALSE)
  #Test PHP_HAS_WNO_UNUSED_PARAMETER_C
  set(PHP_HAS_WNO_UNUSED_PARAMETER_C FALSE)
  #Test PHP_HAS_WNO_UNUSED_PARAMETER_CXX
  set(PHP_HAS_WNO_UNUSED_PARAMETER_CXX FALSE)
  #Test PHP_HAS_WSTRICT_PROTOTYPES_C
  set(PHP_HAS_WSTRICT_PROTOTYPES_C FALSE)
  #Test PHP_HAVE_AVX512_SUPPORTS
  set(PHP_HAVE_AVX512_SUPPORTS TRUE)
  #Test PHP_HAVE_AVX512_VBMI_SUPPORTS
  set(PHP_HAVE_AVX512_VBMI_SUPPORTS TRUE)
endif()
