#[=============================================================================[
# The random extension

Configure the `random` extension.

This extension provides support for random number generators and functions
related to randomness. It is always enabled.
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.1)

project(
  PhpExtensionRandom
  LANGUAGES C
)

include(CheckIncludeFiles)
include(CheckSymbolExists)
include(FeatureSummary)

add_feature_info(
  "ext/random"
  TRUE
  "randomness-related generators and functions"
)

add_library(php_ext_random OBJECT)

target_sources(
  php_ext_random
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

target_compile_definitions(php_ext_random PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

check_symbol_exists(arc4random_buf stdlib.h HAVE_ARC4RANDOM_BUF)
check_symbol_exists(getrandom sys/random.h HAVE_GETRANDOM)

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

configure_file(cmake/config.h.in config.h)
