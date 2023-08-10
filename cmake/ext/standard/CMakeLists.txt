include(CheckCSourceCompiles)
include(CheckCSourceRuns)
include(CheckSymbolExists)
include(PHPFindPackage)

check_symbol_exists(crypt "crypt.h" HAVE_CRYPT)
check_symbol_exists(dn_expand "resolv.h" HAVE_DN_EXPAND)
check_symbol_exists(dn_skipname "resolv.h" HAVE_DN_SKIPNAME)
check_symbol_exists(dns_search "resolv.h" HAVE_DNS_SEARCH)
check_symbol_exists(posix_spawn_file_actions_addchdir_np "spawn.h" HAVE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR_NP)
check_symbol_exists(res_ndestroy "resolv.h" HAVE_RES_NDESTROY)
check_symbol_exists(res_nsearch "resolv.h" HAVE_RES_NSEARCH)
check_symbol_exists(res_search "resolv.h" HAVE_RES_SEARCH)

# Check how flush should be called.
include(PHPCheckFlushIo)

# Check if OS can spawn processes with inherited handles.
include(PHPCheckProcOpenSupport)

# Check whether the strptime() declaration fails.
include(PHPCheckStrptime)

# Check for fnmatch() implementation.
include(PHPCheckFnMatch)

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

re2c_target(
  NAME VarUnserializer
  INPUT "${CMAKE_CURRENT_SOURCE_DIR}/var_unserializer.re"
  OUTPUT "${CMAKE_CURRENT_SOURCE_DIR}/var_unserializer.c"
  OPTIONS "--no-generation-date -b"
)

re2c_target(
  NAME UrlScannerEx
  INPUT "${CMAKE_CURRENT_SOURCE_DIR}/url_scanner_ex.re"
  OUTPUT "${CMAKE_CURRENT_SOURCE_DIR}/url_scanner_ex.c"
  OPTIONS "--no-generation-date -b"
)

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

target_include_directories(
  ext_standard
  PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}"
  PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/libavifinfo"
)

option(EXTERNAL_LIBCRYPT "Whether to use external libcrypt library" OFF)

if(NOT EXTERNAL_LIBCRYPT)
  target_sources(ext_standard PRIVATE crypt_freesec.c crypt_blowfish.c crypt_sha512.c crypt_sha256.c php_crypt_r.c)
  set(PHP_USE_PHP_CRYPT_R 1 CACHE INTERNAL "Whether PHP has to use its own crypt_r")
else()
  include(PHPCheckExternalLibcrypt)
  set(PHP_USE_PHP_CRYPT_R 0 CACHE INTERNAL "Whether PHP has to use its own crypt_r")
endif()

option(PASSWORD_ARGON2 "Whether to include the Argon2 support in password_*" OFF)

if(PASSWORD_ARGON2)
  php_find_package(NAME libargon2 VERSION 20171227)

  if(libargon2_FOUND)
    set(HAVE_ARGON2LIB 1 CACHE INTERNAL "Whether to use the libargon2")
    target_link_libraries(ext_standard PUBLIC ${libargon2_LIBRARIES})
    target_compile_options(ext_opcache PRIVATE ${libargon2_CFLAGS})
  endif()
endif()

target_compile_definitions(ext_standard PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

target_link_libraries(ext_standard PUBLIC main)

file(GLOB EXT_STANDARD_HEADER_FILES "${CMAKE_CURRENT_SOURCE_DIR}/*.h")
set_target_properties(ext_standard PROPERTIES PUBLIC_HEADER "${EXT_STANDARD_HEADER_FILES}")

add_dependencies(ext_standard Zend)
