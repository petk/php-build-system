#[=============================================================================[
# The hash extension

Configure the `hash` extension.

This extension provides HASH message digest framework and is always enabled in
PHP.

## EXT_HASH_MHASH

:orange_circle: *Deprecated as of PHP 8.1.*

* Default: `OFF`
* Values: `ON|OFF`

Enable the mhash support.
#]=============================================================================]

project(
  PhpExtensionHash
  LANGUAGES C
)

include(FeatureSummary)
include(PHP/CheckCompilerFlag)

add_feature_info(
  "ext/hash"
  TRUE
  "HASH message digest framework"
)

option(EXT_HASH_MHASH "Enable the mhash support (deprecated as of PHP 8.1)")

add_feature_info(
  "ext/hash with mhash"
  EXT_HASH_MHASH
  "mhash emulation"
)

if(EXT_HASH_MHASH)
  message(
    DEPRECATION
    "Support for mhash in the hash extension is deprecated as of PHP 8.1.0"
  )

  set(PHP_MHASH_BC TRUE)
endif()

add_library(php_hash OBJECT)

target_sources(
  php_hash
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

target_include_directories(php_hash PRIVATE xxhash)

if(WORDS_BIGENDIAN)
  set(HAVE_SLOW_HASH3 TRUE)
  message(WARNING "Using slow SHA3 implementation on bigendian")
else()
  block()
    if(CMAKE_SIZEOF_VOID_P EQUAL 4)
      set(sha3Dir "sha3/generic32lc")
      target_sources(php_hash PRIVATE ${sha3Dir}/KeccakP-1600-inplace32BI.c)

      # Add -Wno-implicit-fallthrough flag due to warnings on 32-bit builds.
      php_check_compiler_flag(
        C
        -Wno-implicit-fallthrough
        _HAVE_WNO_IMPLICIT_FALLTHROUGH_C
      )
      if(_HAVE_WNO_IMPLICIT_FALLTHROUGH_C)
        set_property(
          SOURCE ${sha3Dir}/KeccakP-1600-inplace32BI.c
          APPEND
          PROPERTY
            COMPILE_OPTIONS -Wno-implicit-fallthrough
        )
      endif()
    else()
      set(sha3Dir "sha3/generic64lc")
      target_sources(php_hash PRIVATE ${sha3Dir}/KeccakP-1600-opt64.c)
    endif()

    target_sources(
      php_hash
      PRIVATE
        ${sha3Dir}/KeccakHash.c
        ${sha3Dir}/KeccakSponge.c
    )

    target_include_directories(
      php_hash
      PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/${sha3Dir}
    )
  endblock()

  target_compile_definitions(
    php_hash
    PRIVATE
      KeccakP200_excluded
      KeccakP400_excluded
      KeccakP800_excluded
      ZEND_ENABLE_STATIC_TSRMLS_CACHE
  )
endif()

configure_file(config.cmake.h.in config.h)
