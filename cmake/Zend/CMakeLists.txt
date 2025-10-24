#[=============================================================================[
Zend Engine.

Targets:

* OBJECT library 'zend' (ALIAS Zend::Zend) holds all Zend Engine objects and
  compile properties.

Target properties:

CMake target properties for the Zend::Zend target:

* VERSION
  Zend Engine version as defined in the Zend/zend.h file.

* ZEND_EXTENSION_API_NO
  Custom target property with internal API version number for PHP extensions
  (dynamically loaded with the 'extension' INI directive). This is the
  ZEND_MODULE_API_NO number from the Zend/zend_modules.h and ensures that built
  extension is compatible with particular PHP build.

* ZEND_MODULE_API_NO
  Custom target property with internal API version number for Zend extensions in
  PHP (dynamically loaded with the 'zend_extension' INI directive), such as
  opcache, debuggers, profilers, etc. This is the ZEND_EXTENSION_API_NO number
  from the Zend/zend_extensions.h and ensures that built extension is compatible
  with particular PHP build.
#]=============================================================================]

message(STATUS "")
message(STATUS "")
message(STATUS "Configuring Zend Engine")
message(STATUS "=======================")
message(STATUS "")

include(cmake/Version.cmake)

project(
  PHP_ZEND
  VERSION ${PHP_ZEND_VERSION}
  #SPDX_LICENSE "Zend-2.0"
  DESCRIPTION "Zend Engine library"
  HOMEPAGE_URL "https://www.php.net"
  LANGUAGES C
)

# Enable Assembly language dialect.
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  if(CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "(ARM|arm|aarch64)")
    enable_language(ASM_MARMASM)
  else()
    enable_language(ASM_MASM)
  endif()
else()
  enable_language(ASM)
endif()

include(CheckIncludeFiles)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(PHP/AddCustomCommand)
include(PHP/SearchLibraries)

################################################################################
# Configuration.
################################################################################

cmake_dependent_option(
  PHP_ZEND_FIBER_ASM
  "Enable the use of Boost fiber assembly files"
  ON
  [[NOT CMAKE_SYSTEM_NAME STREQUAL "Windows"]]
  ON
)
mark_as_advanced(PHP_ZEND_FIBER_ASM)

cmake_dependent_option(
  PHP_ZEND_GLOBAL_REGISTER_VARIABLES
  "Enable global register variables"
  ON
  [[NOT CMAKE_SYSTEM_NAME STREQUAL "Windows"]]
  OFF
)
mark_as_advanced(PHP_ZEND_GLOBAL_REGISTER_VARIABLES)

if(NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(
    CACHE{PHP_ZEND_MAX_EXECUTION_TIMERS}
    TYPE STRING
    HELP "Enable Zend max execution timers"
    VALUE "auto"
  )
  mark_as_advanced(PHP_ZEND_MAX_EXECUTION_TIMERS)
  set_property(
    CACHE PHP_ZEND_MAX_EXECUTION_TIMERS
    PROPERTY STRINGS "auto" "ON" "OFF"
  )
endif()

cmake_dependent_option(
  PHP_ZEND_SIGNALS
  "Enable Zend signal handling"
  ON
  [[NOT CMAKE_SYSTEM_NAME STREQUAL "Windows"]]
  OFF
)
mark_as_advanced(PHP_ZEND_SIGNALS)

################################################################################
# Add library.
################################################################################

add_library(zend OBJECT)
add_library(Zend::Zend ALIAS zend)

target_sources(
  zend
  PRIVATE
    Optimizer/block_pass.c
    Optimizer/compact_literals.c
    Optimizer/compact_vars.c
    Optimizer/dce.c
    Optimizer/dfa_pass.c
    Optimizer/escape_analysis.c
    Optimizer/nop_removal.c
    Optimizer/optimize_func_calls.c
    Optimizer/optimize_temp_vars_5.c
    Optimizer/pass1.c
    Optimizer/pass3.c
    Optimizer/sccp.c
    Optimizer/scdf.c
    Optimizer/zend_call_graph.c
    Optimizer/zend_cfg.c
    Optimizer/zend_dfg.c
    Optimizer/zend_dump.c
    Optimizer/zend_func_info.c
    Optimizer/zend_inference.c
    Optimizer/zend_optimizer.c
    Optimizer/zend_ssa.c
    zend_alloc.c
    zend_API.c
    zend_ast.c
    zend_atomic.c
    zend_attributes.c
    zend_attributes.stub.php
    zend_builtin_functions.c
    zend_builtin_functions.stub.php
    zend_call_stack.c
    zend_closures.c
    zend_closures.stub.php
    zend_compile.c
    zend_constants.c
    zend_constants.stub.php
    zend_cpuinfo.c
    zend_default_classes.c
    zend_dtrace.c
    zend_enum.c
    zend_enum.stub.php
    zend_exceptions.c
    zend_exceptions.stub.php
    zend_execute_API.c
    zend_execute.c
    zend_extensions.c
    zend_fibers.c
    zend_fibers.stub.php
    zend_float.c
    zend_frameless_function.c
    zend_gc.c
    $<$<NOT:$<PLATFORM_ID:Windows>>:zend_gdb.c>
    zend_generators.c
    zend_generators.stub.php
    zend_hash.c
    zend_highlight.c
    zend_hrtime.c
    zend_inheritance.c
    zend_ini_parser.c
    zend_ini_scanner.c
    zend_ini.c
    zend_interfaces.c
    zend_interfaces.stub.php
    zend_iterators.c
    zend_language_parser.c
    zend_language_scanner.c
    zend_lazy_objects.c
    zend_list.c
    zend_llist.c
    $<$<NOT:$<PLATFORM_ID:Windows>>:zend_max_execution_timer.c>
    zend_multibyte.c
    zend_object_handlers.c
    zend_objects_API.c
    zend_objects.c
    zend_observer.c
    zend_opcode.c
    zend_operators.c
    zend_property_hooks.c
    zend_ptr_stack.c
    $<$<NOT:$<PLATFORM_ID:Windows>>:zend_signal.c>
    zend_smart_str.c
    zend_sort.c
    zend_stack.c
    zend_stream.c
    zend_string.c
    zend_strtod.c
    zend_system_id.c
    zend_variables.c
    zend_virtual_cwd.c
    zend_vm_opcodes.c
    zend_weakrefs.c
    zend_weakrefs.stub.php
    zend.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        Optimizer/zend_call_graph.h
        Optimizer/zend_cfg.h
        Optimizer/zend_dfg.h
        Optimizer/zend_dump.h
        Optimizer/zend_func_info.h
        Optimizer/zend_inference.h
        Optimizer/zend_optimizer.h
        Optimizer/zend_ssa.h
        Optimizer/zend_worklist.h
        zend_alloc_sizes.h
        zend_alloc.h
        zend_API.h
        zend_arena.h
        zend_ast.h
        zend_atomic.h
        zend_attributes_arginfo.h
        zend_attributes.h
        zend_bitset.h
        zend_build.h
        zend_builtin_functions_arginfo.h
        zend_builtin_functions.h
        zend_call_stack.h
        zend_closures_arginfo.h
        zend_closures.h
        zend_compile.h
        $<$<PLATFORM_ID:Windows>:${CMAKE_CURRENT_SOURCE_DIR}/zend_config.w32.h>
        zend_constants_arginfo.h
        zend_constants.h
        zend_cpuinfo.h
        zend_dtrace.h
        zend_enum_arginfo.h
        zend_enum.h
        zend_errors.h
        zend_exceptions_arginfo.h
        zend_exceptions.h
        zend_execute.h
        zend_extensions.h
        zend_fibers_arginfo.h
        zend_fibers.h
        zend_float.h
        zend_frameless_function.h
        zend_gc.h
        zend_gdb.h
        zend_generators_arginfo.h
        zend_generators.h
        zend_globals_macros.h
        zend_globals.h
        zend_hash.h
        zend_highlight.h
        zend_hrtime.h
        zend_inheritance.h
        zend_ini_parser.h
        zend_ini_scanner_defs.h
        zend_ini_scanner.h
        zend_ini.h
        zend_interfaces_arginfo.h
        zend_interfaces.h
        zend_iterators.h
        zend_language_parser.h
        zend_language_scanner_defs.h
        zend_language_scanner.h
        zend_lazy_objects.h
        zend_list.h
        zend_llist.h
        zend_long.h
        zend_map_ptr.h
        zend_max_execution_timer.h
        zend_mmap.h
        zend_modules.h
        zend_multibyte.h
        zend_multiply.h
        zend_object_handlers.h
        zend_objects_API.h
        zend_objects.h
        zend_observer.h
        zend_operators.h
        zend_portability.h
        zend_property_hooks.h
        zend_ptr_stack.h
        zend_range_check.h
        zend_signal.h
        zend_simd.h
        zend_smart_str_public.h
        zend_smart_str.h
        zend_smart_string_public.h
        zend_smart_string.h
        zend_sort.h
        zend_stack.h
        zend_stream.h
        zend_string.h
        zend_strtod_int.h
        zend_strtod.h
        zend_system_id.h
        zend_type_info.h
        zend_types.h
        zend_variables.h
        zend_verify_type_inference.h
        zend_virtual_cwd.h
        zend_vm_def.h
        zend_vm_execute.h
        zend_vm_handlers.h
        zend_vm_opcodes.h
        zend_vm_trace_handlers.h
        zend_vm_trace_lines.h
        zend_vm_trace_map.h
        zend_vm.h
        zend_weakrefs_arginfo.h
        zend_weakrefs.h
        zend.h
  PUBLIC
    FILE_SET generated
      TYPE HEADERS
      BASE_DIRS ${CMAKE_CURRENT_BINARY_DIR}
      FILES
        $<$<NOT:$<PLATFORM_ID:Windows>>:${CMAKE_CURRENT_BINARY_DIR}/zend_config.h>
)

target_link_libraries(zend PRIVATE PHP::config)

target_include_directories(
  zend
  INTERFACE
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_compile_definitions(
  zend
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE
  PUBLIC
    $<$<PLATFORM_ID:Windows>:LIBZEND_EXPORTS>
)

set_target_properties(
  zend
  PROPERTIES
    VERSION ${PHP_ZEND_VERSION}
    ZEND_EXTENSION_API_NO ${PHP_ZEND_VERSION_EXTENSION_API_NO}
    ZEND_MODULE_API_NO ${PHP_ZEND_VERSION_MODULE_API_NO}
)

################################################################################
# Add usage requirements to PHP interface targets.
################################################################################

target_link_libraries(php_config INTERFACE $<COMPILE_ONLY:Zend::Zend>)
target_link_libraries(php_sapi INTERFACE Zend::Zend)
target_sources(php_sapi INTERFACE $<TARGET_OBJECTS:Zend::Zend>)

################################################################################
# TSRM (Thread Safe Resource Manager) is a separate directory in php-src as it
# was once a standalone project. Ideally, it should be moved into Zend Engine at
# some point.
################################################################################

target_sources(
  zend
  PRIVATE
    $<$<PLATFORM_ID:Windows>:${CMAKE_CURRENT_SOURCE_DIR}/../TSRM/tsrm_win32.c>
    ${CMAKE_CURRENT_SOURCE_DIR}/../TSRM/TSRM.c
  PUBLIC
    FILE_SET tsrm
      TYPE HEADERS
      BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/../TSRM
      FILES
        $<$<PLATFORM_ID:Windows>:${CMAKE_CURRENT_SOURCE_DIR}/../TSRM/tsrm_win32.h>
        ${CMAKE_CURRENT_SOURCE_DIR}/../TSRM/TSRM.h
)

target_include_directories(
  zend
  INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../TSRM>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${PHP_INCLUDE_PREFIX}/TSRM>
)

target_compile_definitions(zend PUBLIC $<$<PLATFORM_ID:Windows>:TSRM_EXPORTS>)

install(
  TARGETS zend
  FILE_SET tsrm
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PHP_INCLUDE_PREFIX}/TSRM
)

################################################################################
# Configuration checks.
################################################################################

check_include_files(cpuid.h PHP_ZEND_HAVE_CPUID_H)
set(HAVE_CPUID_H ${PHP_ZEND_HAVE_CPUID_H})

check_include_files(libproc.h PHP_ZEND_HAVE_LIBPROC_H)
set(HAVE_LIBPROC_H ${PHP_ZEND_HAVE_LIBPROC_H})

check_symbol_exists(
  clock_gettime_nsec_np
  time.h
  PHP_ZEND_HAVE_CLOCK_GETTIME_NSEC_NP
)
set(HAVE_CLOCK_GETTIME_NSEC_NP ${PHP_ZEND_HAVE_CLOCK_GETTIME_NSEC_NP})

check_symbol_exists(getpid unistd.h PHP_ZEND_HAVE_GETPID)
set(HAVE_GETPID ${PHP_ZEND_HAVE_GETPID})

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(gettid unistd.h PHP_ZEND_HAVE_GETTID)
  set(HAVE_GETTID ${PHP_ZEND_HAVE_GETTID})
cmake_pop_check_state()

check_symbol_exists(kill signal.h PHP_ZEND_HAVE_KILL)
set(HAVE_KILL ${PHP_ZEND_HAVE_KILL})

check_symbol_exists(mempcpy string.h PHP_ZEND_HAVE_MEMPCPY)
set(HAVE_MEMPCPY ${PHP_ZEND_HAVE_MEMPCPY})

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(mremap sys/mman.h PHP_ZEND_HAVE_MREMAP)
  set(HAVE_MREMAP ${PHP_ZEND_HAVE_MREMAP})
cmake_pop_check_state()

block(PROPAGATE HAVE_PTHREAD_ATTR_GET_NP)
  set(headers pthread.h)

  # BSD-based systems have pthread_attr_get_np in pthread_np.h.
  check_include_files(pthread_np.h PHP_ZEND_HAVE_PTHREAD_NP_H)
  if(PHP_ZEND_HAVE_PTHREAD_NP_H)
    list(APPEND headers "pthread_np.h")
  endif()

  check_symbol_exists(
    pthread_attr_get_np
    "${headers}"
    PHP_ZEND_HAVE_PTHREAD_ATTR_GET_NP
  )
  set(HAVE_PTHREAD_ATTR_GET_NP ${PHP_ZEND_HAVE_PTHREAD_ATTR_GET_NP})
endblock()

check_symbol_exists(
  pthread_attr_getstack
  pthread.h
  PHP_ZEND_HAVE_PTHREAD_ATTR_GETSTACK
)
set(HAVE_PTHREAD_ATTR_GETSTACK ${PHP_ZEND_HAVE_PTHREAD_ATTR_GETSTACK})

check_symbol_exists(
  pthread_get_stackaddr_np
  pthread.h
  PHP_ZEND_HAVE_PTHREAD_GET_STACKADDR_NP
)
set(HAVE_PTHREAD_GET_STACKADDR_NP ${PHP_ZEND_HAVE_PTHREAD_GET_STACKADDR_NP})

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(
    pthread_getattr_np
    pthread.h
    PHP_ZEND_HAVE_PTHREAD_GETATTR_NP
  )
  set(HAVE_PTHREAD_GETATTR_NP ${PHP_ZEND_HAVE_PTHREAD_GETATTR_NP})
cmake_pop_check_state()

check_symbol_exists(
  pthread_stackseg_np
  pthread.h
  PHP_ZEND_HAVE_PTHREAD_STACKSEG_NP
)
set(HAVE_PTHREAD_STACKSEG_NP ${PHP_ZEND_HAVE_PTHREAD_STACKSEG_NP})

check_symbol_exists(strnlen string.h PHP_ZEND_HAVE_STRNLEN)
set(HAVE_STRNLEN ${PHP_ZEND_HAVE_STRNLEN})

# Check for sigsetjmp(). It can be a function or defined as a macro. Note, that
# POSIX.1-2001-compliant systems should have it. On Windows the setjmp() is
# used instead.
if(NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
  check_symbol_exists(sigsetjmp setjmp.h PHP_ZEND_HAVE_SIGSETJMP)
  if(NOT PHP_ZEND_HAVE_SIGSETJMP)
    check_symbol_exists(setjmp setjmp.h PHP_ZEND_HAVE_SETJMP)
  endif()
  if(NOT PHP_ZEND_HAVE_SIGSETJMP AND NOT PHP_ZEND_HAVE_SETJMP)
    message(
      FATAL_ERROR
      "Required function sigsetjmp()/setjmp() not found in <setjmp.h>. Please "
      "ensure the target system is compliant with POSIX.1-2001 standard or "
      "later and the <setjmp.h> header is available on the system."
    )
  endif()
endif()

# Check for Solaris/illumos process mapping.
php_search_libraries(
  SYMBOL Pgrab
  HEADERS libproc.h
  LIBRARIES proc
  RESULT_VARIABLE PHP_ZEND_HAVE_PGRAB
  TARGET zend PRIVATE
)

include(cmake/CheckAsmGoto.cmake)
include(cmake/CheckCpuidCount.cmake)
include(cmake/CheckFloatPrecision.cmake)
include(cmake/CheckMMAlignment.cmake)
include(cmake/CheckPreserveNone.cmake)
include(cmake/CheckStackDirection.cmake)
include(cmake/CheckStrerrorR.cmake)
include(cmake/Fibers.cmake)
include(cmake/GenerateGrammar.cmake)
include(cmake/GlobalRegisterVariables.cmake)
include(cmake/MaxExecutionTimers.cmake)
include(cmake/Signals.cmake)

################################################################################
# Create files and set installation.
################################################################################

# Run the Zend/zend_vm_gen.php script.
#
# On 32-bit targets the zend_vm_gen.php script outputs deprecation warnings. As
# 32-bit targets are not considered development oriented environments, where the
# files need to be regenerated, executing this script is skipped.
# See: https://github.com/php/php-src/issues/15899
if(NOT CMAKE_SIZEOF_VOID_P EQUAL 4)
  php_add_custom_command(
    zend_generate_vm
    OUTPUT
      ${CMAKE_CURRENT_SOURCE_DIR}/zend_vm_execute.h
      ${CMAKE_CURRENT_SOURCE_DIR}/zend_vm_handlers.h
      ${CMAKE_CURRENT_SOURCE_DIR}/zend_vm_opcodes.c
      ${CMAKE_CURRENT_SOURCE_DIR}/zend_vm_opcodes.h
    DEPENDS
      ${CMAKE_CURRENT_SOURCE_DIR}/zend_vm_def.h
      ${CMAKE_CURRENT_SOURCE_DIR}/zend_vm_execute.skl
      ${CMAKE_CURRENT_SOURCE_DIR}/zend_vm_gen.php
    PHP_COMMAND
      ${CMAKE_CURRENT_SOURCE_DIR}/zend_vm_gen.php
    COMMENT "[Zend] Regenerating zend_vm_execute.h, zend_vm_handlers.h and zend_vm_opcodes.{h,c}"
    VERBATIM
  )
endif()

configure_file(cmake/zend_config.h.in CMakeFiles/zend_config.h)

if(NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
  cmake_path(
    RELATIVE_PATH
    CMAKE_CURRENT_BINARY_DIR
    BASE_DIRECTORY ${CMAKE_BINARY_DIR}
    OUTPUT_VARIABLE relativeDir
  )
  message(STATUS "Creating ${relativeDir}/zend_config.h")
  file(
    CONFIGURE
    OUTPUT zend_config.h
    CONTENT "#include <php_config.h>\n"
  )
endif()

install(
  TARGETS zend
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET HEADERS
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PHP_INCLUDE_PREFIX}/Zend
  FILE_SET generated
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PHP_INCLUDE_PREFIX}/Zend
)
