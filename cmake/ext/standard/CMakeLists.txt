#[=============================================================================[
# The standard extension

Configure the `standard` extension.

This is an always enabled core PHP extension that provides common functionality
to PHP extensions and SAPIs.

## PHP_EXT_STANDARD_ARGON2

* Default: `OFF`
* Values: `ON|OFF`

Include the Argon2 support in `password_*()` functions.

## PHP_EXT_STANDARD_CRYPT_EXTERNAL

* Default: `OFF`
* Values: `ON|OFF`

Use external crypt library, such as libcrypt or libxcrypt, instead of the
bundled PHP crypt.
#]=============================================================================]

project(
  PhpExtensionStandard
  LANGUAGES C
)

include(CheckIncludeFiles)
include(CheckSymbolExists)
include(FeatureSummary)
include(PHP/SearchLibraries)

add_feature_info(
  "ext/standard"
  TRUE
  "PHP core extension"
)

option(PHP_EXT_STANDARD_ARGON2 "Include the Argon2 support in password_*")
add_feature_info(
  "ext/standard Argon2"
  PHP_EXT_STANDARD_ARGON2
  "Argon2 support in password-hashing PHP functions"
)

option(
  PHP_EXT_STANDARD_CRYPT_EXTERNAL
  "Use external libcrypt/libxcrypt library instead of the bundled PHP crypt"
)
mark_as_advanced(PHP_EXT_STANDARD_CRYPT_EXTERNAL)
add_feature_info(
  "ext/standard crypt external"
  PHP_EXT_STANDARD_CRYPT_EXTERNAL
  "system crypt library instead of bundled"
)

################################################################################
# Add library.
################################################################################

add_library(php_ext_standard OBJECT)

target_sources(
  php_ext_standard
  PRIVATE
    array.c
    assert.c
    base64.c
    basic_functions.stub.php
    browscap.c
    crc32.c
    credits.c
    crypt.c
    css.c
    datetime.c
    dir.stub.php
    dl.c
    dl.stub.php
    $<$<PLATFORM_ID:Windows>:dns_win32.c>
    dns.c
    exec.c
    file.c
    file.stub.php
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
    user_filters.stub.php
    uuencode.c
    var_unserializer.c
    var.c
    versioning.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        base64.h
        basic_functions_arginfo.h
        basic_functions.h
        crc32_x86.h
        crc32.h
        credits_ext.h
        credits_sapi.h
        credits.h
        crypt_blowfish.h
        crypt_freesec.h
        css.h
        datetime.h
        dir_arginfo.h
        dl_arginfo.h
        dl.h
        exec.h
        file_arginfo.h
        file.h
        flock_compat.h
        fsock.h
        head.h
        html_tables.h
        html.h
        info.h
        md5.h
        pack.h
        pageinfo.h
        php_array.h
        php_assert.h
        php_browscap.h
        php_crypt_r.h
        php_crypt.h
        php_dir.h
        php_dns.h
        php_ext_syslog.h
        php_filestat.h
        php_fopen_wrappers.h
        php_http.h
        php_image.h
        php_incomplete_class.h
        php_lcg.h
        php_mail.h
        php_math.h
        php_mt_rand.h
        php_net.h
        php_password.h
        php_rand.h
        php_random.h
        php_smart_string_public.h
        php_smart_string.h
        php_standard.h
        php_string.h
        php_uuencode.h
        php_var.h
        php_versioning.h
        proc_open.h
        quot_print.h
        scanf.h
        sha1.h
        streamsfuncs.h
        url_scanner_ex.h
        url.h
        user_filters_arginfo.h
        $<$<PLATFORM_ID:Windows>:${CMAKE_CURRENT_SOURCE_DIR}/winver.h>
)

# Check for ARM64 processor on Windows.
if(NOT CMAKE_SYSTEM_PROCESSOR STREQUAL "ARM64")
  target_sources(php_ext_standard PRIVATE crc32_x86.c)
endif()

target_include_directories(
  php_ext_standard
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/libavifinfo
)

target_compile_definitions(php_ext_standard PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

# The standard extension depends on the generated Zend language parser.
add_dependencies(php_ext_standard Zend::Zend)

target_link_libraries(
  php_ext_standard
  PRIVATE
    $<$<PLATFORM_ID:Windows>:iphlpapi>
)

################################################################################
# Generate lexer files.
################################################################################

include(cmake/GenerateGrammar.cmake)

################################################################################
# Add Argon2.
################################################################################

if(PHP_EXT_STANDARD_ARGON2)
  find_package(Argon2 20161029)
  set_package_properties(
    Argon2
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to include Argon2 support in password_*."
  )

  target_link_libraries(php_ext_standard PRIVATE Argon2::Argon2)

  set(HAVE_ARGON2LIB TRUE)
endif()

################################################################################
# External libcrypt.
################################################################################

if(NOT PHP_EXT_STANDARD_CRYPT_EXTERNAL)
  target_sources(
    php_ext_standard
    PRIVATE
      crypt_blowfish.c
      crypt_freesec.c
      crypt_sha256.c
      crypt_sha512.c
      php_crypt_r.c
  )

  set(PHP_USE_PHP_CRYPT_R TRUE)
else()
  find_package(Crypt)
  set_package_properties(
    Crypt
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to use external crypt library."
  )

  if(TARGET Crypt::Crypt)
    include(cmake/CheckCrypt.cmake)
  endif()

  target_link_libraries(php_ext_standard PRIVATE Crypt::Crypt)
endif()

################################################################################
# Configuration checks.
################################################################################

include(cmake/CheckArmCrc32.cmake)
include(cmake/CheckStrptime.cmake)

# Check if there is a support means of creating a new process and defining which
# handles it receives.
message(CHECK_START "Checking if OS can spawn processes with inherited handles")
check_symbol_exists(fork unistd.h PHP_HAVE_FORK)
set(HAVE_FORK ${PHP_HAVE_FORK})
if(NOT PHP_HAVE_FORK)
  check_symbol_exists(CreateProcess windows.h PHP_HAVE_CREATEPROCESS)
endif()
if(PHP_HAVE_FORK OR PHP_HAVE_CREATEPROCESS)
  set(PHP_CAN_SUPPORT_PROC_OPEN TRUE)

  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

# Check net/if.h for PHP net_get_interfaces().
if(PHP_HAVE_SYS_SOCKET_H)
  # Darwin and BSD-like systems also need sys/socket.h to include net/if.h.
  check_include_files("sys/socket.h;net/if.h" PHP_HAVE_NET_IF_H)
else()
  check_include_files(net/if.h PHP_HAVE_NET_IF_H)
endif()
set(HAVE_NET_IF_H ${PHP_HAVE_NET_IF_H})

# Detect library functions needed by PHP dns_xxx functions.
# ext/standard/php_dns.h will collect these in a single define
# HAVE_FULL_DNS_FUNCS.
php_search_libraries(
  SYMBOL dn_expand
  HEADERS
    netinet/in.h # BSD-based systems (FreeBSD<=13) need it for resolv.h to work.
    resolv.h
  LIBRARIES
    resolv # Solaris/illumos
  RESULT_VARIABLE PHP_HAVE_DN_EXPAND
  TARGET php_ext_standard PRIVATE
)
set(HAVE_DN_EXPAND ${PHP_HAVE_DN_EXPAND})

php_search_libraries(
  SYMBOL dn_skipname
  HEADERS
    netinet/in.h # BSD-based systems (FreeBSD<=13) need it for resolv.h to work.
    resolv.h
  LIBRARIES
    resolv # Solaris/illumos
  RESULT_VARIABLE PHP_HAVE_DN_SKIPNAME
  TARGET php_ext_standard PRIVATE
)
set(HAVE_DN_SKIPNAME ${PHP_HAVE_DN_SKIPNAME})

# On macos the dn_skipname is defined as a macro but also requires resolv
# library to work. For consistency, this is additional check whether the resolv
# library needs to be linked on macOS.
php_search_libraries(
  SYMBOL res_9_dn_skipname
  HEADERS
    resolv.h
  LIBRARIES
    resolv # macOS
  RESULT_VARIABLE PHP_HAVE_RES_9_DN_SKIPNAME
  TARGET php_ext_standard PRIVATE
)

php_search_libraries(
  SYMBOL dns_search
  HEADERS
    netinet/in.h # BSD-based systems (FreeBSD<=13) need it for resolv.h to work.
    resolv.h
    dns.h        # macOS
  LIBRARIES
    resolv # Solaris/illumos, macOS
  RESULT_VARIABLE PHP_HAVE_DNS_SEARCH
  TARGET php_ext_standard PRIVATE
)
set(HAVE_DNS_SEARCH ${PHP_HAVE_DNS_SEARCH})

php_search_libraries(
  SYMBOL res_ndestroy
  HEADERS
    netinet/in.h # BSD-based systems (FreeBSD<=13) need it for resolv.h to work.
    resolv.h
  LIBRARIES
    resolv # Solaris/illumos
  RESULT_VARIABLE PHP_HAVE_RES_NDESTROY
  TARGET php_ext_standard PRIVATE
)
set(HAVE_RES_NDESTROY ${PHP_HAVE_RES_NDESTROY})

php_search_libraries(
  SYMBOL res_nsearch
  HEADERS
    netinet/in.h # BSD-based systems (FreeBSD<=13) need it for resolv.h to work.
    resolv.h
  LIBRARIES
    resolv # Solaris/illumos
  RESULT_VARIABLE PHP_HAVE_RES_NSEARCH
  TARGET php_ext_standard PRIVATE
)
set(HAVE_RES_NSEARCH ${PHP_HAVE_RES_NSEARCH})

# res_search() is deprecated and should be replaced with res_nsearch().
php_search_libraries(
  SYMBOL res_search
  HEADERS
    netinet/in.h # BSD-based systems (FreeBSD<=13) need it for resolv.h to work.
    resolv.h
  LIBRARIES
    resolv # Solaris/illumos
  RESULT_VARIABLE PHP_HAVE_RES_SEARCH
  TARGET php_ext_standard PRIVATE
)
set(HAVE_RES_SEARCH ${PHP_HAVE_RES_SEARCH})

check_symbol_exists(
  posix_spawn_file_actions_addchdir_np
  spawn.h
  PHP_HAVE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR_NP
)
set(
  HAVE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR_NP
  ${PHP_HAVE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR_NP}
)

################################################################################
# Regenerate credits_*.h files.
################################################################################

block()
  file(GLOB credits ${PHP_SOURCE_DIR}/*/*/CREDITS)
  # Case-sensitive filtering, GLOB on macOS/Windows/Cygwin is case-insensitive.
  list(FILTER credits INCLUDE REGEX ".*CREDITS$")

  # The CODEGEN keyword adds the custom command to a global 'codegen' target.
  set(codegen "")
  if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.31)
    set(codegen CODEGEN)
  endif()

  add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/php_credits.timestamp
    DEPENDS ${credits}
    COMMAND
      ${CMAKE_COMMAND}
        -E touch ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/php_credits.timestamp
    COMMAND
      ${CMAKE_COMMAND} -P ${PHP_SOURCE_DIR}/cmake/scripts/GenerateCredits.cmake
    COMMENT "Regenerating ext/standard/credits_*.h"
    VERBATIM
    ${codegen}
  )

  add_custom_target(
    php_ext_standard_credits
    DEPENDS
      ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/php_credits.timestamp
  )

  add_dependencies(php_ext_standard php_ext_standard_credits)
endblock()

################################################################################
# Create helper target for Windows.
################################################################################

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  add_executable(php_ext_standard_bad_cmd tests/helpers/bad_cmd.c)
  target_compile_options(php_ext_standard_bad_cmd PRIVATE /nologo)
  set_target_properties(
    php_ext_standard_bad_cmd
    PROPERTIES
      RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/tests/helpers
      OUTPUT_NAME bad_cmd
  )
endif()

################################################################################
# Add chroot() based on the SAPI type. It should be enabled only for the
# CLI-based SAPIs. This enables building all SAPIs in a single build invocation.
# Here, a build-time solution is integrated, although this would be better
# resolved as mentioned in the issue report.
# See: https://github.com/php/php-src/issues/11984
################################################################################

check_symbol_exists(chroot unistd.h PHP_HAVE_CHROOT)
set(HAVE_CHROOT ${PHP_HAVE_CHROOT})

add_library(php_ext_standard_functions OBJECT)
add_library(php_ext_standard_functions_cli OBJECT)

target_sources(php_ext_standard_functions PRIVATE basic_functions.c dir.c)
target_sources(php_ext_standard_functions_cli PRIVATE basic_functions.c dir.c)

set_target_properties(
  php_ext_standard_functions
  php_ext_standard_functions_cli
  PROPERTIES
    INCLUDE_DIRECTORIES $<TARGET_PROPERTY:php_ext_standard,INCLUDE_DIRECTORIES>
    COMPILE_DEFINITIONS $<TARGET_PROPERTY:php_ext_standard,COMPILE_DEFINITIONS>
)

target_compile_definitions(
  php_ext_standard_functions_cli
  PRIVATE
    $<$<NOT:$<PLATFORM_ID:Windows>>:ENABLE_CHROOT_FUNC>
)

# ext/standard functions objects based on the SAPI type.
target_sources(
  php_ext_standard
  INTERFACE
    $<IF:$<BOOL:$<TARGET_PROPERTY:PHP_CLI>>,$<TARGET_OBJECTS:php_ext_standard_functions_cli>,$<TARGET_OBJECTS:php_ext_standard_functions>>
)

add_dependencies(php_ext_standard_functions php_ext_standard)
add_dependencies(php_ext_standard_functions_cli php_ext_standard)

################################################################################
# ext/standard depends on ext/zlib for SWC images and transitively depends on
# the zlib library.
# TODO: https://github.com/php/php-src/pull/4681
################################################################################

if(PHP_EXT_ZLIB)
  add_dependencies(php_ext_standard php_ext_zlib)
endif()

################################################################################
# Configuration header
################################################################################

configure_file(cmake/config.h.in config.h)
