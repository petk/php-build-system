#[=============================================================================[
Zend Engine.

## Targets

* OBJECT library `zend` (ALIAS `Zend::Zend`) holds all Zend Engine objects
  and compile properties.

## Target properties

CMake target properties for the `Zend::Zend` target:

* `VERSION`

  Zend Engine version as defined in the `Zend/zend.h` file.

* `ZEND_EXTENSION_API_NO`

  Custom target property with internal API version number for PHP extensions
  (dynamically loaded with the `extension` INI directive). This is the
  `ZEND_MODULE_API_NO` number from the `Zend/zend_modules.h` and ensures that
  built extension is compatible with particular PHP build.

* `ZEND_MODULE_API_NO`

  Custom target property with internal API version number for Zend extensions in
  PHP (dynamically loaded with the `zend_extension` INI directive), such as
  opcache, debuggers, profilers, etc. This is the `ZEND_EXTENSION_API_NO` number
  from the `Zend/zend_extensions.h` and ensures that built extension is
  compatible with particular PHP build.
#]=============================================================================]

message(STATUS "")
message(STATUS "")
message(STATUS "Configuring Zend Engine")
message(STATUS "=======================")
message(STATUS "")

include(cmake/Version.cmake)

project(
  Zend
  VERSION ${Zend_VERSION}
  DESCRIPTION "Zend Engine library"
  LANGUAGES C ASM
)

include(CheckIncludeFiles)
include(CheckSourceCompiles)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)
include(PHP/AddCustomCommand)
include(PHP/SearchLibraries)

################################################################################
# Configuration.
################################################################################

cmake_dependent_option(
  ZEND_FIBER_ASM
  "Enable the use of Boost fiber assembly files"
  ON
  [[NOT CMAKE_SYSTEM_NAME STREQUAL "Windows"]]
  ON
)
mark_as_advanced(ZEND_FIBER_ASM)

option(ZEND_GLOBAL_REGISTER_VARIABLES "Enable global register variables" ON)
mark_as_advanced(ZEND_GLOBAL_REGISTER_VARIABLES)

cmake_dependent_option(
  ZEND_SIGNALS
  "Enable Zend signal handling"
  ON
  [[NOT CMAKE_SYSTEM_NAME STREQUAL "Windows"]]
  OFF
)
mark_as_advanced(ZEND_SIGNALS)

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
        $<$<PLATFORM_ID:Windows>:zend_config.w32.h>
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
    VERSION ${Zend_VERSION}
    ZEND_EXTENSION_API_NO ${Zend_VERSION_EXTENSION_API_NO}
    ZEND_MODULE_API_NO ${Zend_VERSION_MODULE_API_NO}
)

################################################################################
# Add usage requirements to PHP interface targets.
################################################################################

# Cleaner COMPILE_ONLY generator expression is available in CMake >= 3.27.
if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.27)
  target_link_libraries(php_config INTERFACE $<COMPILE_ONLY:Zend::Zend>)
else()
  target_compile_definitions(
    php_config
    INTERFACE
      $<TARGET_PROPERTY:Zend::Zend,INTERFACE_COMPILE_DEFINITIONS>
  )
  target_compile_options(
    php_config
    INTERFACE
      $<TARGET_PROPERTY:Zend::Zend,INTERFACE_COMPILE_OPTIONS>
  )
  target_include_directories(
    php_config
    INTERFACE
      $<TARGET_PROPERTY:Zend::Zend,INTERFACE_INCLUDE_DIRECTORIES>
      $<TARGET_PROPERTY:Zend::Zend,INTERFACE_SYSTEM_INCLUDE_DIRECTORIES>
  )
endif()

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

check_include_files(cpuid.h HAVE_CPUID_H)
check_include_files(libproc.h HAVE_LIBPROC_H)

check_symbol_exists(clock_gettime_nsec_np "time.h" HAVE_CLOCK_GETTIME_NSEC_NP)
check_symbol_exists(getpid "unistd.h" HAVE_GETPID)

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(gettid "unistd.h" HAVE_GETTID)
cmake_pop_check_state()

check_symbol_exists(kill "signal.h" HAVE_KILL)
check_symbol_exists(mempcpy "string.h" HAVE_MEMPCPY)

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(mremap "sys/mman.h" HAVE_MREMAP)
cmake_pop_check_state()

# BSD-based systems have pthread_attr_get_np in pthread_np.h.
block()
  check_include_files(pthread_np.h _HAVE_PTHREAD_NP_H)

  if(_HAVE_PTHREAD_NP_H)
    set(headers "pthread_np.h")
  endif()

  list(APPEND headers pthread.h)

  check_symbol_exists(
    pthread_attr_get_np
    "${headers}"
    HAVE_PTHREAD_ATTR_GET_NP
  )
endblock()

check_symbol_exists(
  pthread_attr_getstack
  "pthread.h"
  HAVE_PTHREAD_ATTR_GETSTACK
)

check_symbol_exists(
  pthread_get_stackaddr_np
  "pthread.h"
  HAVE_PTHREAD_GET_STACKADDR_NP
)

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(pthread_getattr_np "pthread.h" HAVE_PTHREAD_GETATTR_NP)
cmake_pop_check_state()

check_symbol_exists(pthread_stackseg_np "pthread.h" HAVE_PTHREAD_STACKSEG_NP)

# Check for sigsetjmp(). It can be a function or defined as a macro. Note, that
# POSIX.1-2001-compliant systems should have it. On Windows the setjmp() is
# used instead.
if(NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
  check_symbol_exists(sigsetjmp "setjmp.h" _HAVE_SIGSETJMP)
  if(NOT _HAVE_SIGSETJMP)
    message(
      FATAL_ERROR
      "Required function sigsetjmp() not found in setjmp.h. Please ensure the "
      "target system is compliant with POSIX.1-2001 standard or later and the "
      "setjmp.h header is available on the system."
    )
  endif()
endif()

message(CHECK_START "Checking for asm goto support")
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_source_compiles(C [[
    int main(void)
    {
      #if defined(__x86_64__) || defined(__i386__)
        __asm__ goto("jmp %l0\n" :::: end);
      #elif defined(__aarch64__)
        __asm__ goto("b %l0\n" :::: end);
      #endif
      end:
        return 0;
    }
  ]] HAVE_ASM_GOTO)
cmake_pop_check_state()
if(HAVE_ASM_GOTO)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

message(CHECK_START "Checking whether __cpuid_count is available")
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_source_compiles(C [[
    #include <cpuid.h>
    int main(void)
    {
      unsigned eax, ebx, ecx, edx;
      __cpuid_count(0, 0, eax, ebx, ecx, edx);
      return 0;
    }
  ]] HAVE_CPUID_COUNT)
cmake_pop_check_state()
if(HAVE_CPUID_COUNT)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

# Check for Solaris/illumos process mapping.
php_search_libraries(
  Pgrab
  HEADERS libproc.h
  LIBRARIES proc
  TARGET zend PRIVATE
)

include(cmake/CheckFloatPrecision.cmake)

if(ZEND_GLOBAL_REGISTER_VARIABLES)
  include(cmake/CheckGlobalRegisterVariables.cmake)
endif()

include(cmake/CheckMMAlignment.cmake)
include(cmake/CheckStackDirection.cmake)
include(cmake/CheckStrerrorR.cmake)

################################################################################
# Zend signals.
################################################################################

message(CHECK_START "Checking whether to enable Zend signal handling")
check_symbol_exists(sigaction "signal.h" HAVE_SIGACTION)
if(HAVE_SIGACTION AND ZEND_SIGNALS)
  message(CHECK_PASS "yes")

  # zend_config.h (or its parent php_config.h) isn't included in some zend_*
  # files, therefore also compilation definition is added.
  target_compile_definitions(zend PUBLIC ZEND_SIGNALS)
else()
  set_property(CACHE ZEND_SIGNALS PROPERTY VALUE OFF)
  message(CHECK_FAIL "no")
endif()
add_feature_info(
  "Zend signals"
  ZEND_SIGNALS
  "signal handling for performance"
)

################################################################################
# Zend max execution timers.
################################################################################

include(cmake/MaxExecutionTimers.cmake)
if(TARGET Zend::MaxExecutionTimers)
  target_link_libraries(zend PUBLIC Zend::MaxExecutionTimers)
endif()

################################################################################
# Generate parser and lexer files.
################################################################################

include(cmake/GenerateGrammar.cmake)

################################################################################
# Configure fibers.
################################################################################

include(cmake/Fibers.cmake)
if(TARGET Zend::Fibers)
  target_link_libraries(zend PRIVATE Zend::Fibers)
endif()

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
    CONTENT "#include <../main/php_config.h>\n"
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
