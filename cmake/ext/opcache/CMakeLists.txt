project(
  PhpExtensionOpCache
  LANGUAGES C
)

include(CheckSymbolExists)
include(CMakeDependentOption)
include(FeatureSummary)
include(PHP/CheckCompilerFlag)
include(PHP/SearchLibraries)

option(EXT_OPCACHE "Enable the opcache extension" ON)

add_feature_info(
  "ext/opcache"
  EXT_OPCACHE
  "PHP OPcode caching engine"
)

cmake_dependent_option(
  EXT_OPCACHE_HUGE_CODE_PAGES
  "Enable copying PHP CODE pages into HUGE PAGES"
  ON
  [[EXT_OPCACHE AND NOT CMAKE_SYSTEM_NAME STREQUAL "Windows"]]
  OFF
)

cmake_dependent_option(
  EXT_OPCACHE_JIT
  "Enable JIT"
  ON
  "EXT_OPCACHE"
  OFF
)

add_feature_info(
  "ext/opcache JIT"
  EXT_OPCACHE_JIT
  "Opcache's JIT (Just-In-Time compiler)"
)

cmake_dependent_option(
  EXT_OPCACHE_CAPSTONE
  "Support opcache JIT disassembly through Capstone"
  OFF
  "EXT_OPCACHE"
  OFF
)

if(NOT EXT_OPCACHE)
  return()
endif()

################################################################################
# Add library.
################################################################################

# OPcache extension can be built only as a shared library.
add_library(php_opcache SHARED)

target_sources(
  php_opcache
  PRIVATE
    opcache.stub.php
    $<$<NOT:$<PLATFORM_ID:Windows>>:shared_alloc_mmap.c>
    $<$<NOT:$<PLATFORM_ID:Windows>>:shared_alloc_posix.c>
    $<$<NOT:$<PLATFORM_ID:Windows>>:shared_alloc_shm.c>
    $<$<PLATFORM_ID:Windows>:shared_alloc_win32.c>
    zend_accelerator_blacklist.c
    zend_accelerator_debug.c
    zend_accelerator_hash.c
    zend_accelerator_module.c
    zend_accelerator_util_funcs.c
    zend_file_cache.c
    zend_persist_calc.c
    zend_persist.c
    zend_shared_alloc.c
    ZendAccelerator.c
)

target_include_directories(
  php_opcache
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/jit
    ${CMAKE_CURRENT_BINARY_DIR}/jit
)

add_dependencies(php_opcache php_date php_pcre)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  add_dependencies(php_opcache php_hash)
endif()

set_target_properties(
  php_opcache
  PROPERTIES
    PHP_ZEND_EXTENSION TRUE
)

php_check_compiler_flag(
  C
  -Wno-implicit-fallthrough
  _HAVE_WNO_IMPLICIT_FALLTHROUGH_C
)
if(_HAVE_WNO_IMPLICIT_FALLTHROUGH_C)
  target_compile_options(php_opcache PRIVATE -Wno-implicit-fallthrough)
endif()

target_compile_definitions(php_opcache PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

if(EXT_OPCACHE_HUGE_CODE_PAGES)
  set(
    HAVE_HUGE_CODE_PAGES 1
    CACHE INTERNAL "Whether to copy PHP CODE pages into HUGE PAGES (experimental)"
  )
endif()

################################################################################
# JIT.
################################################################################

# Check JIT requirements.
if(EXT_OPCACHE_JIT)
  if(
    # *nix:
    NOT CMAKE_SYSTEM_PROCESSOR MATCHES "^(i[34567]86.*|x86.*|amd64|aarch64.*)$"
    # Windows:
    AND NOT CMAKE_SYSTEM_PROCESSOR MATCHES "^(X86|AMD64|ARM64)$"
  )
    message(
      WARNING
      "JIT is not supported by target architecture ${CMAKE_SYSTEM_PROCESSOR}"
    )
    set_property(CACHE EXT_OPCACHE_JIT PROPERTY VALUE 0)
  elseif(
    CMAKE_SYSTEM_NAME STREQUAL "Darwin"
    AND CMAKE_SYSTEM_PROCESSOR MATCHES "^aarch64.*$"
    AND PHP_THREAD_SAFETY
  )
    message(
      WARNING
      "JIT is not supported on Apple Silicon with thread safety enabled"
    )
    set_property(CACHE EXT_OPCACHE_JIT PROPERTY VALUE 0)
  endif()
endif()

if(EXT_OPCACHE_JIT)
  set(HAVE_JIT 1 CACHE INTERNAL "Whether JIT is enabled")

  target_sources(
    php_opcache
    PRIVATE
      $<$<NOT:$<PLATFORM_ID:Windows>>:jit/zend_jit_gdb.c>
      jit/zend_jit_vm_helpers.c
      jit/zend_jit.c
  )

  # The string.h header is always available with C89 standard. The bundled
  # ext/opcache/jit/libudis86 still includes it conditionally.
  target_compile_definitions(php_opcache PRIVATE HAVE_STRING_H=1)

  # Check for Capstone.
  if(EXT_OPCACHE_CAPSTONE)
    find_package(Capstone 3.0.0)
    set_package_properties(
      Capstone
      PROPERTIES
        TYPE REQUIRED
        PURPOSE "Necessary to enable OPcache JIT disassembly through Capstone."
    )

    target_link_libraries(php_opcache PRIVATE Capstone::Capstone)

    set(HAVE_CAPSTONE 1 CACHE INTERNAL "Capstone is available")
  endif()

  # Find out which ABI to use.
  if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|amd64|AMD64|ARM64)$")
    set(DASM_FLAGS -D X64=1)
    set(DASM_ARCH "x86")
  elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(i[34567]86.*|x86.*|X86)$")
    set(DASM_ARCH "x86")
  elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^aarch64.*")
    set(DASM_FLAGS -D ARM64=1)
    set(DASM_ARCH "arm64")
  endif()

  if(
    CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64"
    AND CMAKE_SYSTEM_NAME STREQUAL "Darwin"
  )
    list(APPEND DASM_FLAGS -D X64APPLE=1)
  endif()

  if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    list(APPEND DASM_FLAGS -D WIN=1)
  endif()

  if(
    CMAKE_SYSTEM_PROCESSOR MATCHES "^(AMD64|ARM64)$"
    AND CMAKE_SYSTEM_NAME STREQUAL "Windows"
  )
    list(APPEND DASM_FLAGS -D X64WIN=1)
  endif()

  if(PHP_THREAD_SAFETY)
    list(APPEND DASM_FLAGS -D ZTS=1)
  endif()

  add_executable(
    php_opcache_jit_minilua
    jit/dynasm/minilua.c
  )
  set_target_properties(
    php_opcache_jit_minilua
    PROPERTIES
      OUTPUT_NAME minilua
  )

  # Link math library as needed.
  php_search_libraries(
    floor
    _HAVE_FLOOR
    HEADERS math.h
    LIBRARIES m
    TARGET php_opcache_jit_minilua PRIVATE
  )

  # Create jit directory in the current build directory if it doesn't exist yet.
  add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/jit
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/jit
    COMMENT "[ext/opcache] Creating ext/opcache/jit directory"
  )

  # Generate Jit for architecture.
  add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/jit/zend_jit_${DASM_ARCH}.c
    COMMAND
      php_opcache_jit_minilua ${CMAKE_CURRENT_LIST_DIR}/jit/dynasm/dynasm.lua
        ${DASM_FLAGS}
        -o ${CMAKE_CURRENT_BINARY_DIR}/jit/zend_jit_${DASM_ARCH}.c
        ${CMAKE_CURRENT_LIST_DIR}/jit/zend_jit_${DASM_ARCH}.dasc
    DEPENDS
      php_opcache_jit_minilua
      ${CMAKE_CURRENT_BINARY_DIR}/jit
    COMMENT "[ext/opcache] Generating ext/opcache/jit/zend_jit_${DASM_ARCH}.c"
  )

  add_custom_target(
    php_opcache_jit
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/jit/zend_jit_${DASM_ARCH}.c
    COMMENT "[ext/opcache] Building JIT for architecture ${DASM_ARCH}"
  )

  add_dependencies(php_opcache php_opcache_jit)
endif()

################################################################################
# Configuration checks.
################################################################################

check_symbol_exists(mprotect "sys/mman.h" HAVE_MPROTECT)

# Check for shared memory support.
include(PHP/CheckSHM)
if(TARGET PHP::CheckSHMLibrary)
  target_link_libraries(php_opcache PRIVATE PHP::CheckSHMLibrary)
endif()

configure_file(config.cmake.h.in config.h @ONLY)
