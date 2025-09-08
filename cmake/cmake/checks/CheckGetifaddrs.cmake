#[=============================================================================[
Check for usable getifaddrs(). Instead of only checking for symbol, this check
also ensures that struct ifaddrs is available and the entire usage is declared
in belonging headers. On modern systems, only checking for getifaddrs symbol and
library should be sufficient.

The getifaddrs() is mostly available in C library (Linux, Solaris 11.4...) with
few noted exceptions below. Some systems also need <sys/types.h> header
(NetBSD, OpenBSD, and older FreeBSD).
#]=============================================================================]

include(PHP/SearchLibraries)

php_search_libraries(
  SOURCE [[
    #include <sys/types.h>
    #include <ifaddrs.h>

    int main(void)
    {
      struct ifaddrs *interfaces;
      if (!getifaddrs(&interfaces)) {
        freeifaddrs(interfaces);
      }

      return 0;
    }
  ]]
  LIBRARIES
    socket  # Solaris 11..11.3, illumos
    network # Haiku
  RESULT_VARIABLE PHP_HAVE_GETIFADDRS
  TARGET php_config INTERFACE
)
set(HAVE_GETIFADDRS "${PHP_HAVE_GETIFADDRS}")
