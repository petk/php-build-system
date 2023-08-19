include(CheckCSourceRuns)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(PHPFindPackage)

# Opcache extension can be built either as shared or disabled.
option(opcache "Whether to enable the opcache extension" ON)

cmake_dependent_option(huge_code_pages "Whether to enable copying PHP CODE pages into HUGE PAGES" ON "opcache" OFF)

if(huge_code_pages)
  set(HAVE_HUGE_CODE_PAGES 1 CACHE INTERNAL "Define to enable copying PHP CODE pages into HUGE PAGES (experimental)")
else()
  set(HAVE_HUGE_CODE_PAGES 0 CACHE INTERNAL "Define to enable copying PHP CODE pages into HUGE PAGES (experimental)")
endif()

cmake_dependent_option(opcache_jit "Whether to enable JIT" ON "opcache" OFF)

cmake_dependent_option(capstone "Support opcache JIT disassembly through capstone" OFF "opcache" OFF)

if(NOT opcache)
  return()
endif()

if(opcache_jit)
  if(NOT ${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "i[34567]86.*|x86.*|aarch64")
    message(WARNING "JIT not supported by host architecture")
    set(opcache_jit OFF)
  endif()
endif()

if(opcache_jit)
  set(HAVE_JIT 1 CACHE INTERNAL "Define to enable JIT")

  string(TOLOWER "${PHP_UNAME}" host_os)
  if(${host_os} MATCHES "x86_64-.*-darwin.*")
    set(DASM_FLAGS -D X64APPLE=1 -D X64=1)
    set(DASM_ARCH "x86")
  elseif(${host_os} MATCHES "x86_64.*")
    set(DASM_FLAGS -D X64=1)
    set(DASM_ARCH "x86")
  elseif(${host_os} MATCHES "i[34567]86.*")
    set(DASM_ARCH "x86")
  elseif(${host_os} MATCHES "x86.*")
    set(DASM_ARCH "x86")
  elseif(${host_os} MATCHES "aarch64.*")
    set(DASM_FLAGS -D ARM64=1)
    set(DASM_ARCH "arm64")
  endif()

  if(ZTS)
    list(APPEND DASM_FLAGS -D ZTS=1)
  endif()
endif()

check_symbol_exists(mprotect "sys/mman.h" HAVE_MPROTECT)

cmake_push_check_state()
  set(CMAKE_REQUIRED_DEFINITIONS "${CMAKE_REQUIRED_DEFINITIONS} -D_GNU_SOURCE")
  check_symbol_exists(memfd_create "sys/mman.h" HAVE_MEMFD_CREATE)
cmake_pop_check_state()

# Check for HAVE_SHM_IPC.
include(PHPCheckShmIpc)

# Check for HAVE_SHM_MMAP_ANON.
include(PHPCheckShmMmap)

# Check for HAVE_SHM_MMAP_POSIX.
include(PHPCheckShmMmapPosix)

if(NOT HAVE_SHM_IPC AND NOT HAVE_SHM_MMAP_ANON AND NOT HAVE_SHM_MMAP_POSIX)
  message(FATAL_ERROR "No supported shared memory caching support was found when configuring opcache. Check config.log for any errors or missing dependencies.")
endif()

# OPcache extension can be either disabled or built as shared.
php_extension(NAME "opcache" SHARED)

if(opcache_jit)
  add_executable(minilua
    jit/dynasm/minilua.c
  )

  target_link_libraries(minilua PUBLIC m)

  add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/jit/zend_jit_${DASM_ARCH}.c
    COMMAND minilua ${CMAKE_CURRENT_BINARY_DIR}/jit/dynasm/dynasm.lua ${DASM_FLAGS} -o ${CMAKE_CURRENT_BINARY_DIR}/jit/zend_jit_${DASM_ARCH}.c ${CMAKE_CURRENT_SOURCE_DIR}/jit/zend_jit_${DASM_ARCH}.dasc
    DEPENDS minilua
    COMMENT "Generating ext/opcache/jit/zend_jit_${DASM_ARCH}.c"
  )

  add_custom_target(
    BuildZendJitForArchitecture
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/jit/zend_jit_${DASM_ARCH}.c
  )
endif()

add_library(ext_opcache SHARED
  ZendAccelerator.c
  zend_accelerator_blacklist.c
  zend_accelerator_debug.c
  zend_accelerator_hash.c
  zend_accelerator_module.c
  zend_persist.c
  zend_persist_calc.c
  zend_file_cache.c
  zend_shared_alloc.c
  zend_accelerator_util_funcs.c
  shared_alloc_shm.c
  shared_alloc_mmap.c
  shared_alloc_posix.c
)

target_include_directories(
  ext_opcache
  PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
  PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/jit"
)

target_compile_options(ext_opcache PRIVATE
  -Wno-implicit-fallthrough
)

target_compile_definitions(ext_opcache PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

if(opcache_jit)
  target_sources(ext_opcache PRIVATE
    jit/zend_jit.c
    jit/zend_jit_gdb.c
    jit/zend_jit_vm_helpers.c
  )

  add_dependencies(ext_opcache BuildZendJitForArchitecture)

  # Check for capstone.
  if(capstone)
    php_find_package(NAME capstone VERSION 3.0.0)

    if(capstone_FOUND)
      set(HAVE_CAPSTONE 1 CACHE INTERNAL "Capstone is available")
      target_link_libraries(ext_opcache PRIVATE ${capstone_LIBRARIES})
      target_compile_options(ext_opcache PRIVATE ${capstone_CFLAGS})
    endif()
  endif()
endif()

if(SHM_MMAP_POSIX_REQUIRED_LIBRARIES)
  target_link_libraries(ext_opcache PRIVATE ${SHM_MMAP_POSIX_REQUIRED_LIBRARIES})
endif()

target_link_libraries(ext_opcache PRIVATE Zend main ext_standard)
