include(CheckCCompilerFlag)
include(CMakeDependentOption)

option(EXT_SODIUM "Whether to enable the sodium extension" OFF)

cmake_dependent_option(
  EXT_SODIUM_SHARED
  "Whether to build the sodium extension as shared object"
  OFF
  "EXT_SODIUM;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_SODIUM)
  return()
endif()

if(EXT_SODIUM_SHARED)
  set(_type "SHARED")
endif()

add_library(php_sodium ${_type}
  libsodium.c
  sodium_pwhash.c
)

find_package(Sodium 1.0.2 REQUIRED)

target_link_libraries(php_sodium PRIVATE Sodium::Sodium)

# Add -Wno-type-limits and -Wno-logical-op as this may arise on 32bits platforms.
target_compile_options(php_sodium PRIVATE -Wno-type-limits)

check_c_compiler_flag(-Wno-logical-op HAVE_WNO_LOGICAL_OP)
if(HAVE_WNO_LOGICAL_OP)
  target_compile_options(php_sodium PRIVATE -Wno-logical-op)
  unset(HAVE_WNO_LOGICAL_OP)
endif()

set(HAVE_LIBSODIUMLIB 1 CACHE INTERNAL "Whether the libsodium is available")
