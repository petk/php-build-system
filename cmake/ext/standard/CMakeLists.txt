include(CheckIncludeFile)
include(CheckIncludeFiles)
include(CheckSourceCompiles)
include(CheckSymbolExists)
include(FeatureSummary)
include(PHP/SearchLibraries)

option(EXT_STANDARD_ARGON2 "Include the Argon2 support in password_*" OFF)

add_feature_info(
  "ext/standard Argon2"
  EXT_STANDARD_ARGON2
  "Argon2 support in password_* functions."
)

option(EXT_STANDARD_EXTERNAL_LIBCRYPT "Use external libcrypt or libxcrypt" OFF)

add_feature_info(
  "External librcypt"
  EXT_STANDARD_EXTERNAL_LIBCRYPT
  "External libcrypt or libxcrypt library."
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
      BASE_DIRS "${PHP_SOURCE_DIR}"
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

add_dependencies(php_standard Zend::Zend)

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
    NAME php_standard_var_unserializer
    INPUT "${CMAKE_CURRENT_SOURCE_DIR}/var_unserializer.re"
    OUTPUT "${CMAKE_CURRENT_SOURCE_DIR}/var_unserializer.c"
    OPTIONS "--no-generation-date -b"
  )

  re2c_target(
    NAME php_standard_url_scanner_ex
    INPUT "${CMAKE_CURRENT_SOURCE_DIR}/url_scanner_ex.re"
    OUTPUT "${CMAKE_CURRENT_SOURCE_DIR}/url_scanner_ex.c"
    OPTIONS "--no-generation-date -b"
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
check_symbol_exists(CreateProcess "windows.h" HAVE_CREATEPROCESS)
if(HAVE_FORK OR HAVE_CREATEPROCESS)
  set(
    PHP_CAN_SUPPORT_PROC_OPEN 1
    CACHE INTERNAL "Define if system has fork/vfork/CreateProcess"
  )

  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

message(CHECK_START "Checking for usable getifaddrs")
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
if(HAVE_GETIFADDRS)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

# Check for __attribute__ ((__aligned__)) support in the compiler.
message(CHECK_START "Checking whether the compiler supports aligned attribute")
check_source_compiles(C "
  int main(void) {
    unsigned char test[32] __attribute__ ((__aligned__ (__alignof__ (int))));
    return 0;
  }
" HAVE_ATTRIBUTE_ALIGNED)
if(HAVE_ATTRIBUTE_ALIGNED)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
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

# Check whether the strptime() declaration fails.
include(PHP/CheckStrptime)

# Check for fnmatch() implementation.
include(PHP/CheckFnmatch)

# Detect library functions needed by PHP dns_xxx functions.
# ext/standard/php_dns.h will collect these in a single define
# HAVE_FULL_DNS_FUNCS.
php_search_libraries(
  res_nsearch
  resolv.h
  HAVE_RES_NSEARCH
  RES_NSEARCH_LIBRARY
  LIBRARIES
    resolv
    socket
)
if(RES_NSEARCH_LIBRARY)
  target_link_libraries(php_standard PRIVATE ${RES_NSEARCH_LIBRARY})
endif()

php_search_libraries(
  res_ndestroy
  resolv.h
  HAVE_RES_NDESTROY
  RES_NDESTROY_LIBRARY
  LIBRARIES
    resolv
    socket
)
if(RES_NDESTROY_LIBRARY)
  target_link_libraries(php_standard PRIVATE ${RES_NDESTROY_LIBRARY})
endif()

php_search_libraries(
  dns_search
  resolv.h
  HAVE_DNS_SEARCH
  DNS_SEARCH_LIBRARY
  LIBRARIES
    resolv
    socket
)
if(DNS_SEARCH_LIBRARY)
  target_link_libraries(php_standard PRIVATE ${DNS_SEARCH_LIBRARY})
endif()

php_search_libraries(
  dn_expand
  resolv.h
  HAVE_DN_EXPAND
  DN_EXPAND_LIBRARY
  LIBRARIES
    resolv
    socket
)
if(DN_EXPAND_LIBRARY)
  target_link_libraries(php_standard PRIVATE ${DN_EXPAND_LIBRARY})
endif()

php_search_libraries(
  dn_skipname
  resolv.h
  HAVE_DN_SKIPNAME
  DN_SKIPNAME_LIBRARY
  LIBRARIES
    resolv
    socket
)
if(DN_SKIPNAME_LIBRARY)
  target_link_libraries(php_standard PRIVATE ${DN_SKIPNAME_LIBRARY})
endif()

# res_search() is deprecated and should be replaced with res_nsearch().
php_search_libraries(
  res_search
  resolv.h
  HAVE_RES_SEARCH
  RES_SEARCH_LIBRARY
  LIBRARIES
    resolv
    socket
)
if(RES_SEARCH_LIBRARY)
  target_link_libraries(php_standard PRIVATE ${RES_SEARCH_LIBRARY})
endif()

check_symbol_exists(
  posix_spawn_file_actions_addchdir_np
  "spawn.h"
  HAVE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR_NP
)

# TODO: Check whether to enable the chroot() function by checking which SAPI is
# being built.
set(ENABLE_CHROOT_FUNC 1 CACHE INTERNAL "Whether to enable chroot() function")

################################################################################
# Installation.
################################################################################

install(
  TARGETS php_standard
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET HEADERS
)
