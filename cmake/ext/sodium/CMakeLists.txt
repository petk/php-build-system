include(CheckCompilerFlag)
include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_SODIUM "Enable the sodium extension" OFF)

add_feature_info("ext/sodium" EXT_SODIUM
  "Support for encryption, decryption, signatures and password hashing."
)

cmake_dependent_option(
  EXT_SODIUM_SHARED
  "Build the sodium extension as a shared library"
  OFF
  "EXT_SODIUM;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_SODIUM)
  return()
endif()

if(EXT_SODIUM_SHARED)
  add_library(php_sodium SHARED)
else()
  add_library(php_sodium)
endif()

target_sources(
  php_sodium
  PRIVATE
    libsodium.c
    sodium_pwhash.c
  PUBLIC
    FILE_SET HEADERS
      BASE_DIRS "${PHP_SOURCE_DIR}"
      FILES
        php_libsodium.h
)

find_package(Sodium 1.0.8)
set_package_properties(
  Sodium
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the sodium extension."
)

target_link_libraries(php_sodium PRIVATE Sodium::Sodium)

# Add -Wno-type-limits and -Wno-logical-op as this may arise on 32bits platforms.
check_compiler_flag(C -Wno-type-limits HAVE_WNO_TYPE_LIMITS_C)
if(HAVE_WNO_TYPE_LIMITS_C)
  target_compile_options(php_sodium PRIVATE -Wno-type-limits)
endif()

check_compiler_flag(C -Wno-logical-op HAVE_WNO_LOGICAL_OP_C)
if(HAVE_WNO_LOGICAL_OP_C)
  target_compile_options(php_sodium PRIVATE -Wno-logical-op)
endif()

set(HAVE_LIBSODIUMLIB 1 CACHE INTERNAL "Whether the libsodium is available")

install(
  TARGETS php_sodium
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET HEADERS
)
