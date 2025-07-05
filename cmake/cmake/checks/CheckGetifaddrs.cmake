#[=============================================================================[
Check for usable getifaddrs().
#]=============================================================================]

include_guard(GLOBAL)

include(CheckSourceCompiles)
include(CMakePushCheckState)
include(PHP/SearchLibraries)

# The getifaddrs() is mostly available in C library (Linux, Solaris 11.4...).
php_search_libraries(
  getifaddrs
  HEADERS
    sys/types.h # Needed on some obsolete systems. Which ones?
    ifaddrs.h
  LIBRARIES
    socket  # Solaris 11..11.3, illumos
    network # Haiku
  VARIABLE PHP_HAS_GETIFADDRS_SYMBOL
  LIBRARY_VARIABLE PHP_HAS_GETIFADDRS_LIBRARY
)

if(PHP_HAS_GETIFADDRS_SYMBOL AND NOT DEFINED PHP_HAS_GETIFADDRS)
  message(CHECK_START "Checking for usable getifaddrs")
  cmake_push_check_state(RESET)
    if(PHP_HAS_GETIFADDRS_LIBRARY)
      set(CMAKE_REQUIRED_LIBRARIES ${PHP_HAS_GETIFADDRS_LIBRARY})
    endif()
    set(CMAKE_REQUIRED_QUIET TRUE)
    check_source_compiles(C [[
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
    ]] PHP_HAS_GETIFADDRS)
  cmake_pop_check_state()

  if(PHP_HAS_GETIFADDRS)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
endif()

if(PHP_HAS_GETIFADDRS AND PHP_HAS_GETIFADDRS_LIBRARY)
  target_link_libraries(php_config INTERFACE ${PHP_HAS_GETIFADDRS_LIBRARY})
endif()

set(HAVE_GETIFADDRS "${PHP_HAS_GETIFADDRS}")
