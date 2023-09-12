include(CheckCSourceRuns)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)

# Opcache extension can be built either as shared or disabled.
option(EXT_OPCACHE "Whether to enable the opcache extension" ON)

cmake_dependent_option(EXT_OPCACHE_HUGE_CODE_PAGES "Whether to enable copying PHP CODE pages into HUGE PAGES" ON "EXT_OPCACHE" OFF)

cmake_dependent_option(EXT_OPCACHE_JIT "Whether to enable JIT" ON "EXT_OPCACHE" OFF)

cmake_dependent_option(EXT_OPCACHE_CAPSTONE "Support opcache JIT disassembly through capstone" OFF "EXT_OPCACHE" OFF)

if(NOT EXT_OPCACHE)
  return()
endif()

if(EXT_OPCACHE_HUGE_CODE_PAGES)
  set(HAVE_HUGE_CODE_PAGES 1 CACHE INTERNAL "Define to enable copying PHP CODE pages into HUGE PAGES (experimental)")
endif()

if(EXT_OPCACHE_JIT)
  if(NOT ${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "i[34567]86.*|x86.*|aarch64")
    message(WARNING "JIT not supported by host architecture")
    set(EXT_OPCACHE_JIT OFF)
  endif()
endif()

if(EXT_OPCACHE_JIT)
  set(HAVE_JIT 1 CACHE INTERNAL "Define to enable JIT")

  if(${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "x86_64.*")
    set(DASM_FLAGS -D X64=1)
    set(DASM_ARCH "x86")
  elseif(${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "i[34567]86.*")
    set(DASM_ARCH "x86")
  elseif(${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "x86.*")
    set(DASM_ARCH "x86")
  elseif(${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "aarch64.*")
    set(DASM_FLAGS -D ARM64=1)
    set(DASM_ARCH "arm64")
  endif()

  string(TOLOWER "${CMAKE_HOST_SYSTEM_NAME}" _host_system_name)
  if(${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "x86_64.*" AND ${_host_system_name} MATCHES "darwin.*")
    list(APPEND DASM_FLAGS -D X64APPLE=1)
  endif()

  if(PHP_ZTS)
    list(APPEND DASM_FLAGS -D ZTS=1)
  endif()
endif()

check_symbol_exists(mprotect "sys/mman.h" HAVE_MPROTECT)

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
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

if(EXT_OPCACHE_JIT)
  add_executable(minilua
    jit/dynasm/minilua.c
  )

  target_link_libraries(minilua PRIVATE m)

  add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/jit/zend_jit_${DASM_ARCH}.c
    COMMAND minilua ${CMAKE_CURRENT_BINARY_DIR}/jit/dynasm/dynasm.lua ${DASM_FLAGS} -o ${CMAKE_CURRENT_BINARY_DIR}/jit/zend_jit_${DASM_ARCH}.c ${CMAKE_CURRENT_SOURCE_DIR}/jit/zend_jit_${DASM_ARCH}.dasc
    DEPENDS minilua
    COMMENT "Generating ext/opcache/jit/zend_jit_${DASM_ARCH}.c"
  )

  add_custom_target(
    BuildZendJitForArchitecture
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/jit/zend_jit_${DASM_ARCH}.c
    COMMENT "Building Zend JIT for architecture ${DASM_ARCH}"
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
  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}
          ${CMAKE_CURRENT_SOURCE_DIR}/jit
)

target_compile_options(ext_opcache PRIVATE
  -Wno-implicit-fallthrough
)

target_compile_definitions(ext_opcache PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

if(EXT_OPCACHE_JIT)
  target_sources(ext_opcache PRIVATE
    jit/zend_jit.c
    jit/zend_jit_gdb.c
    jit/zend_jit_vm_helpers.c
  )

  add_dependencies(ext_opcache BuildZendJitForArchitecture)

  # Check for capstone.
  if(EXT_OPCACHE_CAPSTONE)
    find_package(CAPSTONE 3.0.0)

    if(CAPSTONE_FOUND)
      set(HAVE_CAPSTONE 1 CACHE INTERNAL "Capstone is available")

      if(CAPSTONE_LIBRARIES)
        target_link_libraries(ext_opcache PRIVATE ${CAPSTONE_LIBRARIES})
      endif()

      if(CAPSTONE_INCLUDE_DIRS)
        target_include_directories(ext_opcache PRIVATE ${CAPSTONE_INCLUDE_DIRS})
      endif()
    endif()
  endif()
endif()

if(SHM_MMAP_POSIX_REQUIRED_LIBRARIES)
  target_link_libraries(ext_opcache PRIVATE ${SHM_MMAP_POSIX_REQUIRED_LIBRARIES})
endif()

install(
  TARGETS ext_opcache
  TYPE LIBRARY
  DESTINATION ${PHP_EXTENSION_DIR}
)
