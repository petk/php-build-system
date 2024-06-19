include(CheckIncludeFile)
include(CheckIncludeFiles)
include(CheckSourceCompiles)
include(CheckSymbolExists)
include(CMakePushCheckState)
include(FeatureSummary)
include(PHP/SearchLibraries)

option(EXT_STANDARD_ARGON2 "Include the Argon2 support in password_*" OFF)

add_feature_info(
  "ext/standard Argon2"
  EXT_STANDARD_ARGON2
  "Argon2 support in password_* functions"
)

option(EXT_STANDARD_EXTERNAL_LIBCRYPT "Use external libcrypt or libxcrypt" OFF)

add_feature_info(
  "External librcypt"
  EXT_STANDARD_EXTERNAL_LIBCRYPT
  "External libcrypt or libxcrypt library"
)

################################################################################
# Add library.
################################################################################

add_library(php_standard STATIC)

file(GLOB _php_standard_headers ${CMAKE_CURRENT_SOURCE_DIR}/*.h)
# Exclude Windows header and specify it below separately.
list(FILTER _php_standard_headers EXCLUDE REGEX ".*winver\\.h$")

target_sources(
  php_standard
  PRIVATE
    array.c
    assert.c
    base64.c
    basic_functions.c
    browscap.c
    crc32.c
    credits.c
    crypt.c
    css.c
    datetime.c
    dir.c
    dl.c
    $<$<PLATFORM_ID:Windows>:dns_win32.c>
    dns.c
    exec.c
    file.c
    filestat.c
    filters.c
    flock_compat.c
    formatted_print.c
    fsock.c
    ftok.c
    ftp_fopen_wrapper.c
    head.c
    hrtime.c
    html.c
    http_fopen_wrapper.c
    http.c
    image.c
    incomplete_class.c
    info.c
    iptc.c
    levenshtein.c
    libavifinfo/avifinfo.c
    link.c
    mail.c
    math.c
    md5.c
    metaphone.c
    microtime.c
    net.c
    pack.c
    pageinfo.c
    password.c
    php_fopen_wrapper.c
    proc_open.c
    quot_print.c
    scanf.c
    sha1.c
    soundex.c
    streamsfuncs.c
    string.c
    strnatcmp.c
    syslog.c
    type.c
    uniqid.c
    url_scanner_ex.c
    url.c
    user_filters.c
    uuencode.c
    var_unserializer.c
    var.c
    versioning.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        ${_php_standard_headers}
        $<$<PLATFORM_ID:Windows>:winver.h>
)

# Check for ARM64 processor on Windows.
if(NOT CMAKE_SYSTEM_PROCESSOR STREQUAL "ARM64")
  target_sources(php_standard PRIVATE crc32_x86.c)
endif()

target_include_directories(
  php_standard
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/libavifinfo
)

target_compile_definitions(php_standard PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

# The standard extension depends on the generated Zend language parser.
add_dependencies(php_standard zend_patch_language_parser)

target_link_libraries(
  php_standard
  PRIVATE
    $<$<PLATFORM_ID:Windows>:iphlpapi>
    # TODO: Can this be fixed better?
    PHP::main
)

################################################################################
# Generate lexers.
################################################################################

if(RE2C_FOUND)
  re2c_target(
    php_standard_var_unserializer
    var_unserializer.re
    ${CMAKE_CURRENT_SOURCE_DIR}/var_unserializer.c
    OPTIONS -b
  )

  re2c_target(
    php_standard_url_scanner_ex
    url_scanner_ex.re
    ${CMAKE_CURRENT_SOURCE_DIR}/url_scanner_ex.c
    OPTIONS -b
  )

  add_dependencies(
    php_generate_files
    php_standard_var_unserializer
    php_standard_url_scanner_ex
  )
endif()

################################################################################
# Add Argon2.
################################################################################

if(EXT_STANDARD_ARGON2)
  find_package(Argon2 20171227)
  set_package_properties(
    Argon2
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to include Argon2 support in password_*."
  )

  target_link_libraries(php_standard PRIVATE Argon2::Argon2)

  set(HAVE_ARGON2LIB 1 CACHE INTERNAL "Whether to use the libargon2")
endif()

################################################################################
# External libcrypt.
################################################################################

if(NOT EXT_STANDARD_EXTERNAL_LIBCRYPT)
  target_sources(
    php_standard
    PRIVATE
      crypt_blowfish.c
      crypt_freesec.c
      crypt_sha256.c
      crypt_sha512.c
      php_crypt_r.c
  )

  set(PHP_USE_PHP_CRYPT_R 1 CACHE INTERNAL "Whether PHP uses its own crypt_r")
else()
  find_package(Crypt)
  set_package_properties(
    Crypt
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to use external crypt library."
  )

  target_link_libraries(php_standard PRIVATE Crypt::Crypt)
endif()

################################################################################
# Configuration checks.
################################################################################

# Check if there is a support means of creating a new process and defining which
# handles it receives.
message(CHECK_START "Checking if OS can spawn processes with inherited handles")
check_symbol_exists(fork "unistd.h" HAVE_FORK)
if(NOT HAVE_FORK)
  check_symbol_exists(CreateProcess "windows.h" HAVE_CREATEPROCESS)
endif()
if(HAVE_FORK OR HAVE_CREATEPROCESS)
  set(
    PHP_CAN_SUPPORT_PROC_OPEN 1
    CACHE INTERNAL "Define if system has fork/vfork/CreateProcess"
  )

  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

# The getifaddrs() is available in C library some systems (Solaris 11.4...)
php_search_libraries(
  getifaddrs
  _HAVE_GETIFADDRS
  HEADERS ifaddrs.h
  LIBRARIES
    socket  # Solaris 11..11.3, illumos
    network # Haiku
  LIBRARY_VARIABLE libraryForGetifaddrs
  TARGET php_standard PRIVATE
)

if(_HAVE_GETIFADDRS)
  message(CHECK_START "Checking for usable getifaddrs")
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES ${libraryForGetifaddrs})
    set(CMAKE_REQUIRED_QUIET TRUE)
    check_source_compiles(C "
      #include <sys/types.h>
      #include <ifaddrs.h>
      int main(void) {
        struct ifaddrs *interfaces;
        if (!getifaddrs(&interfaces)) {
          freeifaddrs(interfaces);
        }
        return 0;
      }
    " HAVE_GETIFADDRS)
  cmake_pop_check_state()
  if(HAVE_GETIFADDRS)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
endif()

# Check net/if.h for PHP net_get_interfaces().
if(HAVE_SYS_SOCKET_H)
  # Darwin and BSD-like systems also need sys/socket.h to include net/if.h.
  check_include_files("sys/socket.h;net/if.h" HAVE_NET_IF_H)
else()
  check_include_file(net/if.h HAVE_NET_IF_H)
endif()

# Check how flush should be called.
include(PHP/CheckFlushIo)

# Check for fnmatch() implementation.
include(PHP/CheckFnmatch)

# Detect library functions needed by PHP dns_xxx functions.
# ext/standard/php_dns.h will collect these in a single define
# HAVE_FULL_DNS_FUNCS.
php_search_libraries(
  res_nsearch
  HAVE_RES_NSEARCH
  HEADERS
    netinet/in.h # BSD-based systems (FreeBSD<=13) need it for resolv.h to work.
    resolv.h
  LIBRARIES
    resolv # Solaris/illumos
  TARGET php_standard PRIVATE
)

php_search_libraries(
  res_ndestroy
  HAVE_RES_NDESTROY
  HEADERS
    netinet/in.h # BSD-based systems (FreeBSD<=13) need it for resolv.h to work.
    resolv.h
  LIBRARIES
    resolv # Solaris/illumos
  TARGET php_standard PRIVATE
)

php_search_libraries(
  dns_search
  HAVE_DNS_SEARCH
  HEADERS
    netinet/in.h # BSD-based systems (FreeBSD<=13) need it for resolv.h to work.
    resolv.h
    dns.h        # macOS
  LIBRARIES
    resolv # Solaris/illumos, macOS
  TARGET php_standard PRIVATE
)

php_search_libraries(
  dn_expand
  HAVE_DN_EXPAND
  HEADERS
    netinet/in.h # BSD-based systems (FreeBSD<=13) need it for resolv.h to work.
    resolv.h
  LIBRARIES
    resolv # Solaris/illumos
  TARGET php_standard PRIVATE
)

php_search_libraries(
  dn_skipname
  HAVE_DN_SKIPNAME
  HEADERS
    netinet/in.h # BSD-based systems (FreeBSD<=13) need it for resolv.h to work.
    resolv.h
  LIBRARIES
    resolv # Solaris/illumos
  TARGET php_standard PRIVATE
)

# res_search() is deprecated and should be replaced with res_nsearch().
php_search_libraries(
  res_search
  HAVE_RES_SEARCH
  HEADERS
    netinet/in.h # BSD-based systems (FreeBSD<=13) need it for resolv.h to work.
    resolv.h
  LIBRARIES
    resolv # Solaris/illumos
  TARGET php_standard PRIVATE
)

check_symbol_exists(
  posix_spawn_file_actions_addchdir_np
  "spawn.h"
  HAVE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR_NP
)

# TODO: Check whether to enable the chroot() function by checking which SAPI is
# being built.
set(ENABLE_CHROOT_FUNC 1 CACHE INTERNAL "Whether to enable chroot() function")
