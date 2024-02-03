include(CheckCompilerFlag)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(EXT_OPCACHE "Enable the opcache extension" ON)

add_feature_info(
  "ext/opcache"
  EXT_OPCACHE
  "PHP OPcode caching engine."
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

set_target_properties(php_opcache PROPERTIES PHP_ZEND_EXTENSION TRUE)

check_compiler_flag(C -Wno-implicit-fallthrough HAVE_WNO_IMPLICIT_FALLTHROUGH_C)
if(HAVE_WNO_IMPLICIT_FALLTHROUGH_C)
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

if(EXT_OPCACHE_JIT)
  if(NOT CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^(i[34567]86.*|x86.*|amd64|aarch64.*)$")
    message(WARNING "JIT is not supported by host architecture")
    set_property(CACHE EXT_OPCACHE_JIT PROPERTY VALUE 0)
  endif()
endif()

if(EXT_OPCACHE_JIT)
  set(HAVE_JIT 1 CACHE INTERNAL "Whether JIT is enabled")
  set(ZEND_JIT_IR 1 CACHE INTERNAL "Whether the JIT IR framework is used")

  target_sources(
    php_opcache
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
  )

  target_include_directories(
    php_opcache
    PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/jit/ir
  )

  # Check for Capstone.
  if(EXT_OPCACHE_CAPSTONE)
    find_package(Capstone 3.0.0)
    set_package_properties(
      Capstone
      PROPERTIES
        TYPE REQUIRED
        PURPOSE "Necessary to enable OPcache JIT disassembly through Capstone."
    )

    target_sources(php_opcache PRIVATE jit/ir/ir_disasm.c)

    target_link_libraries(php_opcache PRIVATE Capstone::Capstone)

    set(HAVE_CAPSTONE 1 CACHE INTERNAL "Capstone is available")
  endif()

  # Find out which ABI to use.
  if(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^(x86_64|amd64)$")
    set(IR_TARGET "IR_TARGET_X64")
    set(DASM_FLAGS -D X64=1)
    set(DASM_ARCH "x86")
  elseif(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^(i[34567]86.*|x86.*)$")
    set(IR_TARGET "IR_TARGET_X86")
    set(DASM_ARCH "x86")
  elseif(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^aarch64.*")
    set(IR_TARGET "IR_TARGET_AARCH64")
    set(DASM_ARCH "aarch64")
  endif()

  if(
    CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "x86_64"
    AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin"
  )
    list(APPEND DASM_FLAGS -D X64APPLE=1)
  endif()

  if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    list(APPEND DASM_FLAGS -D WIN=1)
  endif()

  if(
    CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "x86_64"
    AND CMAKE_SYSTEM_NAME STREQUAL "Windows"
  )
    list(APPEND DASM_FLAGS -D X64WIN=1)
  endif()

  target_compile_definitions(
    php_opcache
    PRIVATE
      IR_PHP
      ${IR_TARGET}
      $<$<CONFIG:Debug,DebugAssertions>:IR_DEBUG>
  )

  add_executable(
    php_opcache_jit_minilua
    jit/ir/dynasm/minilua.c
  )
  set_target_properties(
    php_opcache_jit_minilua
    PROPERTIES
      OUTPUT_NAME minilua
      RUNTIME_OUTPUT_DIRECTORY jit/ir
  )
  target_link_libraries(php_opcache_jit_minilua PRIVATE m)

  # Create jit directory in the current build directory if it doesn't exist yet.
  add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/jit
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/jit
    COMMENT "[ext/opcache] Creating ext/opcache/jit directory"
  )

  # Create IR folding engine generator.
  add_executable(
    php_opcache_jit_generator
    jit/ir/gen_ir_fold_hash.c
  )
  target_compile_definitions(
    php_opcache_jit_generator
    PRIVATE
      ${IR_TARGET}
      IR_PHP
      IR_PHP_MM=0
  )
  set_target_properties(
    php_opcache_jit_generator
    PROPERTIES
      OUTPUT_NAME gen_ir_fold_hash
      RUNTIME_OUTPUT_DIRECTORY jit/ir
  )

  # Generate IR folding engine rules header.
  add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/jit/ir/ir_fold_hash.h
    COMMAND php_opcache_jit_generator
      < ${CMAKE_CURRENT_SOURCE_DIR}/jit/ir/ir_fold.h
      > ${CMAKE_CURRENT_BINARY_DIR}/jit/ir/ir_fold_hash.h
    DEPENDS php_opcache_jit_generator ${CMAKE_CURRENT_BINARY_DIR}/jit
    COMMENT "[ext/opcache] Generating folding engine rules ext/opcache/jit/ir/ir_fold_hash.h"
  )

  # Generate native code generator for selected architecture.
  add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/jit/ir/ir_emit_${DASM_ARCH}.h
    COMMAND
      php_opcache_jit_minilua ${CMAKE_CURRENT_SOURCE_DIR}/jit/ir/dynasm/dynasm.lua
        ${DASM_FLAGS}
        -o ${CMAKE_CURRENT_BINARY_DIR}/jit/ir/ir_emit_${DASM_ARCH}.h
        ${CMAKE_CURRENT_SOURCE_DIR}/jit/ir/ir_${DASM_ARCH}.dasc
    DEPENDS
      php_opcache_jit_minilua
      ${CMAKE_CURRENT_BINARY_DIR}/jit
    COMMENT "[ext/opcache] Generating native code generator ext/opcache/jit/ir/ir_emit_${DASM_ARCH}.h"
  )

  add_custom_target(
    php_opcache_jit
    DEPENDS
      ${CMAKE_CURRENT_BINARY_DIR}/jit/ir/ir_emit_${DASM_ARCH}.h
      ${CMAKE_CURRENT_BINARY_DIR}/jit/ir/ir_fold_hash.h
    COMMENT "[ext/opcache] Building JIT for architecture ${DASM_ARCH}"
  )

  add_dependencies(php_opcache php_opcache_jit)
endif()

################################################################################
# Configuration checks.
################################################################################

check_symbol_exists(mprotect "sys/mman.h" HAVE_MPROTECT)

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(memfd_create "sys/mman.h" HAVE_MEMFD_CREATE)
cmake_pop_check_state()

# For FreeBSD.
check_symbol_exists(shm_create_largepage "sys/mman.h" HAVE_SHM_CREATE_LARGEPAGE)

if(NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
  # Check for HAVE_SHM_IPC.
  include(PHP/CheckShmIpc)

  # Check for HAVE_SHM_MMAP_ANON.
  include(PHP/CheckShmMmap)

  # Check for HAVE_SHM_MMAP_POSIX.
  include(PHP/CheckShmMmapPosix)
  if(TARGET PHP::CheckShmMmapPosix)
    target_link_libraries(php_opcache PRIVATE PHP::CheckShmMmapPosix)
  endif()

  if(NOT HAVE_SHM_IPC AND NOT HAVE_SHM_MMAP_ANON AND NOT HAVE_SHM_MMAP_POSIX)
    message(
      FATAL_ERROR
      "No supported shared memory caching support was found when configuring "
      "opcache. Please check CMake logs for any errors or missing dependencies."
    )
  endif()
endif()

install(
  TARGETS php_opcache
  RUNTIME
    DESTINATION "${PHP_EXTENSION_DIR}"
  LIBRARY
    DESTINATION "${PHP_EXTENSION_DIR}"
)
