#[=============================================================================[
Specific configuration for Windows platform.
#]=============================================================================]

include_guard(GLOBAL)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  ##############################################################################
  # Emulated functionality by php-src/win32.
  ##############################################################################

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

  # PHP has nice() emulation implemented on Windows.
  set(HAVE_NICE TRUE)

  # PHP defines strcasecmp in Zend/zend_config.w32.h.
  set(HAVE_STRCASECMP TRUE)

  # PHP has syslog.h emulation implemented on Windows.
  set(HAVE_SYSLOG_H TRUE)

  # PHP has usleep() emulation implemented on Windows.
  set(HAVE_USLEEP TRUE)

  # Windows has LoadLibrary().
  set(PHP_HAS_DYNAMIC_LOADING TRUE)

  # PHP has nanosleep() emulation implemented on Windows.
  set(PHP_HAS_NANOSLEEP TRUE)

  # PHP has socketpair() emulation implemented on Windows.
  set(PHP_HAS_SOCKETPAIR TRUE)

  ##############################################################################
  # To speed up the Windows build experience where configuration phase takes
  # much longer compared to POSIX-based environments, the following are always
  # known on Windows targets.
  ##############################################################################

  set(HAVE_ALLOCA_H FALSE)
  set(HAVE_DIRENT_H FALSE)
  set(HAVE_FLOCK FALSE)
  set(HAVE_GRP_H FALSE)
  set(HAVE_KILL FALSE)
  set(HAVE_PWD_H FALSE)
  set(HAVE_SETITIMER FALSE)
  set(HAVE_SIGSETJMP FALSE) # Windows has setjmp() in <setjmp.h> instead.
  set(HAVE_STRUCT_STAT_ST_BLKSIZE FALSE)
  set(HAVE_STRUCT_STAT_ST_BLOCKS FALSE)
  set(HAVE_SYMLINK FALSE)
  set(HAVE_SYS_FILE_H FALSE)
  set(HAVE_SYS_SOCKET_H FALSE)
  set(HAVE_SYS_TIME_H FALSE)
  set(HAVE_SYS_WAIT_H FALSE)
  set(HAVE_UNISTD_H FALSE)

  set(PHP_EXT_GD_HAS_FLOORF TRUE)
  set(PHP_EXT_OPCACHE_HAS_FLOOR TRUE)
  set(PHP_HAS_DN_EXPAND FALSE)
  set(PHP_HAS_DN_SKIPNAME FALSE)
  set(PHP_HAS_DNS_SEARCH FALSE)
  set(PHP_HAS_GAI_STRERROR FALSE)
  set(PHP_HAS_GETADDRINFO TRUE)
  set(PHP_HAS_GETADDRINFO_LIBRARY ws2_32)
  set(PHP_HAS_GETADDRINFO_SYMBOL TRUE)
  set(PHP_HAS_GETHOSTBYADDR TRUE)
  set(PHP_HAS_GETHOSTBYADDR_LIBRARY ws2_32)
  set(PHP_HAS_GETHOSTBYNAME_R FALSE)
  set(PHP_HAS_GETHOSTNAME TRUE)
  set(PHP_HAS_GETHOSTNAME_LIBRARY ws2_32)
  set(PHP_HAS_GETIFADDRS_SYMBOL FALSE)
  set(PHP_HAS_GETPROBYNUMBER TRUE)
  set(PHP_HAS_GETPROBYNUMBER_LIBRARY ws2_32)
  set(PHP_HAS_GETPROTOBYNAME TRUE)
  set(PHP_HAS_GETPROTOBYNAME_LIBRARY ws2_32)
  set(PHP_HAS_GETSERVBYNAME TRUE)
  set(PHP_HAS_GETSERVBYNAME_LIBRARY ws2_32)
  set(PHP_HAS_GETSERVBYPORT TRUE)
  set(PHP_HAS_GETSERVBYPORT_LIBRARY ws2_32)
  set(PHP_HAS_INET_ATON FALSE)
  set(PHP_HAS_INET_NTOA FALSE)
  set(PHP_HAS_INET_NTOP TRUE)
  set(PHP_HAS_INET_NTOP_LIBRARY ws2_32)
  set(PHP_HAS_INET_PTON TRUE)
  set(PHP_HAS_INET_PTON_LIBRARY ws2_32)
  set(PHP_HAS_OPENPTY FALSE)
  set(PHP_HAS_RES_9_DN_SKIPNAME FALSE)
  set(PHP_HAS_RES_NDESTROY FALSE)
  set(PHP_HAS_RES_NSEARCH FALSE)
  set(PHP_HAS_RES_SEARCH FALSE)
  set(PHP_HAS_SETSOCKOPT TRUE)
  set(PHP_HAS_SETSOCKOPT_LIBRARY ws2_32)
  set(PHP_HAS_SHUTDOWN TRUE)
  set(PHP_HAS_SHUTDOWN_LIBRARY ws2_32)
  set(PHP_HAS_SIN TRUE)
  set(PHP_HAS_SOCKET TRUE)
  set(PHP_HAS_SOCKET_LIBRARY ws2_32)
endif()
