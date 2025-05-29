#[=============================================================================[
Specific configuration for Windows platform.
#]=============================================================================]

include_guard(GLOBAL)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  # Common compilation definitions.
  target_compile_definitions(
    php_config
    INTERFACE
      PHP_WIN32  # For PHP code
      _WIN32     # Defined by all compilers when targeting Windows. Left here
                 # to match the native PHP Windows build system.
      WIN32      # Defined by Windows SDK and some compilers (GCC and Clang)
                 # when targeting Windows. Left here for BC for possible PECL
                 # extensions not being updated yet. In new code it is being
                 # replaced with _WIN32.
      ZEND_WIN32 # For Zend Engine
  )

  # To speed up the Windows build experience with Visual Studio generators,
  # these are always known on Windows systems.
  # TODO: Update and fix this better.

  set(HAVE_FNMATCH TRUE)

  # PHP has unconditional getaddrinfo() support on Windows for now.
  set(HAVE_GETADDRINFO TRUE)

  # PHP defines getpid as _getpid on Windows.
  set(HAVE_GETPID TRUE)

  # PHP has custom glob() implemented on Windows.
  set(HAVE_GLOB TRUE)

  # PHP has custom nanosleep for Windows platform.
  set(HAVE_NANOSLEEP TRUE)

  set(HAVE_NICE TRUE)

  # PHP supports socketpair by the emulation in win32/sockets.c.
  set(HAVE_SOCKETPAIR TRUE)

  # PHP defines strcasecmp in zend_config.w32.h.
  set(HAVE_STRCASECMP TRUE)

  # PHP has custom syslog.h for Windows platform.
  set(HAVE_SYSLOG_H TRUE)

  # PHP has custom usleep for Windows platform.
  set(HAVE_USLEEP TRUE)
endif()
