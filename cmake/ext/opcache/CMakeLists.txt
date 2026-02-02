#[=============================================================================[
# The Zend OPcache extension

This extension enables the PHP OPcode caching engine.

## Configuration options

### PHP_EXT_OPCACHE

:red_circle: *Removed as of PHP 8.5.*

* Default: `ON`
* Values: `ON|OFF`

Enables the extension. This extension is always built as shared when enabled. As
of PHP 8.5, this extension is always enabled and cannot be disabled.

### PHP_EXT_OPCACHE_HUGE_CODE_PAGES

* Default: `ON`
* Values: `ON|OFF`

Enables copying PHP CODE pages into HUGE PAGES.

> [!NOTE]
> This option is not available when the target system is Windows.

### PHP_EXT_OPCACHE_JIT

* Default: `ON`
* Values: `ON|OFF`

Enables JIT (just-in-time) compilation.

### PHP_EXT_OPCACHE_CAPSTONE

* Default: `OFF`
* Values: `ON|OFF`

Enables OPcache JIT disassembly through Capstone engine.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

project(
  PHP_EXT_OPCACHE
  LANGUAGES C
)

if(PROJECT_IS_TOP_LEVEL)
  message(
    FATAL_ERROR
    "The PHP opcache extension is intended to be built only within the "
    "top-level PHP source tree (php-src)."
  )
endif()

include(CheckSymbolExists)
include(CMakeDependentOption)
include(FeatureSummary)
include(PHP/SearchLibraries)

add_feature_info(
  "ext/opcache"
  TRUE
  "PHP OPcode caching engine"
)

cmake_dependent_option(
  PHP_EXT_OPCACHE_HUGE_CODE_PAGES
  "Enable copying PHP CODE pages into HUGE PAGES"
  ON
  [[NOT CMAKE_SYSTEM_NAME STREQUAL "Windows"]]
  OFF
)
add_feature_info(
  "ext/opcache HUGE PAGES"
  PHP_EXT_OPCACHE_HUGE_CODE_PAGES
  "PHP CODE pages are copied into HUGE PAGES"
)

option(PHP_EXT_OPCACHE_JIT "Enable JIT (just-in-time) compilation" ON)

option(
  PHP_EXT_OPCACHE_CAPSTONE
  "Support OPcache JIT disassembly through Capstone engine"
)

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(opcache)

################################################################################
# Add library.
################################################################################

add_library(php_ext_opcache OBJECT)

target_sources(
  php_ext_opcache
  PRIVATE
    opcache.stub.php
    $<$<NOT:$<PLATFORM_ID:Windows>>:shared_alloc_mmap.c>
    $<$<NOT:$<PLATFORM_ID:Windows>>:shared_alloc_posix.c>
    $<$<NOT:$<PLATFORM_ID:Windows>>:shared_alloc_shm.c>
    $<$<PLATFORM_ID:Windows>:shared_alloc_win32.c>
    zend_accelerator_api.c
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
    PUBLIC
    FILE_SET HEADERS
      FILES
        zend_accelerator_api.h
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
    CMAKE_SYSTEM_NAME STREQUAL "Windows"
    AND CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "(arm|aarch64|ARM)"
  )
    message(
      WARNING
      "JIT is not supported by target architecture "
      "${CMAKE_C_COMPILER_ARCHITECTURE_ID}"
    )
    set_property(CACHE PHP_EXT_OPCACHE_JIT PROPERTY VALUE OFF)
  elseif(
    NOT CMAKE_C_COMPILER_ARCHITECTURE_ID
    MATCHES "(i[3456]86|x86_64|aarch64|arm64|x64|X86)"
  )
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
  set(dasm_arch "")
  set(dasm_flags "")
  set(ir_target "")
  set(tls_target "")

  # Find out which ABI to use.
  if(CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "(x86_64|x64)")
    set(dasm_arch "x86")
    set(dasm_flags -D X64=1)
    set(ir_target "IR_TARGET_X64")
    set(tls_target "x86_64")
  elseif(CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "(i[34567]86|X86)")
    set(dasm_arch "x86")
    set(ir_target "IR_TARGET_X86")
    set(tls_target "x86")
  elseif(CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "(arm64|aarch64")
    set(dasm_arch "aarch64")
    set(ir_target "IR_TARGET_AARCH64")
    set(tls_target "aarch64")
  endif()

  if(
    CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "x86_64"
    AND CMAKE_SYSTEM_NAME STREQUAL "Darwin"
  )
    list(APPEND dasm_flags -D X64APPLE=1)
    set(tls_target "darwin")
  endif()

  if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    list(APPEND dasm_flags -D WIN=1)
    set(tls_target "win")
  endif()

  if(
    CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "(x86_64|x64)"
    AND CMAKE_SYSTEM_NAME STREQUAL "Windows"
  )
    list(APPEND dasm_flags -D X64WIN=1)
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
    SYMBOL floor
    HEADERS math.h
    LIBRARIES m
    RESULT_VARIABLE PHP_EXT_OPCACHE_HAVE_FLOOR
    TARGET php_ext_opcache_jit_minilua PRIVATE
  )

  # Help generators create a jit/ir build directory.
  file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/jit/ir)

  cmake_path(
    RELATIVE_PATH
    CMAKE_CURRENT_BINARY_DIR
    BASE_DIRECTORY ${CMAKE_BINARY_DIR}
    OUTPUT_VARIABLE relative_dir
  )

  # Generate native code generator for selected architecture.
  add_custom_command(
    OUTPUT jit/ir/ir_emit_${dasm_arch}.h
    COMMAND
      php_ext_opcache_jit_minilua
        ${CMAKE_CURRENT_SOURCE_DIR}/jit/ir/dynasm/dynasm.lua
        ${dasm_flags}
        -o ${CMAKE_CURRENT_BINARY_DIR}/jit/ir/ir_emit_${dasm_arch}.h
        ${CMAKE_CURRENT_SOURCE_DIR}/jit/ir/ir_${dasm_arch}.dasc
    COMMENT
      "[ext/opcache] Generating native code generator ${relative_dir}/jit/ir/ir_emit_${dasm_arch}.h"
    DEPENDS
      jit/ir/dynasm/dynasm.lua
      jit/ir/ir_${dasm_arch}.dasc
    VERBATIM
    COMMAND_EXPAND_LISTS
  )

  # Create IR folding engine generator.
  add_executable(php_ext_opcache_jit_generator jit/ir/gen_ir_fold_hash.c)
  target_compile_definitions(
    php_ext_opcache_jit_generator
    PRIVATE
      ${ir_target}
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
    COMMAND
      php_ext_opcache_jit_generator
      < ${CMAKE_CURRENT_SOURCE_DIR}/jit/ir/ir_fold.h
      > ${CMAKE_CURRENT_BINARY_DIR}/jit/ir/ir_fold_hash.h
    COMMENT
      "[ext/opcache] Generating folding engine rules ${relative_dir}/jit/ir/ir_fold_hash.h"
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
      ${CMAKE_CURRENT_BINARY_DIR}/jit/ir/ir_emit_${dasm_arch}.h
      ${CMAKE_CURRENT_BINARY_DIR}/jit/ir/ir_fold_hash.h
  )

  if(tls_target AND PHP_THREAD_SAFETY)
    target_sources(php_ext_opcache PRIVATE jit/tls/zend_jit_tls_${tls_target}.c)
  endif()

  target_include_directories(
    php_ext_opcache
    PRIVATE
      ${CMAKE_CURRENT_BINARY_DIR}/jit/ir
  )

  target_compile_definitions(
    php_ext_opcache
    PRIVATE
      IR_PHP
      ${ir_target}
      $<$<CONFIG:Debug,DebugAssertions>:IR_DEBUG>
  )

  foreach(
    file IN ITEMS
      ${CMAKE_CURRENT_SOURCE_DIR}/jit/zend_jit_helpers.c
      ${CMAKE_CURRENT_SOURCE_DIR}/jit/zend_jit_ir.c
  )
    set_property(SOURCE jit/zend_jit.c APPEND PROPERTY OBJECT_DEPENDS "${file}")
  endforeach()

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

check_symbol_exists(mprotect sys/mman.h PHP_EXT_OPCACHE_HAVE_MPROTECT)
set(HAVE_MPROTECT ${PHP_EXT_OPCACHE_HAVE_MPROTECT})

# For FreeBSD.
check_symbol_exists(
  shm_create_largepage
  sys/mman.h
  PHP_EXT_OPCACHE_HAVE_SHM_CREATE_LARGEPAGE
)
set(HAVE_SHM_CREATE_LARGEPAGE ${PHP_EXT_OPCACHE_HAVE_SHM_CREATE_LARGEPAGE})

# Check for shared memory support.
include(cmake/CheckSHM.cmake)

configure_file(cmake/config.h.in config.h)
