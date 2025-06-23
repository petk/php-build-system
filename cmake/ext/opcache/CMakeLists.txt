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

cmake_minimum_required(VERSION 3.29...4.0)

project(
  PhpExtensionOpCache
  LANGUAGES C
)

include(CheckSymbolExists)
include(CMakeDependentOption)
include(FeatureSummary)
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
  if(
    # *nix:
    NOT CMAKE_SYSTEM_PROCESSOR MATCHES "^(i[34567]86.*|x86.*|amd64|aarch64.*)$"
    # Windows:
    AND NOT CMAKE_SYSTEM_PROCESSOR MATCHES "^(X86|AMD64)$"
  )
    message(
      WARNING
      "JIT is not supported by target architecture ${CMAKE_SYSTEM_PROCESSOR}"
    )
    set_property(CACHE PHP_EXT_OPCACHE_JIT PROPERTY VALUE OFF)
  elseif(
    CMAKE_SYSTEM_NAME STREQUAL "Darwin"
    AND CMAKE_SYSTEM_PROCESSOR MATCHES "^aarch64.*$"
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
  if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|amd64|AMD64|ARM64)$")
    set(IR_TARGET "IR_TARGET_X64")
    set(DASM_FLAGS -D X64=1)
    set(DASM_ARCH "x86")
  elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(i[34567]86.*|x86.*|X86)$")
    set(IR_TARGET "IR_TARGET_X86")
    set(DASM_ARCH "x86")
  elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^aarch64.*")
    set(IR_TARGET "IR_TARGET_AARCH64")
    set(DASM_ARCH "aarch64")
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

  # Generate ir_emit_<arch>.h file.
  add_executable(php_ext_opcache_jit_minilua jit/ir/dynasm/minilua.c)
  set_target_properties(
    php_ext_opcache_jit_minilua
    PROPERTIES
      RUNTIME_OUTPUT_DIRECTORY CMakeFiles
  )

  # Link math library as needed.
  php_search_libraries(
    floor
    HEADERS math.h
    LIBRARIES m
    TARGET php_ext_opcache_jit_minilua PRIVATE
  )

  # Help generators create a jit/ir build directory.
  file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/jit/ir)

  cmake_path(
    RELATIVE_PATH
    CMAKE_CURRENT_BINARY_DIR
    BASE_DIRECTORY ${CMAKE_BINARY_DIR}
    OUTPUT_VARIABLE relativeDir
  )

  # Generate native code generator for selected architecture.
  add_custom_command(
    OUTPUT jit/ir/ir_emit_${DASM_ARCH}.h
    COMMAND
      php_ext_opcache_jit_minilua ${CMAKE_CURRENT_SOURCE_DIR}/jit/ir/dynasm/dynasm.lua
        ${DASM_FLAGS}
        -o ${CMAKE_CURRENT_BINARY_DIR}/jit/ir/ir_emit_${DASM_ARCH}.h
        ${CMAKE_CURRENT_SOURCE_DIR}/jit/ir/ir_${DASM_ARCH}.dasc
    COMMENT "[ext/opcache] Generating native code generator ${relativeDir}/jit/ir/ir_emit_${DASM_ARCH}.h"
    DEPENDS
      jit/ir/dynasm/dynasm.lua
      jit/ir/ir_${DASM_ARCH}.dasc
    VERBATIM
    COMMAND_EXPAND_LISTS
  )

  # Create IR folding engine generator.
  add_executable(php_ext_opcache_jit_generator jit/ir/gen_ir_fold_hash.c)
  target_compile_definitions(
    php_ext_opcache_jit_generator
    PRIVATE
      ${IR_TARGET}
      IR_PHP
      IR_PHP_MM=0
  )
  set_target_properties(
    php_ext_opcache_jit_generator
    PROPERTIES
      RUNTIME_OUTPUT_DIRECTORY CMakeFiles
  )

  # Generate IR folding engine rules header.
  add_custom_command(
    OUTPUT jit/ir/ir_fold_hash.h
    COMMAND php_ext_opcache_jit_generator
      < ${CMAKE_CURRENT_SOURCE_DIR}/jit/ir/ir_fold.h
      > ${CMAKE_CURRENT_BINARY_DIR}/jit/ir/ir_fold_hash.h
    COMMENT "[ext/opcache] Generating folding engine rules ${relativeDir}/jit/ir/ir_fold_hash.h"
    DEPENDS
      jit/ir/ir_fold.h
    VERBATIM
    COMMAND_EXPAND_LISTS
  )

  target_sources(
    php_ext_opcache
    PRIVATE
      jit/ir/ir_cfg.c
      jit/ir/ir_check.c
      jit/ir/ir_dump.c
      jit/ir/ir_emit.c
      jit/ir/ir_gcm.c
      $<$<NOT:$<PLATFORM_ID:Windows>>:jit/ir/ir_gdb.c>
      jit/ir/ir_patch.c
      $<$<NOT:$<PLATFORM_ID:Windows>>:jit/ir/ir_perf.c>
      jit/ir/ir_ra.c
      jit/ir/ir_save.c
      jit/ir/ir_sccp.c
      jit/ir/ir_strtab.c
      jit/ir/ir.c
      jit/zend_jit_vm_helpers.c
      jit/zend_jit.c
      ${CMAKE_CURRENT_BINARY_DIR}/jit/ir/ir_emit_${DASM_ARCH}.h
      ${CMAKE_CURRENT_BINARY_DIR}/jit/ir/ir_fold_hash.h
  )

  target_include_directories(
    php_ext_opcache
    PRIVATE
      ${CMAKE_CURRENT_BINARY_DIR}/jit/ir
  )

  target_compile_definitions(
    php_ext_opcache
    PRIVATE
      IR_PHP
      ${IR_TARGET}
      $<$<CONFIG:Debug,DebugAssertions>:IR_DEBUG>
  )

  # Check for Capstone.
  if(PHP_EXT_OPCACHE_CAPSTONE)
    find_package(Capstone 3.0.0)
    set_package_properties(
      Capstone
      PROPERTIES
        TYPE REQUIRED
        PURPOSE "Necessary to enable OPcache JIT disassembly through Capstone."
    )

    target_sources(php_ext_opcache PRIVATE jit/ir/ir_disasm.c)

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

check_symbol_exists(mprotect sys/mman.h HAVE_MPROTECT)

# For FreeBSD.
check_symbol_exists(shm_create_largepage sys/mman.h HAVE_SHM_CREATE_LARGEPAGE)

# Check for shared memory support.
include(cmake/CheckSHM.cmake)
if(TARGET PHP::CheckSHMLibrary)
  target_link_libraries(php_ext_opcache PRIVATE PHP::CheckSHMLibrary)
endif()

configure_file(cmake/config.h.in config.h)
