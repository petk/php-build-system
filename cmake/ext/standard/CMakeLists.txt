include(CheckCSourceCompiles)
include(CheckSymbolExists)
include(CheckFlushIo)

check_flush_io()

check_symbol_exists(res_search "resolv.h" HAVE_RES_SEARCH)
check_symbol_exists(posix_spawn_file_actions_addchdir_np "spawn.h" HAVE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR_NP)

php_extension(NAME "standard")

RE2C_TARGET(
  NAME VarUnserializer
  INPUT ${CMAKE_CURRENT_BINARY_DIR}/var_unserializer.re
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/var_unserializer.c
  OPTIONS "--no-generation-date -b"
)

RE2C_TARGET(
  NAME UrlScannerEx
  INPUT ${CMAKE_CURRENT_BINARY_DIR}/url_scanner_ex.re
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/url_scanner_ex.c
  OPTIONS "--no-generation-date -b"
)

message(STATUS "Checking for fork/CreateProcess")
check_symbol_exists(fork "unistd.h" HAVE_FORK)
check_symbol_exists(CreateProcess "windows.h" HAVE_CREATEPROCESS)
message(STATUS "Checking if your OS can spawn processes with inherited handles")
if(HAVE_FORK OR HAVE_CREATEPROCESS)
  message(STATUS "yes")
  set(PHP_CAN_SUPPORT_PROC_OPEN 1 CACHE STRING "Define if your system has fork/vfork/CreateProcess")
else()
  message(STATUS "no")
endif()

message(STATUS "Checking for usable getifaddrs")
try_run(
  RUN_RESULT_VAR
  COMPILE_RESULT_VAR
  ${CMAKE_BINARY_DIR}
  "${CMAKE_SOURCE_DIR}/cmake/test_standard_getifaddrs.c"
)

if(RUN_RESULT_VAR EQUAL 0 AND COMPILE_RESULT_VAR)
  message(STATUS "getifaddrs is present and usable")
  set(HAVE_GETIFADDRS 1 CACHE STRING "Whether getifaddrs is present and usable")
else()
  message(STATUS "getifaddrs is not present")
endif()

add_library(ext_standard
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
  set(PHP_USE_PHP_CRYPT_R 1 CACHE STRING "Whether PHP has to use its own crypt_r")
else()
  set(PHP_USE_PHP_CRYPT_R 0 CACHE STRING "Whether PHP has to use its own crypt_r")
endif()

# Check for __attribute__ ((__aligned__)) support in the compiler.
message(STATUS "Checking whether the compiler supports aligned attribute")

if(CMAKE_CROSSCOMPILING)
  message(STATUS "Cross compiling: no")
else()
  check_c_source_compiles("
    int main() {
      unsigned char test[32] __attribute__ ((__aligned__ (__alignof__ (int))));
      return 0;
    }
  " HAS_ATTRIBUTE_ALIGNED)

  if(HAS_ATTRIBUTE_ALIGNED)
    message(STATUS "Compiler supports __attribute__ ((__aligned__))")
    set(HAVE_ATTRIBUTE_ALIGNED 1 CACHE STRING "Whether the compiler supports __attribute__ ((__aligned__))")
  else()
    message(STATUS "Compiler doesn't support aligned attribute")
  endif()
endif()

target_link_libraries(ext_standard PUBLIC main)
