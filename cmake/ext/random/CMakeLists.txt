include(CheckSourceCompiles)
include(CheckSymbolExists)

add_library(php_random STATIC
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
)

target_compile_definitions(php_random PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

# Check for arc4random on BSD systems.
check_symbol_exists(arc4random_buf "stdlib.h" HAVE_DECL_ARC4RANDOM_BUF)

# Check for CCRandomGenerateBytes. Header was absent in previous macOS releases.
check_source_compiles(C "
  #include <sys/types.h>
  #include <Availability.h>
  #include <CommonCrypto/CommonCryptoError.h>
  #include <CommonCrypto/CommonRandom.h>

  int main(void) {
    return 0;
  }
" HAVE_COMMONCRYPTO_COMMONRANDOM_H)

target_sources(
  php_random
  PUBLIC FILE_SET HEADERS
    BASE_DIRS "${PROJECT_SOURCE_DIR}"
    FILES
      php_random_uint128.h
      php_random.h
)

install(
  TARGETS php_random
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET HEADERS
)
