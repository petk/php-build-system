include(CheckCCompilerFlag)
include(CheckCSourceCompiles)
include(CheckIncludeFile)
include(CheckSymbolExists)
include(CMakePushCheckState)

message(STATUS "Building Zend Engine library")

check_include_file(cpuid.h HAVE_CPUID_H)

check_symbol_exists(getpid "unistd.h" HAVE_GETPID)
check_symbol_exists(kill "signal.h" HAVE_KILL)
check_symbol_exists(sigsetjmp "setjmp.h" HAVE_SIGSETJMP)

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(pthread_getattr_np "pthread.h" HAVE_PTHREAD_GETATTR_NP)
cmake_pop_check_state()

check_symbol_exists(pthread_attr_get_np "pthread.h" HAVE_PTHREAD_ATTR_GET_NP)
check_symbol_exists(pthread_get_stackaddr_np "pthread.h" HAVE_PTHREAD_GET_STACKADDR_NP)
check_symbol_exists(pthread_attr_getstack "pthread.h" HAVE_PTHREAD_ATTR_GETSTACK)
check_symbol_exists(pthread_stackseg_np "pthread.h" HAVE_PTHREAD_STACKSEG_NP)

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(gettid "unistd.h" HAVE_GETTID)
cmake_pop_check_state()

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(mremap "sys/mman.h" HAVE_MREMAP)
cmake_pop_check_state()

message(STATUS "Checking whether __cpuid_count is available")
check_c_source_compiles("
  #include <cpuid.h>
  int main() {
    unsigned eax, ebx, ecx, edx;
    __cpuid_count(0, 0, eax, ebx, ecx, edx);

    return 0;
  }
" HAVE_CPUID_COUNT)

# Check if dlsym() needs underscore.
include(PHPCheckDlsym)

# Check which inline keyword compiler supports.
include(PHPCheckInline)

message(STATUS "Checking if target system is Darwin")
string(TOLOWER "${CMAKE_HOST_SYSTEM_NAME}" host_os)
if(${host_os} MATCHES ".*darwin.*")
  message(STATUS "yes")
  set(DARWIN 1 CACHE INTERNAL "Define if the target system is darwin")
else()
  message(STATUS "no")
endif()

# Check MM alignment.
include(PHPCheckMMAlignment)

# Check for global register variables.
if(ZEND_GCC_GLOBAL_REGS)
  include(PHPCheckGccGlobalRegisterVars)
endif()

# Check if stack grows downward.
include(PHPCheckStackLimit)

# Check float precision.
include(PHPCheckFloatPrecision)

# Check Zend signals.
include(PHPCheckZendSignals)

# Check Zend max execution timers.
include(PHPCheckZendMaxExecutionTimers)

bison_target(ZendIniParser zend_ini_parser.y "${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_parser.c"
  COMPILE_FLAGS "-v -d"
  DEFINES_FILE "${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_parser.h"
)

bison_target(ZendLanguageParser zend_language_parser.y "${CMAKE_CURRENT_SOURCE_DIR}/zend_language_parser.c"
  COMPILE_FLAGS "-v -d"
  DEFINES_FILE "${CMAKE_CURRENT_SOURCE_DIR}/zend_language_parser.h"
)

# Tweak zendparse to be exported through ZEND_API. This has to be revisited once
# bison supports foreign skeletons and that bison version is used. Read
# https://git.savannah.gnu.org/cgit/bison.git/tree/data/README.md for more.
add_custom_target(
  patch_zend_language_parser_files
  COMMAND ${CMAKE_COMMAND} -P "${CMAKE_SOURCE_DIR}/cmake/modules/Zend/patch_zend_language_parser_file.cmake"
  DEPENDS ${BISON_ZendLanguageParser_OUTPUTS}
  COMMENT "Patching Zend language parser files"
)

re2c_target(
  NAME zendLanguageScanner
  INPUT "${CMAKE_CURRENT_SOURCE_DIR}/zend_language_scanner.l"
  OUTPUT "${CMAKE_CURRENT_SOURCE_DIR}/zend_language_scanner.c"
  OPTIONS "--no-generation-date --case-inverted -cbdFt \"${CMAKE_CURRENT_SOURCE_DIR}/zend_language_scanner_defs.h\""
)

re2c_target(
  NAME zendIniScanner
  INPUT "${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_scanner.l"
  OUTPUT "${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_scanner.c"
  OPTIONS "--no-generation-date --case-inverted -cbdFt \"${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_scanner_defs.h\""
)

message(STATUS "Creating Zend/zend_config.h")
file(WRITE zend_config.h "#include <../main/php_config.h>\n")

add_library(Zend STATIC
  zend_language_parser.c
  zend_language_scanner.c
  zend_ini_parser.c
  zend_ini_scanner.c
  zend_alloc.c
  zend_call_stack.c
  zend_compile.c
  zend_constants.c
  zend_dtrace.c
  zend_execute_API.c
  zend_highlight.c
  zend_llist.c
  zend_vm_opcodes.c
  zend_opcode.c
  zend_operators.c
  zend_ptr_stack.c
  zend_stack.c
  zend_variables.c
  zend.c zend_API.c
  zend_extensions.c
  zend_hash.c
  zend_list.c
  zend_builtin_functions.c
  zend_attributes.c
  zend_execute.c
  zend_ini.c
  zend_sort.c
  zend_multibyte.c
  zend_stream.c
  zend_iterators.c
  zend_interfaces.c
  zend_exceptions.c
  zend_strtod.c
  zend_gc.c
  zend_closures.c
  zend_weakrefs.c
  zend_float.c
  zend_string.c
  zend_signal.c
  zend_generators.c
  zend_virtual_cwd.c
  zend_ast.c
  zend_objects.c
  zend_object_handlers.c
  zend_objects_API.c
  zend_default_classes.c
  zend_inheritance.c
  zend_smart_str.c
  zend_cpuinfo.c
  zend_gdb.c
  zend_observer.c
  zend_system_id.c
  zend_enum.c
  zend_fibers.c
  zend_atomic.c
  zend_max_execution_timer.c
  zend_hrtime.c
  Optimizer/zend_optimizer.c
  Optimizer/pass1.c
  Optimizer/pass3.c
  Optimizer/optimize_func_calls.c
  Optimizer/block_pass.c
  Optimizer/optimize_temp_vars_5.c
  Optimizer/nop_removal.c
  Optimizer/compact_literals.c
  Optimizer/zend_cfg.c
  Optimizer/zend_dfg.c
  Optimizer/dfa_pass.c
  Optimizer/zend_ssa.c
  Optimizer/zend_inference.c
  Optimizer/zend_func_info.c
  Optimizer/zend_call_graph.c
  Optimizer/sccp.c
  Optimizer/scdf.c
  Optimizer/dce.c
  Optimizer/escape_analysis.c
  Optimizer/compact_vars.c
  Optimizer/zend_dump.c
  ${BISON_ZendIniParser_OUTPUTS}
)

add_dependencies(Zend patch_zend_language_parser_files)

target_include_directories(
  Zend
  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}
          ${CMAKE_SOURCE_DIR}
  INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(Zend PRIVATE TSRM)

target_compile_definitions(Zend PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

# Check for fibers support.
include(PHPCheckFibers)

if(ZEND_FIBER_ASM)
  add_library(ZendAsm STATIC
    "asm/make_${FIBER_ASM_FILE}.S"
    "asm/jump_${FIBER_ASM_FILE}.S"
  )

  # The asm file can't see macro from defined constant, workaround this via cflag.
  if(SYSCALL_SHADOW_STACK_EXISTS)
    message(STATUS "Adding compile definition for Zend: SHADOW_STACK_SYSCALL")
    target_compile_definitions(ZendAsm PRIVATE SHADOW_STACK_SYSCALL=1)
  endif()

  target_link_libraries(Zend PRIVATE ZendAsm)
endif()

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  target_compile_options(Zend BEFORE PRIVATE -Wall -Wextra -Wno-unused-parameter -Wno-sign-compare)
endif()

# Check if compiler supports -Wno-clobbered (only GCC).
check_c_compiler_flag(-Wno-clobbered HAVE_WNO_CLOBBERED)
if(HAVE_WNO_CLOBBERED)
  target_compile_options(Zend BEFORE PRIVATE -Wno-clobbered)
  unset(HAVE_WNO_CLOBBERED)
endif()

# Check for support for implicit fallthrough level 1, also add after previous
# CFLAGS as level 3 is enabled in -Wextra.
check_c_compiler_flag(-Wimplicit-fallthrough=1 HAVE_WIMPLICIT_FALLTHROUGH)
if(HAVE_WIMPLICIT_FALLTHROUGH)
  target_compile_options(Zend PRIVATE -Wimplicit-fallthrough=1)
  unset(HAVE_WIMPLICIT_FALLTHROUGH)
endif()

check_c_compiler_flag(-Wduplicated-cond HAVE_WDUPLICATED_COND)
if(HAVE_WDUPLICATED_COND)
  target_compile_options(Zend BEFORE PRIVATE -Wduplicated-cond)
  unset(HAVE_WDUPLICATED_COND)
endif()

check_c_compiler_flag(-Wlogical-op HAVE_WLOGICAL_OP)
if(HAVE_WLOGICAL_OP)
  target_compile_options(Zend BEFORE PRIVATE -Wlogical-op)
  unset(HAVE_WLOGICAL_OP)
endif()

check_c_compiler_flag(-Wformat-truncation HAVE_WFORMAT_TRUNCATION)
if(HAVE_WFORMAT_TRUNCATION)
  target_compile_options(Zend BEFORE PRIVATE -Wformat-truncation)
  unset(HAVE_WFORMAT_TRUNCATION)
endif()

check_c_compiler_flag(-Wstrict-prototypes HAVE_WSTRICT_PROTOTYPES)
if(HAVE_WSTRICT_PROTOTYPES)
  target_compile_options(Zend BEFORE PRIVATE -Wstrict-prototypes)
  unset(HAVE_WSTRICT_PROTOTYPES)
endif()

check_c_compiler_flag(-fno-common HAVE_FNO_COMMON)
if(HAVE_FNO_COMMON)
  target_compile_options(Zend BEFORE PRIVATE -fno-common)
  unset(HAVE_FNO_COMMON)
endif()

if(ZEND_DEBUG)
  target_compile_options(Zend PRIVATE -g)
endif()

# TODO: zend_config.h (or its parent php_config.h) isn't included in some zend_*
# files, therefore we need to add compilation definitions also like this here.
if(PHP_ZTS)
  target_compile_definitions(Zend PRIVATE ZTS)
endif()

if(ZEND_SIGNALS)
  target_compile_definitions(Zend PRIVATE ZEND_SIGNALS)
endif()

if(ZEND_MAX_EXECUTION_TIMERS)
  target_compile_definitions(Zend PRIVATE ZEND_MAX_EXECUTION_TIMERS)
endif()

file(GLOB_RECURSE _zend_headers "${PROJECT_SOURCE_DIR}/Zend/*.h")
install(FILES ${_zend_headers} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/Zend)

install(
  FILES
    Optimizer/zend_call_graph.h
    Optimizer/zend_cfg.h
    Optimizer/zend_dfg.h
    Optimizer/zend_dump.h
    Optimizer/zend_func_info.h
    Optimizer/zend_inference.h
    Optimizer/zend_optimizer.h
    Optimizer/zend_ssa.h
    DESTINATION
      ${CMAKE_INSTALL_INCLUDEDIR}/php/Zend/Optimizer
)
