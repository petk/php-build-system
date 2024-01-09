include(CheckCompilerFlag)
include(FeatureSummary)

option(EXT_HASH_MHASH "Enable the mhash support" OFF)

add_feature_info("ext/hash with mhash" EXT_HASH_MHASH
  "The mhash emulation in the hash extension. Deprecated as of PHP 8.1.0."
)

if(EXT_HASH_MHASH)
  message(
    DEPRECATION
    "Support for mhash in the hash extension is deprecated as of PHP 8.1.0"
  )

  set(PHP_MHASH_BC 1 CACHE INTERNAL "Whether the mhash support is included")
endif()

add_library(php_hash STATIC
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
  murmur/PMurHash.c
  murmur/PMurHash128.c
)

target_include_directories(
  php_hash
  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/murmur
          ${CMAKE_CURRENT_SOURCE_DIR}/xxhash
)

if(WORDS_BIGENDIAN)
  set(HAVE_SLOW_HASH3 1 CACHE INTERNAL "Define if hash3 algo is available")
  message(WARNING "Using SHA3 slow implementation on bigendian")
else()
  block()
    if(CMAKE_SIZEOF_VOID_P EQUAL 4)
      set(sha3_dir "sha3/generic32lc")
      target_sources(php_hash PRIVATE "${sha3_dir}/KeccakP-1600-inplace32BI.c")
    else()
      set(sha3_dir "sha3/generic64lc")
      target_sources(php_hash PRIVATE "${sha3_dir}/KeccakP-1600-opt64.c")
    endif()

    target_sources(
      php_hash
      PRIVATE
        ${sha3_dir}/KeccakHash.c
        ${sha3_dir}/KeccakSponge.c
    )

    target_include_directories(
      php_hash
      PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/${sha3_dir}
    )
  endblock()

  # Add -Wno-implicit-fallthrough flag as it happens on 32-bit builds.
  check_compiler_flag(C -Wno-implicit-fallthrough HAVE_WNO_IMPLICIT_FALLTHROUGH_C)
  if(HAVE_WNO_IMPLICIT_FALLTHROUGH_C)
    target_compile_options(php_hash PRIVATE -Wno-implicit-fallthrough)
  endif()

  target_compile_definitions(php_hash
    PRIVATE KeccakP200_excluded
            KeccakP400_excluded
            KeccakP800_excluded
            ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
  )
endif()

target_sources(
  php_hash
  PUBLIC FILE_SET HEADERS
    BASE_DIRS "${PROJECT_SOURCE_DIR}"
    FILES
      php_hash_adler32.h
      php_hash_crc32.h
      $<$<NOT:$<PLATFORM_ID:Windows>>:php_hash_fnv.h>
      php_hash_gost.h
      php_hash_haval.h
      $<$<NOT:$<PLATFORM_ID:Windows>>:php_hash_joaat.h>
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
)

install(
  TARGETS php_hash
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET HEADERS
)
