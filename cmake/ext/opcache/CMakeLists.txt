#[=============================================================================[
# The Zend OPcache extension

This extension enables the PHP OPcode caching engine.

## PHP_EXT_OPCACHE

* Default: `ON`
* Values: `ON|OFF`

Enable the extension. This extension is always built as shared when enabled.

## PHP_EXT_OPCACHE_HUGE_CODE_PAGES

* Default: `ON`
* Values: `ON|OFF`

Enable copying PHP CODE pages into HUGE PAGES.

## PHP_EXT_OPCACHE_JIT

* Default: `ON`
* Values: `ON|OFF`

Enable JIT (just-in-time) compilation.

## PHP_EXT_OPCACHE_CAPSTONE

* Default: `OFF`
* Values: `ON|OFF`

Enable OPcache JIT disassembly through Capstone engine.
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.2)

project(
  PhpExtensionOpCache
  LANGUAGES C
)

include(CheckSymbolExists)
include(CMakeDependentOption)
include(FeatureSummary)
include(PHP/CheckCompilerFlag)
include(PHP/SearchLibraries)

option(PHP_EXT_OPCACHE "Enable the Zend OPcache extension" ON)
add_feature_info(
  "ext/opcache"
  PHP_EXT_OPCACHE
  "PHP OPcode caching engine"
)

cmake_dependent_option(
  PHP_EXT_OPCACHE_HUGE_CODE_PAGES
  "Enable copying PHP CODE pages into HUGE PAGES"
  ON
  [[PHP_EXT_OPCACHE AND NOT CMAKE_SYSTEM_NAME STREQUAL "Windows"]]
  OFF
)

cmake_dependent_option(
  PHP_EXT_OPCACHE_JIT
  "Enable JIT (just-in-time) compilation"
  ON
  PHP_EXT_OPCACHE
  OFF
)

cmake_dependent_option(
  PHP_EXT_OPCACHE_CAPSTONE
  "Support OPcache JIT disassembly through Capstone engine"
  OFF
  PHP_EXT_OPCACHE
  OFF
)

if(NOT PHP_EXT_OPCACHE)
  return()
endif()

################################################################################
# Add library.
################################################################################

add_library(php_ext_opcache MODULE)

target_sources(
  php_ext_opcache
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

add_dependencies(php_ext_opcache php_ext_date php_ext_pcre)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  add_dependencies(php_ext_opcache php_ext_hash)
endif()

set_target_properties(
  php_ext_opcache
  PROPERTIES
    PHP_ZEND_EXTENSION TRUE
)

target_compile_definitions(php_ext_opcache PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

if(PHP_EXT_OPCACHE_HUGE_CODE_PAGES)
  set(HAVE_HUGE_CODE_PAGES TRUE)
endif()

################################################################################
# JIT.
################################################################################

# Check if JIT is supported by the target architecture.
if(PHP_EXT_OPCACHE_JIT)
  if(NOT CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "(i[3456]86|x86_64|aarch64|arm64|x64|X86|ARM64)")
    message(
      WARNING
      "JIT is not supported by target architecture "
      "${CMAKE_C_COMPILER_ARCHITECTURE_ID}"
    )
    set_property(CACHE PHP_EXT_OPCACHE_JIT PROPERTY VALUE OFF)
  elseif(
    CMAKE_SYSTEM_NAME STREQUAL "Darwin"
    AND CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "arm64"
    AND PHP_THREAD_SAFETY
  )
    message(
      WARNING
      "JIT is not supported on Apple Silicon with thread safety enabled"
    )
    set_property(CACHE PHP_EXT_OPCACHE_JIT PROPERTY VALUE OFF)
  endif()
endif()

target_include_directories(
  php_ext_opcache
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
)

if(PHP_EXT_OPCACHE_JIT)
  # Find out which ABI to use.
  if(CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "(x86_64|x64)")
    set(DASM_FLAGS -D X64=1)
    set(DASM_ARCH "x86")
  elseif(CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "(i[34567]86|X86)")
    set(DASM_ARCH "x86")
  elseif(CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "(arm64|ARM64|aarch64)")
    set(DASM_FLAGS -D ARM64=1)
    set(DASM_ARCH "arm64")
  endif()

  if(
    CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "x86_64"
    AND CMAKE_SYSTEM_NAME STREQUAL "Darwin"
  )
    list(APPEND DASM_FLAGS -D X64APPLE=1)
  endif()

  if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    list(APPEND DASM_FLAGS -D WIN=1)
  endif()

  if(
    CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "(x86_64|x64|ARM64|aarch64)"
    AND CMAKE_SYSTEM_NAME STREQUAL "Windows"
  )
    list(APPEND DASM_FLAGS -D X64WIN=1)
  endif()

  if(PHP_THREAD_SAFETY)
    list(APPEND DASM_FLAGS -D ZTS=1)
  endif()

  # Generate zend_jit_<arch>.c file.
  add_executable(php_ext_opcache_jit_minilua jit/dynasm/minilua.c)
  set_target_properties(
    php_ext_opcache_jit_minilua
    PROPERTIES
      RUNTIME_OUTPUT_DIRECTORY CMakeFiles
  )

  # Link math library as needed.
  php_search_libraries(
    SYMBOL floor
    HEADERS math.h
    LIBRARIES m
    RESULT_VARIABLE PHP_EXT_OPCACHE_HAVE_FLOOR
    TARGET php_ext_opcache_jit_minilua PRIVATE
  )

  # Help minilua create a jit build directory.
  file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/jit)

  cmake_path(
    RELATIVE_PATH
    CMAKE_CURRENT_BINARY_DIR
    BASE_DIRECTORY ${CMAKE_BINARY_DIR}
    OUTPUT_VARIABLE relativeDir
  )

  # Generate Jit for architecture.
  add_custom_command(
    OUTPUT jit/zend_jit_${DASM_ARCH}.c
    COMMAND
      php_ext_opcache_jit_minilua ${CMAKE_CURRENT_SOURCE_DIR}/jit/dynasm/dynasm.lua
        ${DASM_FLAGS}
        -o ${CMAKE_CURRENT_BINARY_DIR}/jit/zend_jit_${DASM_ARCH}.c
        ${CMAKE_CURRENT_SOURCE_DIR}/jit/zend_jit_${DASM_ARCH}.dasc
    COMMENT "[ext/opcache] Generating ${relativeDir}/jit/zend_jit_${DASM_ARCH}.c"
    DEPENDS
      jit/dynasm/dynasm.lua
      jit/zend_jit_${DASM_ARCH}.dasc
    VERBATIM
    COMMAND_EXPAND_LISTS
  )

  target_sources(
    php_ext_opcache
    PRIVATE
      $<$<NOT:$<PLATFORM_ID:Windows>>:jit/zend_jit_gdb.c>
      jit/zend_jit_vm_helpers.c
      jit/zend_jit.c
      ${CMAKE_CURRENT_BINARY_DIR}/jit/zend_jit_${DASM_ARCH}.c
  )

  # Mark generated file as "header" to not get compiled into its own object.
  set_source_files_properties(
    ${CMAKE_CURRENT_BINARY_DIR}/jit/zend_jit_${DASM_ARCH}.c
    PROPERTIES HEADER_FILE_ONLY ON
  )

  # The string.h header is always available with C89 standard. The bundled
  # ext/opcache/jit/libudis86 still includes it conditionally.
  target_compile_definitions(php_ext_opcache PRIVATE HAVE_STRING_H=1)

  php_check_compiler_flag(
    C
    -Wno-implicit-fallthrough
    PHP_HAS_WNO_IMPLICIT_FALLTHROUGH_C
  )
  if(PHP_HAS_WNO_IMPLICIT_FALLTHROUGH_C)
    target_compile_options(php_ext_opcache PRIVATE -Wno-implicit-fallthrough)
  endif()

  # Check for Capstone.
  if(PHP_EXT_OPCACHE_CAPSTONE)
    find_package(Capstone 3.0.0)
    set_package_properties(
      Capstone
      PROPERTIES
        TYPE REQUIRED
        PURPOSE "Necessary to enable OPcache JIT disassembly through Capstone."
    )

    target_link_libraries(php_ext_opcache PRIVATE Capstone::Capstone)

    set(HAVE_CAPSTONE TRUE)
  endif()

  set(HAVE_JIT TRUE)
endif()

add_feature_info(
  "ext/opcache JIT"
  HAVE_JIT
  "OPcache just-in-time compilation"
)

add_feature_info(
  "ext/opcache Capstone"
  HAVE_CAPSTONE
  "OPcache JIT disassembly through Capstone engine"
)

################################################################################
# Configuration checks.
################################################################################

check_symbol_exists(mprotect sys/mman.h PHP_EXT_OPCACHE_HAVE_MPROTECT)
set(HAVE_MPROTECT ${PHP_EXT_OPCACHE_HAVE_MPROTECT})

# Check for shared memory support.
include(cmake/CheckSHM.cmake)

configure_file(cmake/config.h.in config.h)
