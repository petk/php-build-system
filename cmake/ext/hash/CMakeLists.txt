#[=============================================================================[
# The hash extension

This extension provides HASH message digest framework and is always enabled in
PHP.

## Configuration options

### PHP_EXT_HASH_MHASH

:orange_circle: *Deprecated as of PHP 8.1.*

* Default: `OFF`
* Values: `ON|OFF`

Enables the mhash emulation support.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

project(
  PHP_EXT_HASH
  LANGUAGES C
)

if(PROJECT_IS_TOP_LEVEL)
  message(
    FATAL_ERROR
    "The PHP hash extension is intended to be built only within the "
    "top-level PHP source tree (php-src)."
  )
endif()

include(FeatureSummary)
include(PHP/CheckCompilerFlag)

add_feature_info(
  "ext/hash"
  TRUE
  "HASH message digest framework"
)

option(
  PHP_EXT_HASH_MHASH
  "Enable the mhash emulation support (deprecated as of PHP 8.1)"
)
mark_as_advanced(PHP_EXT_HASH_MHASH)
add_feature_info(
  "ext/hash mhash"
  PHP_EXT_HASH_MHASH
  "mhash emulation"
)

message(CHECK_START "Checking whether to enable mhash")
if(PHP_EXT_HASH_MHASH)
  message(CHECK_PASS "yes")
  message(
    DEPRECATION
    "The 'PHP_EXT_HASH_MHASH' option to enable the mhash emulation support in "
    "the hash extension is deprecated as of PHP 8.1.0 and will be removed in "
    "future PHP versions."
  )
  set(PHP_MHASH_BC TRUE)
else()
  message(CHECK_FAIL "no")
endif()

include(PHP/Extension)
php_extension(hash)

add_library(php_ext_hash OBJECT)

target_sources(
  php_ext_hash
  PRIVATE
    hash_adler32.c
    hash_crc32.c
    hash_fnv.c
    hash_gost.c
    hash_haval.c
    hash_joaat.c
    hash_md.c
    hash_murmur.c
    hash_ripemd.c
    hash_sha.c
    hash_sha3.c
    hash_snefru.c
    hash_tiger.c
    hash_whirlpool.c
    hash_xxhash.c
    hash.c
    hash.stub.php
    murmur/PMurHash.c
    murmur/PMurHash128.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        php_hash_adler32.h
        php_hash_crc32.h
        php_hash_fnv.h
        php_hash_gost.h
        php_hash_haval.h
        php_hash_joaat.h
        php_hash_md.h
        php_hash_murmur.h
        php_hash_ripemd.h
        php_hash_sha.h
        php_hash_sha3.h
        php_hash_snefru.h
        php_hash_tiger.h
        php_hash_whirlpool.h
        php_hash_xxhash.h
        php_hash.h
        xxhash/xxhash.h
)

target_include_directories(php_ext_hash PRIVATE xxhash)

target_compile_definitions(
  php_ext_hash
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE
)

if(CMAKE_C_BYTE_ORDER STREQUAL "BIG_ENDIAN")
  set(HAVE_SLOW_HASH3 TRUE)
  message(WARNING "Using slow SHA3 implementation on big-endian")
else()
  block()
    if(CMAKE_SIZEOF_VOID_P EQUAL 4)
      set(sha3_dir "sha3/generic32lc")
      target_sources(
        php_ext_hash
        PRIVATE ${sha3_dir}/KeccakP-1600-inplace32BI.c
      )

      # Add -Wno-implicit-fallthrough flag due to warnings on 32-bit builds.
      php_check_compiler_flag(
        C
        -Wno-implicit-fallthrough
        PHP_HAS_WNO_IMPLICIT_FALLTHROUGH_C
      )
      if(PHP_HAS_WNO_IMPLICIT_FALLTHROUGH_C)
        set_property(
          SOURCE ${sha3_dir}/KeccakP-1600-inplace32BI.c
          APPEND
          PROPERTY
            COMPILE_OPTIONS -Wno-implicit-fallthrough
        )
      endif()
    else()
      set(sha3_dir "sha3/generic64lc")
      target_sources(php_ext_hash PRIVATE ${sha3_dir}/KeccakP-1600-opt64.c)
    endif()

    target_sources(
      php_ext_hash
      PRIVATE
        ${sha3_dir}/KeccakHash.c
        ${sha3_dir}/KeccakSponge.c
    )

    target_include_directories(
      php_ext_hash
      PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/${sha3_dir}
    )
  endblock()

  target_compile_definitions(
    php_ext_hash
    PRIVATE
      KeccakP200_excluded
      KeccakP400_excluded
      KeccakP800_excluded
  )
endif()

configure_file(cmake/config.h.in config.h)
