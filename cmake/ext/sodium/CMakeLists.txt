include(CheckCCompilerFlag)
include(CMakeDependentOption)

option(EXT_SODIUM "Whether to enable the sodium extension" OFF)

cmake_dependent_option(EXT_SODIUM_SHARED "Whether to build the sodium extension as shared object" OFF "EXT_SODIUM;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_SODIUM)
  return()
endif()

if(EXT_SODIUM_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "sodium" ${_library_type})

add_library(ext_sodium ${_library_type}
  libsodium.c
  sodium_pwhash.c
)

find_package(SODIUM 1.0.2 REQUIRED)

if(SODIUM_LIBRARIES)
  target_link_libraries(ext_sodium PRIVATE ${SODIUM_LIBRARIES})
endif()

if(SODIUM_INCLUDE_DIRS)
  target_include_directories(ext_sodium PRIVATE ${SODIUM_INCLUDE_DIRS})
endif()

# Add -Wno-type-limits and -Wno-logical-op as this may arise on 32bits platforms.
target_compile_options(ext_sodium PRIVATE -Wno-type-limits)

check_c_compiler_flag(-Wno-logical-op HAVE_WNO_LOGICAL_OP)
if(HAVE_WNO_LOGICAL_OP)
  target_compile_options(ext_sodium PRIVATE -Wno-logical-op)
  unset(HAVE_WNO_LOGICAL_OP)
endif()

set(HAVE_LIBSODIUMLIB 1 CACHE INTERNAL "Whether the libsodium is available")
