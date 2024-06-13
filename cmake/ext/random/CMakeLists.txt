include(CheckIncludeFiles)
include(CheckSymbolExists)

add_library(php_random STATIC)

target_sources(
  php_random
  PRIVATE
    csprng.c
    engine_combinedlcg.c
    engine_mt19937.c
    engine_pcgoneseq128xslrr64.c
    engine_secure.c
    engine_user.c
    engine_xoshiro256starstar.c
    gammasection.c
    random.c
    randomizer.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        php_random.h
)

target_compile_definitions(php_random PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

check_symbol_exists(arc4random_buf "stdlib.h" HAVE_DECL_ARC4RANDOM_BUF)

# Check for CCRandomGenerateBytes. Header was absent in previous macOS releases.
block()
  set(headers
    sys/types.h
    Availability.h
    CommonCrypto/CommonCryptoError.h
    CommonCrypto/CommonRandom.h
  )

  check_include_files("${headers}" HAVE_COMMONCRYPTO_COMMONRANDOM_H)
endblock()
