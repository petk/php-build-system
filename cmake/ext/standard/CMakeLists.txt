include(CheckCSourceCompiles)
include(CheckCSourceRuns)
include(CheckLibraryExists)
include(CheckSymbolExists)

option(EXT_STANDARD_EXTERNAL_LIBCRYPT "Whether to use external libcrypt library" OFF)

option(EXT_STANDARD_ARGON2 "Whether to include the Argon2 support in password_*" OFF)

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

# Check how flush should be called.
include(PHP/CheckFlushIo)

# Check if OS can spawn processes with inherited handles.
include(PHP/CheckProcOpenSupport)

# Check whether the strptime() declaration fails.
include(PHP/CheckStrptime)

# Check for fnmatch() implementation.
include(PHP/CheckFnmatch)

message(STATUS "Checking for usable getifaddrs")
check_c_source_runs("
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

# Check for __attribute__ ((__aligned__)) support in the compiler.
message(STATUS "Checking whether the compiler supports aligned attribute")

check_c_source_compiles("
  int main(void) {
    unsigned char test[32] __attribute__ ((__aligned__ (__alignof__ (int))));
    return 0;
  }
" HAVE_ATTRIBUTE_ALIGNED)

# TODO: Check whether to enable the chroot() function by checking which SAPI is
# being built.
set(ENABLE_CHROOT_FUNC 1 CACHE INTERNAL "Whether to enable chroot() function")

php_extension(NAME "standard" STATIC)

add_library(ext_standard STATIC
  array.c
  base64.c
  basic_functions.c
  browscap.c
  crc32.c
  crypt.c
  datetime.c
  dir.c
  dl.c
  dns.c
  exec.c
  file.c
  filestat.c
  flock_compat.c
  formatted_print.c
  fsock.c
  head.c
  html.c
  image.c
  info.c
  iptc.c
  link.c
  mail.c
  math.c
  md5.c
  metaphone.c
  microtime.c
  pack.c
  pageinfo.c
  quot_print.c
  soundex.c
  string.c
  scanf.c
  syslog.c
  type.c
  uniqid.c
  url.c
  var.c
  versioning.c
  assert.c
  strnatcmp.c
  levenshtein.c
  incomplete_class.c
  url_scanner_ex.c
  ftp_fopen_wrapper.c
  http_fopen_wrapper.c
  php_fopen_wrapper.c
  credits.c
  css.c
  var_unserializer.c
  ftok.c
  sha1.c
  user_filters.c
  uuencode.c
  filters.c
  proc_open.c
  streamsfuncs.c
  http.c
  password.c
  net.c
  hrtime.c
  crc32_x86.c
  libavifinfo/avifinfo.c
)

if(RE2C_FOUND)
  re2c_target(
    NAME varUnserializer
    INPUT "${CMAKE_CURRENT_SOURCE_DIR}/var_unserializer.re"
    OUTPUT "${CMAKE_CURRENT_SOURCE_DIR}/var_unserializer.c"
    OPTIONS "--no-generation-date -b"
  )

  re2c_target(
    NAME urlScannerEx
    INPUT "${CMAKE_CURRENT_SOURCE_DIR}/url_scanner_ex.re"
    OUTPUT "${CMAKE_CURRENT_SOURCE_DIR}/url_scanner_ex.c"
    OPTIONS "--no-generation-date -b"
  )
endif()

target_include_directories(
  ext_standard
  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/libavifinfo
)

if(NOT EXT_STANDARD_EXTERNAL_LIBCRYPT)
  target_sources(ext_standard PRIVATE crypt_freesec.c crypt_blowfish.c crypt_sha512.c crypt_sha256.c php_crypt_r.c)
  set(PHP_USE_PHP_CRYPT_R 1 CACHE INTERNAL "Whether PHP has to use its own crypt_r")
else()
  include(PHP/CheckExternalLibcrypt)

  if(CRYPT_EXTRA_LIBRARIES)
    list(APPEND STANDARD_EXTRA_LIBRARIES ${CRYPT_EXTRA_LIBRARIES})
  endif()

  set(PHP_USE_PHP_CRYPT_R 0 CACHE INTERNAL "Whether PHP has to use its own crypt_r")
endif()

if(EXT_STANDARD_ARGON2)
  find_package(ARGON 20171227 REQUIRED)

  if(ARGON_FOUND)
    set(HAVE_ARGON2LIB 1 CACHE INTERNAL "Whether to use the libargon2")

    if(ARGON_LIBRARIES)
      target_link_libraries(ext_standard PRIVATE ${ARGON_LIBRARIES})
    endif()

    if(ARGON_INCLUDE_DIRS)
      target_include_directories(ext_standard PRIVATE ${ARGON_INCLUDE_DIRS})
    endif()
  endif()
endif()

target_compile_definitions(ext_standard PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

add_dependencies(ext_standard Zend)

# TODO: Can this be fixed better?
target_link_libraries(ext_standard PRIVATE main)

if(STANDARD_EXTRA_LIBRARIES)
  list(REMOVE_DUPLICATES ${STANDARD_EXTRA_LIBRARIES})
  target_link_libraries(ext_standard PRIVATE ${STANDARD_EXTRA_LIBRARIES})
endif()

file(GLOB _ext_standard_headers "${CMAKE_CURRENT_SOURCE_DIR}/*.h")

target_sources(
  ext_standard
  PUBLIC FILE_SET ext_standard_headers
  TYPE HEADERS
  FILES ${_ext_standard_headers}
)

install(
  TARGETS ext_standard
  FILE_SET ext_standard_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/standard
)
