include(CheckCCompilerFlag)
include(CheckCSourceCompiles)
include(CheckIncludeFile)
include(CheckSymbolExists)
include(CMakePushCheckState)

################################################################################
# Configure Zend.
################################################################################

if(PHP_DEBUG OR PHP_DEBUG_ASSERTIONS)
  set(ZEND_DEBUG 1 CACHE INTERNAL "Whether to enable debugging")
else()
  set(ZEND_DEBUG 0 CACHE INTERNAL "Whether to enable debugging")
endif()

################################################################################
# Check Zend configuration.
################################################################################

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
  int main(void) {
    unsigned eax, ebx, ecx, edx;
    __cpuid_count(0, 0, eax, ebx, ecx, edx);

    return 0;
  }
" HAVE_CPUID_COUNT)

# Check if dlsym() needs underscore.
include(Zend/CheckDlsym)

# Check which inline keyword compiler supports.
include(Zend/CheckInline)

# Check MM alignment.
include(Zend/CheckMMAlignment)

# Check for global register variables.
if(ZEND_GCC_GLOBAL_REGS)
  include(Zend/CheckGccGlobalRegisterVars)
endif()

# Check if stack grows downward.
include(Zend/CheckStackLimit)

# Check float precision.
include(Zend/CheckFloatPrecision)

# Check Zend signals.
include(Zend/CheckZendSignals)

# Check Zend max execution timers.
include(Zend/CheckZendMaxExecutionTimers)

################################################################################
# Zend library.
################################################################################

add_library(zend STATIC
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
  zend.c
  zend_API.c
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
)

target_link_libraries(zend PRIVATE PHP::configuration)

target_include_directories(
  zend
  PRIVATE ${CMAKE_SOURCE_DIR}
          ${CMAKE_BINARY_DIR}
          ${CMAKE_SOURCE_DIR}/main
          ${CMAKE_BINARY_DIR}/main
  INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}
            ${CMAKE_CURRENT_BINARY_DIR}
            ${CMAKE_SOURCE_DIR}/TSRM
)

target_link_libraries(zend PRIVATE php_tsrm)

target_compile_definitions(zend PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

if(ZEND_MAX_EXECUTION_TIMERS_LIBRARIES)
  target_link_libraries(zend PRIVATE ${ZEND_MAX_EXECUTION_TIMERS_LIBRARIES})
endif()

# TODO: zend_config.h (or its parent php_config.h) isn't included in some zend_*
# files, therefore we need to add compilation definitions also like this here.
if(PHP_ZTS)
  target_compile_definitions(zend PRIVATE ZTS)
endif()

if(ZEND_SIGNALS)
  target_compile_definitions(zend PRIVATE ZEND_SIGNALS)
endif()

if(ZEND_MAX_EXECUTION_TIMERS)
  target_compile_definitions(zend PRIVATE ZEND_MAX_EXECUTION_TIMERS)
endif()

################################################################################
# Generate Zend lexers and parsers.
################################################################################

if(BISON_FOUND)
  bison_target(zend_ini_parser zend_ini_parser.y "${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_parser.c"
    COMPILE_FLAGS "-v -d"
    DEFINES_FILE "${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_parser.h"
  )

  bison_target(zend_language_parser zend_language_parser.y "${CMAKE_CURRENT_SOURCE_DIR}/zend_language_parser.c"
    COMPILE_FLAGS "-v -d"
    DEFINES_FILE "${CMAKE_CURRENT_SOURCE_DIR}/zend_language_parser.h"
  )

  # Tweak zendparse to be exported through ZEND_API. This has to be revisited once
  # bison supports foreign skeletons and that bison version is used. Read
  # https://git.savannah.gnu.org/cgit/bison.git/tree/data/README.md for more.
  file(
    GENERATE
    OUTPUT CMakeFiles/PatchZendLanguageParserFiles.cmake
    CONTENT "
      file(READ \"${CMAKE_CURRENT_SOURCE_DIR}/zend_language_parser.h\" file_contents)
      string(REPLACE \"int zendparse\" \"ZEND_API int zendparse\" file_contents \"\${file_contents}\")
      file(WRITE \"${CMAKE_CURRENT_SOURCE_DIR}/zend_language_parser.h\" \"\${file_contents}\")
      file(READ \"${CMAKE_CURRENT_SOURCE_DIR}/zend_language_parser.c\" file_contents)
      string(REPLACE \"int zendparse\" \"ZEND_API int zendparse\" file_contents \"\${file_contents}\")
      file(WRITE \"${CMAKE_CURRENT_SOURCE_DIR}/zend_language_parser.c\" \"\${file_contents}\")
    "
  )
  add_custom_target(
    zend_patch_language_parser_files
    COMMAND ${CMAKE_COMMAND} -P "CMakeFiles/PatchZendLanguageParserFiles.cmake"
    DEPENDS ${BISON_zend_language_parser_OUTPUTS}
    COMMENT "Patching Zend language parser files"
  )

  add_dependencies(zend zend_patch_language_parser_files)
endif()

if(RE2C_FOUND)
  re2c_target(
    NAME zend_language_scanner
    INPUT "${CMAKE_CURRENT_SOURCE_DIR}/zend_language_scanner.l"
    OUTPUT "${CMAKE_CURRENT_SOURCE_DIR}/zend_language_scanner.c"
    OPTIONS "--no-generation-date --case-inverted -cbdFt \"${CMAKE_CURRENT_SOURCE_DIR}/zend_language_scanner_defs.h\""
  )

  re2c_target(
    NAME zend_ini_scanner
    INPUT "${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_scanner.l"
    OUTPUT "${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_scanner.c"
    OPTIONS "--no-generation-date --case-inverted -cbdFt \"${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_scanner_defs.h\""
  )
endif()

################################################################################
# Configure fibers.
################################################################################

# Check for fibers support.
include(Zend/CheckFibers)

if(ZEND_FIBER_ASM)
  add_library(zend_asm STATIC
    "asm/make_${FIBER_ASM_FILE}.S"
    "asm/jump_${FIBER_ASM_FILE}.S"
  )

  target_link_libraries(zend_asm PRIVATE PHP::configuration)

  # The asm file can't see macro from defined constant, workaround this via cflag.
  if(SYSCALL_SHADOW_STACK_EXISTS)
    message(STATUS "Adding compile definition for Zend: SHADOW_STACK_SYSCALL")
    target_compile_definitions(zend_asm PRIVATE SHADOW_STACK_SYSCALL=1)
  endif()

  target_link_libraries(zend PRIVATE zend_asm)
endif()

################################################################################
# Compilation flags. TODO - move this to global level.
################################################################################

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  target_compile_options(zend BEFORE PRIVATE -Wall -Wextra -Wno-unused-parameter -Wno-sign-compare)
endif()

# Check if compiler supports -Wno-clobbered (only GCC).
check_c_compiler_flag(-Wno-clobbered HAVE_WNO_CLOBBERED)
if(HAVE_WNO_CLOBBERED)
  target_compile_options(zend BEFORE PRIVATE -Wno-clobbered)
endif()

# Check for support for implicit fallthrough level 1, also add after previous
# CFLAGS as level 3 is enabled in -Wextra.
check_c_compiler_flag(-Wimplicit-fallthrough=1 HAVE_WIMPLICIT_FALLTHROUGH)
if(HAVE_WIMPLICIT_FALLTHROUGH)
  target_compile_options(zend PRIVATE -Wimplicit-fallthrough=1)
endif()

check_c_compiler_flag(-Wduplicated-cond HAVE_WDUPLICATED_COND)
if(HAVE_WDUPLICATED_COND)
  target_compile_options(zend BEFORE PRIVATE -Wduplicated-cond)
endif()

check_c_compiler_flag(-Wlogical-op HAVE_WLOGICAL_OP)
if(HAVE_WLOGICAL_OP)
  target_compile_options(zend BEFORE PRIVATE -Wlogical-op)
endif()

check_c_compiler_flag(-Wformat-truncation HAVE_WFORMAT_TRUNCATION)
if(HAVE_WFORMAT_TRUNCATION)
  target_compile_options(zend BEFORE PRIVATE -Wformat-truncation)
endif()

check_c_compiler_flag(-Wstrict-prototypes HAVE_WSTRICT_PROTOTYPES)
if(HAVE_WSTRICT_PROTOTYPES)
  target_compile_options(zend BEFORE PRIVATE -Wstrict-prototypes)
endif()

check_c_compiler_flag(-fno-common HAVE_FNO_COMMON)
if(HAVE_FNO_COMMON)
  target_compile_options(zend BEFORE PRIVATE -fno-common)
endif()

if(ZEND_DEBUG)
  target_compile_options(zend PRIVATE -g)
endif()

################################################################################
# Create files and set installation.
################################################################################

message(STATUS "Creating Zend/zend_config.h")
file(WRITE ${CMAKE_BINARY_DIR}/Zend/zend_config.h "#include <../main/php_config.h>\n")

file(GLOB_RECURSE _zend_headers "${PROJECT_SOURCE_DIR}/Zend/*.h")
list(APPEND _zend_headers "${CMAKE_CURRENT_BINARY_DIR}/zend_config.h")
install(FILES ${_zend_headers} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/Zend)

# TODO: Duplicate installation step.
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
