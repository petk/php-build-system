option(EXT_HASH_MHASH "Whether mhash support should be included" OFF)

if(EXT_HASH_MHASH)
  set(PHP_MHASH_BC 1 CACHE INTERNAL "Whether mhash support should be included")
endif()

php_extension(NAME "hash" STATIC)

add_library(ext_hash STATIC
  hash.c
  hash_md.c
  hash_sha.c
  hash_ripemd.c
  hash_haval.c
  hash_tiger.c
  hash_gost.c
  hash_snefru.c
  hash_whirlpool.c
  hash_adler32.c
  hash_crc32.c
  hash_fnv.c
  hash_joaat.c
  hash_sha3.c
  murmur/PMurHash.c
  murmur/PMurHash128.c
  hash_murmur.c
  hash_xxhash.c
)

target_include_directories(
  ext_hash
  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/murmur
          ${CMAKE_CURRENT_SOURCE_DIR}/xxhash
)

if(CMAKE_C_BYTE_ORDER STREQUAL "LITTLE_ENDIAN")
  if(CMAKE_SIZEOF_VOID_P EQUAL 4)
    message(STATUS "32-bit platform")

    set(SHA3_DIR "sha3/generic32lc")
    target_sources(ext_hash PRIVATE "${SHA3_DIR}/KeccakP-1600-inplace32BI.c")
  else()
    message(STATUS "64-bit platform")

    set(SHA3_DIR "sha3/generic64lc")
    target_sources(ext_hash PRIVATE "${SHA3_DIR}/KeccakP-1600-opt64.c")
  endif()

  target_sources(ext_hash PRIVATE ${SHA3_DIR}/KeccakHash.c ${SHA3_DIR}/KeccakSponge.c)

  target_include_directories(ext_hash PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/${SHA3_DIR})

  # Add -Wno-implicit-fallthrough flag as it happens on 32-bit builds.
  target_compile_options(ext_hash
    PRIVATE -Wno-implicit-fallthrough
  )

  target_compile_definitions(ext_hash
    PRIVATE KeccakP200_excluded
            KeccakP400_excluded
            KeccakP800_excluded
            ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
  )
else()
  set(HAVE_SLOW_HASH3 1 CACHE INTERNAL "Define if hash3 algo is available")
  message(WARNING "Using SHA3 slow implementation on bigendian")
endif()

target_sources(
  ext_hash
  PUBLIC FILE_SET ext_hash_headers
  TYPE HEADERS
  FILES
    php_hash.h
    php_hash_md.h
    php_hash_sha.h
    php_hash_ripemd.h
    php_hash_haval.h
    php_hash_tiger.h
    php_hash_gost.h
    php_hash_snefru.h
    php_hash_whirlpool.h
    php_hash_adler32.h
    php_hash_crc32.h
    php_hash_fnv.h
    php_hash_joaat.h
    php_hash_sha3.h
    php_hash_murmur.h
    php_hash_xxhash.h
)

install(
  TARGETS ext_hash
  FILE_SET ext_hash_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/hash
)
