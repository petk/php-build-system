project(
  PhpExtensionRandom
  LANGUAGES C
)

include(CheckIncludeFiles)
include(CheckSymbolExists)
include(FeatureSummary)

add_feature_info(
  "ext/random"
  ON
  "Random number generators and functions related to randomness"
)

add_library(php_random STATIC)

target_sources(
  php_random
  PRIVATE
    csprng.c
    engine_mt19937.c
    engine_pcgoneseq128xslrr64.c
    engine_secure.c
    engine_user.c
    engine_xoshiro256starstar.c
    gammasection.c
    random.c
    random.stub.php
    randomizer.c
    zend_utils.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        php_random_csprng.h
        php_random_uint128.h
        php_random.h
)

target_compile_definitions(php_random PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

check_symbol_exists(arc4random_buf "stdlib.h" HAVE_ARC4RANDOM_BUF)
check_symbol_exists(getrandom "sys/random.h" HAVE_GETRANDOM)

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

# TODO: Fix this better with object libraries in the future.
target_link_libraries(php_random PRIVATE Zend::Zend)

configure_file(config.cmake.h.in config.h @ONLY)
