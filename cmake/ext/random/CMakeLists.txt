include(CheckCSourceCompiles)
include(CheckIncludeFile)
include(CheckSymbolExists)

# Check for arc4random on BSD systems.
check_symbol_exists(arc4random_buf "stdlib.h" HAVE_DECL_ARC4RANDOM_BUF)

# Check for CCRandomGenerateBytes, header was absent in previous macOS releases.
check_include_file(CommonCrypto/CommonRandom.h HAVE_COMMONCRYPTO_COMMONRANDOM_H)

if(HAVE_COMMONCRYPTO_COMMONRANDOM_H)
  set(CMAKE_REQUIRED_INCLUDES ${CMAKE_REQUIRED_INCLUDES} CommonCrypto)
  check_c_source_compiles("
    #include <sys/types.h>
    #include <Availability.h>
    #include <CommonCrypto/CommonCryptoError.h>
    int main() {
      return 0;
    }
  " COMMONCRYPTO_HEADERS_WORK)
  if(COMMONCRYPTO_HEADERS_WORK)
    set(HAVE_COMMONCRYPTO_COMMONRANDOM_H 1 CACHE STRING "Define to 1 if you have the <CommonCrypto/CommonRandom.h> header file.")
  else()
    unset(HAVE_COMMONCRYPTO_COMMONRANDOM_H CACHE)
  endif()
endif()

php_extension(NAME "random")

add_library(ext_random
  random.c
  csprng.c
  engine_combinedlcg.c
  engine_mt19937.c
  engine_pcgoneseq128xslrr64.c
  engine_xoshiro256starstar.c
  engine_secure.c
  engine_user.c
  gammasection.c
  randomizer.c
)

target_include_directories(
  ext_random
  PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}"
  PUBLIC "${CMAKE_SOURCE_DIR}"
)

target_compile_definitions(ext_random PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

set_target_properties(ext_random PROPERTIES PUBLIC_HEADER "php_random.h")
