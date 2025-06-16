#[=============================================================================[
Specific configuration for Windows platform.
#]=============================================================================]

include_guard(GLOBAL)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  # To speed up the Windows build experience with Visual Studio generators,
  # these are always known on Windows systems.

  # Whether system has <alloca.h> header.
  set(HAVE_ALLOCA_H FALSE)

  # Whether system has <dirent.h> header.
  set(HAVE_DIRENT_H FALSE)

  # PHP has fnmatch() emulation implemented on Windows.
  set(HAVE_FNMATCH TRUE)

  # Whether system has flock().
  set(HAVE_FLOCK FALSE)

  # PHP has ftok() emulation implemented on Windows.
  set(HAVE_FTOK TRUE)

  # PHP has unconditional getaddrinfo() support on Windows.
  set(HAVE_GETADDRINFO TRUE)

  # PHP has unconditional support for getcwd() on Windows.
  set(HAVE_GETCWD TRUE)

  # PHP defines getpid as _getpid on Windows.
  set(HAVE_GETPID TRUE)

  # PHP has getrusage() emulation implemented on Windows.
  set(HAVE_GETRUSAGE TRUE)

  # PHP has gettimeofday() emulation implemented on Windows.
  set(HAVE_GETTIMEOFDAY TRUE)

  # Whether system has <grp.h> header.
  set(HAVE_GRP_H FALSE)

  # Whether system has kill().
  set(HAVE_KILL FALSE)

  # Windows has LoadLibrary().
  set(HAVE_LIBDL TRUE)

  # PHP has nanosleep() emulation implemented on Windows.
  set(HAVE_NANOSLEEP TRUE)

  # PHP has nice() emulation implemented on Windows.
  set(HAVE_NICE TRUE)

  # Whether system has <pwd.h> header.
  set(HAVE_PWD_H FALSE)

  # Whether systems has setitimer().
  set(HAVE_SETITIMER FALSE)

  # Windows has setjmp() in <setjmp.h> instead.
  set(HAVE_SIGSETJMP FALSE)

  # PHP has socketpair() emulation implemented on Windows.
  set(HAVE_SOCKETPAIR TRUE)

  # PHP defines strcasecmp in Zend/zend_config.w32.h.
  set(HAVE_STRCASECMP TRUE)

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

  # PHP has syslog.h emulation implemented on Windows.
  set(HAVE_SYSLOG_H TRUE)

  # Whether 'st_blksize' is a member of 'struct stat'.
  set(HAVE_STRUCT_STAT_ST_BLKSIZE FALSE)

  # Whether 'st_blocks' is a member of 'struct stat'.
  set(HAVE_STRUCT_STAT_ST_BLOCKS FALSE)

  # Whether system has <unistd.h>.
  set(HAVE_UNISTD_H FALSE)

  # PHP has usleep() emulation implemented on Windows.
  set(HAVE_USLEEP TRUE)
endif()
