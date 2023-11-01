include(CheckCCompilerFlag)
include(CheckCSourceRuns)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(EXT_OPCACHE "Enable the opcache extension" ON)

add_feature_info("ext/opcache" EXT_OPCACHE
  "Adds support for PHP OPcode caching engine."
)

cmake_dependent_option(
  EXT_OPCACHE_HUGE_CODE_PAGES
  "Enable copying PHP CODE pages into HUGE PAGES"
  ON
  "EXT_OPCACHE"
  OFF
)

cmake_dependent_option(
  EXT_OPCACHE_JIT
  "Enable JIT"
  ON
  "EXT_OPCACHE"
  OFF
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

  if(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "x86_64.*" AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
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

if(PHP_VERSION VERSION_GREATER_EQUAL "8.4")
  # Check for FreeBSD.
  check_symbol_exists(shm_create_largepage "sys/mman.h" HAVE_SHM_CREATE_LARGEPAGE)
endif()

# Check for HAVE_SHM_IPC.
include(PHP/CheckShmIpc)

# Check for HAVE_SHM_MMAP_ANON.
include(PHP/CheckShmMmap)

# Check for HAVE_SHM_MMAP_POSIX.
include(PHP/CheckShmMmapPosix)

if(NOT HAVE_SHM_IPC AND NOT HAVE_SHM_MMAP_ANON AND NOT HAVE_SHM_MMAP_POSIX)
  message(
    FATAL_ERROR
    "No supported shared memory caching support was found when configuring "
    "opcache. Please check logs for any errors or missing dependencies."
  )
endif()

# OPcache extension can be built only as a shared library.
add_library(php_opcache SHARED
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
  php_opcache
  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/jit
          ${CMAKE_CURRENT_BINARY_DIR}/jit
)

check_c_compiler_flag(-Wno-implicit-fallthrough HAVE_WNO_IMPLICIT_FALLTHROUGH)
if(HAVE_WNO_IMPLICIT_FALLTHROUGH)
  target_compile_options(php_opcache PRIVATE -Wno-implicit-fallthrough)
endif()

target_compile_definitions(php_opcache PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

if(SHM_MMAP_POSIX_REQUIRED_LIBRARIES)
  target_link_libraries(php_opcache PRIVATE ${SHM_MMAP_POSIX_REQUIRED_LIBRARIES})
endif()

if(EXT_OPCACHE_JIT)
  target_sources(php_opcache PRIVATE
    jit/zend_jit.c
    jit/zend_jit_gdb.c
    jit/zend_jit_vm_helpers.c
  )

  add_executable(php_opcache_minilua
    jit/dynasm/minilua.c
  )

  set_target_properties(php_opcache_minilua PROPERTIES OUTPUT_NAME minilua)

  target_link_libraries(php_opcache_minilua PRIVATE m)

  # Create jit directory in the current build directory if it doesn't exist yet.
  add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/jit
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/jit
    COMMENT "Creating ext/opcache/jit directory"
  )

  # Generate Zend Jit for architecture.
  add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/jit/zend_jit_${DASM_ARCH}.c
    COMMAND php_opcache_minilua ${CMAKE_CURRENT_LIST_DIR}/jit/dynasm/dynasm.lua ${DASM_FLAGS} -o ${CMAKE_CURRENT_BINARY_DIR}/jit/zend_jit_${DASM_ARCH}.c ${CMAKE_CURRENT_LIST_DIR}/jit/zend_jit_${DASM_ARCH}.dasc
    DEPENDS php_opcache_minilua ${CMAKE_CURRENT_BINARY_DIR}/jit
    COMMENT "Generating ext/opcache/jit/zend_jit_${DASM_ARCH}.c"
  )

  add_custom_target(
    php_opcache_build_jit
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/jit/zend_jit_${DASM_ARCH}.c
    COMMENT "Building Zend JIT for architecture ${DASM_ARCH}"
  )

  add_dependencies(php_opcache php_opcache_build_jit)

  # Check for Capstone.
  if(EXT_OPCACHE_CAPSTONE)
    find_package(Capstone 3.0.0)
    set_package_properties(Capstone PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable OPcache JIT disassembly through Capstone."
    )

    target_link_libraries(php_opcache PRIVATE Capstone::Capstone)

    set(HAVE_CAPSTONE 1 CACHE INTERNAL "Capstone is available")
  endif()
endif()

install(
  TARGETS php_opcache
  TYPE LIBRARY
  DESTINATION ${PHP_EXTENSION_DIR}
)
