option(mhash "Whether mhash support should be enabled" OFF)

if(mhash)
  set(PHP_MHASH_BC 1 PARENT_SCOPE)
endif()

php_extension(NAME "hash")

add_library(ext_hash
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
  PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
  PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/murmur"
  PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/xxhash"
  PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/"
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

  target_sources(ext_hash PRIVATE "${SHA3_DIR}/KeccakHash.c" "${SHA3_DIR}/KeccakSponge.c")

  target_include_directories(ext_hash PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/${SHA3_DIR}")

  # Add -Wno-implicit-fallthrough flag as it happens on 32-bit builds.
  target_compile_options(ext_hash PRIVATE
    -Wno-implicit-fallthrough
    -DKeccakP200_excluded
    -DKeccakP400_excluded
    -DKeccakP800_excluded
    -DZEND_ENABLE_STATIC_TSRMLS_CACHE=1
  )
else()
  set(HAVE_SLOW_HASH3 1 PARENT_SCOPE)
  message(WARNING "Using SHA3 slow implementation on bigendian")
endif()
