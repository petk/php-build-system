#[=============================================================================[
Specific configuration for Windows platform.
#]=============================================================================]

include_guard(GLOBAL)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  # Common compilation definitions.
  target_compile_definitions(
    php_configuration
    INTERFACE
      PHP_WIN32  # For PHP code
      _WIN32     # Defined by all compilers when targeting Windows. Left here
                 # to match the native PHP Windows build system.
      WIN32      # Defined by Windows SDK and some compilers (GCC and Clang)
                 # when targeting Windows. Left here for BC for possible PECL
                 # extensions not being updated yet. In new code it is being
                 # replaced with _WIN32.
      ZEND_WIN32 # For Zend engine
  )

  # To speed up the Windows build experience with Visual Studio generators,
  # these are always known on Windows systems.
  # TODO: Update and fix this better.

  # PHP has custom syslog.h for Windows platform.
  set(HAVE_SYSLOG_H 1)

  # PHP has custom usleep for Windows platform.
  set(HAVE_USLEEP 1)

  # PHP has custom nanosleep for Windows platform.
  set(HAVE_NANOSLEEP 1)

  # PHP supports socketpair by the emulation in win32/sockets.c
  set(HAVE_SOCKETPAIR 1)

  # PHP has unconditional getaddrinfo() support on Windows for now.
  set(HAVE_GETADDRINFO 1)

  set(HAVE_NICE 1)
endif()
