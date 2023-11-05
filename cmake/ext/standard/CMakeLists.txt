include(CheckCSourceCompiles)
include(CheckIncludeFile)
include(CheckIncludeFiles)
include(CheckLibraryExists)
include(CheckSymbolExists)
include(FeatureSummary)

option(EXT_STANDARD_ARGON2 "Include the Argon2 support in password_*" OFF)

add_feature_info("Argon2" EXT_STANDARD_ARGON2
  "Argon2 support in password_* functions."
)

option(EXT_STANDARD_EXTERNAL_LIBCRYPT "Use external libcrypt library" OFF)

add_feature_info("External librcypt" EXT_STANDARD_EXTERNAL_LIBCRYPT
  "External libcrypt library."
)

################################################################################
# Add library.
################################################################################

add_library(php_standard STATIC
  array.c
  assert.c
  base64.c
  basic_functions.c
  browscap.c
  crc32_x86.c
  crc32.c
  credits.c
  crypt.c
  css.c
  datetime.c
  dir.c
  dl.c
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
)

target_include_directories(
  php_standard
  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/libavifinfo
)

target_compile_definitions(php_standard PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

add_dependencies(php_standard zend)

# TODO: Can this be fixed better?
target_link_libraries(php_standard PRIVATE PHP::main)

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
  set_package_properties(Argon2 PROPERTIES
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
  target_sources(php_standard PRIVATE
    crypt_blowfish.c
    crypt_freesec.c
    crypt_sha256.c
    crypt_sha512.c
    php_crypt_r.c
  )

  set(PHP_USE_PHP_CRYPT_R 1 CACHE INTERNAL "Whether PHP has to use its own crypt_r")
else()
  include(PHP/CheckExternalLibcrypt)

  if(CRYPT_EXTRA_LIBRARIES)
    target_link_libraries(php_standard PRIVATE ${CRYPT_EXTRA_LIBRARIES})
  endif()

  set(PHP_USE_PHP_CRYPT_R 0 CACHE INTERNAL "Whether PHP has to use its own crypt_r")
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
check_c_source_compiles("
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
check_c_source_compiles("
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

################################################################################
# TODO: Fix the following checks better.
################################################################################

# Detect library functions needed by php dns_xxx functions.
# ext/standard/php_dns.h will collect these in a single define
# HAVE_FULL_DNS_FUNCS.
set(STANDARD_EXTRA_LIBRARIES "")

check_symbol_exists(posix_spawn_file_actions_addchdir_np "spawn.h" HAVE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR_NP)

check_symbol_exists(res_nsearch "resolv.h" HAVE_RES_NSEARCH)
if(NOT HAVE_RES_NSEARCH)
  set(LIBRARIES_TO_CHECK resolv bind socket)

  foreach(library ${LIBRARIES_TO_CHECK})
    check_library_exists(${library} res_nsearch "" HAVE_RES_NSEARCH)

    if(HAVE_RES_NSEARCH)
      list(APPEND STANDARD_EXTRA_LIBRARIES ${library})
      break()
    endif()
  endforeach()
endif()

check_symbol_exists(res_ndestroy "resolv.h" HAVE_RES_NDESTROY)
if(NOT HAVE_RES_NDESTROY)
  set(LIBRARIES_TO_CHECK resolv bind socket)

  foreach(library ${LIBRARIES_TO_CHECK})
    check_library_exists(${library} res_ndestroy "" HAVE_RES_NDESTROY)

    if(HAVE_RES_NDESTROY)
      list(APPEND STANDARD_EXTRA_LIBRARIES ${library})
      break()
    endif()
  endforeach()
endif()

check_symbol_exists(dns_search "resolv.h" HAVE_DNS_SEARCH)
if(NOT HAVE_DNS_SEARCH)
  set(LIBRARIES_TO_CHECK resolv bind socket)

  foreach(library ${LIBRARIES_TO_CHECK})
    check_library_exists(${library} dns_search "" HAVE_DNS_SEARCH)

    if(HAVE_DNS_SEARCH)
      list(APPEND STANDARD_EXTRA_LIBRARIES ${library})
      break()
    endif()
  endforeach()
endif()

check_symbol_exists(dn_expand "resolv.h" HAVE_DN_EXPAND)
if(NOT HAVE_DN_EXPAND)
  set(LIBRARIES_TO_CHECK resolv bind socket)

  foreach(library ${LIBRARIES_TO_CHECK})
    check_library_exists(${library} dn_expand "" HAVE_DN_EXPAND)

    if(HAVE_DN_EXPAND)
      list(APPEND STANDARD_EXTRA_LIBRARIES ${library})
      break()
    endif()
  endforeach()
endif()

check_symbol_exists(dn_skipname "resolv.h" HAVE_DN_SKIPNAME)
if(NOT HAVE_DN_SKIPNAME)
  set(LIBRARIES_TO_CHECK resolv bind socket)

  foreach(library ${LIBRARIES_TO_CHECK})
    check_library_exists(${library} dn_skipname "" HAVE_DN_SKIPNAME)

    if(HAVE_DN_SKIPNAME)
      list(APPEND STANDARD_EXTRA_LIBRARIES ${library})
      break()
    endif()
  endforeach()
endif()

check_symbol_exists(res_search "resolv.h" HAVE_RES_SEARCH)
if(NOT HAVE_RES_SEARCH)
  set(LIBRARIES_TO_CHECK resolv bind socket)

  foreach(library ${LIBRARIES_TO_CHECK})
    check_library_exists(${library} res_search "" HAVE_RES_SEARCH)

    if(HAVE_RES_SEARCH)
      list(APPEND STANDARD_EXTRA_LIBRARIES ${library})
      break()
    endif()
  endforeach()
endif()

if(STANDARD_EXTRA_LIBRARIES)
  list(REMOVE_DUPLICATES STANDARD_EXTRA_LIBRARIES)
  target_link_libraries(php_standard PRIVATE ${STANDARD_EXTRA_LIBRARIES})
endif()

# TODO: Check whether to enable the chroot() function by checking which SAPI is
# being built.
set(ENABLE_CHROOT_FUNC 1 CACHE INTERNAL "Whether to enable chroot() function")

################################################################################
# Install headers.
################################################################################

file(GLOB _standard_headers_files "${CMAKE_CURRENT_SOURCE_DIR}/*.h")

target_sources(
  php_standard
  PUBLIC FILE_SET standard_headers
  TYPE HEADERS
  FILES ${_standard_headers_files}
)

install(
  TARGETS php_standard
  FILE_SET standard_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/standard
)
