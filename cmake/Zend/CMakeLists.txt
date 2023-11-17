include(CheckCCompilerFlag)
include(CheckCSourceCompiles)
include(CheckIncludeFile)
include(CheckSymbolExists)
include(CMakePushCheckState)
include(PHP/SearchLibraries)

################################################################################
# Zend engine configuration.
################################################################################

option(ZEND_GCC_GLOBAL_REGS "Enable GCC global register variables" ON)

option(ZEND_FIBER_ASM "Enable the use of boost fiber assembly files" ON)

option(ZEND_SIGNALS "Enable Zend signal handling" ON)

# TODO: Check if default value can be improved. Once cached variable is set, it
# can't be changed based on PHP_ZTS value on the second configuration run.
option(ZEND_MAX_EXECUTION_TIMERS "Enable Zend max execution timers" ${PHP_ZTS})

# TODO: Fix this better.
if(PHP_ZTS)
  set(ZTS 1 PARENT_SCOPE)
endif()

if(PHP_DEBUG OR PHP_DEBUG_ASSERTIONS)
  set(ZEND_DEBUG 1 CACHE INTERNAL "Whether to enable debugging")
else()
  set(ZEND_DEBUG 0 CACHE INTERNAL "Whether to enable debugging")
endif()

################################################################################
# Zend engine library.
################################################################################

add_library(zend STATIC
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
  zend_builtin_functions.c
  zend_call_stack.c
  zend_closures.c
  zend_compile.c
  zend_constants.c
  zend_cpuinfo.c
  zend_default_classes.c
  zend_dtrace.c
  zend_enum.c
  zend_exceptions.c
  zend_execute_API.c
  zend_execute.c
  zend_extensions.c
  zend_fibers.c
  zend_float.c
  zend_gc.c
  zend_gdb.c
  zend_generators.c
  zend_hash.c
  zend_highlight.c
  zend_hrtime.c
  zend_inheritance.c
  zend_ini_parser.c
  zend_ini_scanner.c
  zend_ini.c
  zend_interfaces.c
  zend_iterators.c
  zend_language_parser.c
  zend_language_scanner.c
  zend_list.c
  zend_llist.c
  zend_max_execution_timer.c
  zend_multibyte.c
  zend_object_handlers.c
  zend_objects_API.c
  zend_objects.c
  zend_observer.c
  zend_opcode.c
  zend_operators.c
  zend_ptr_stack.c
  zend_signal.c
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
  zend.c
)

add_library(Zend::Zend ALIAS zend)

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

target_link_libraries(zend PRIVATE PHP::TSRM)

target_compile_definitions(zend PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

################################################################################
# Zend engine configuration checks.
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

message(CHECK_START "Checking whether __cpuid_count is available")
check_c_source_compiles("
  #include <cpuid.h>
  int main(void) {
    unsigned eax, ebx, ecx, edx;
    __cpuid_count(0, 0, eax, ebx, ecx, edx);
    return 0;
  }
" HAVE_CPUID_COUNT)
if(HAVE_CPUID_COUNT)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

# Check Zend signals.
message(CHECK_START "Checking whether to enable Zend signal handling")
check_symbol_exists(sigaction "signal.h" HAVE_SIGACTION)
if(NOT HAVE_SIGACTION OR NOT ZEND_SIGNALS)
  message(CHECK_FAIL "no")
  set_property(CACHE ZEND_SIGNALS PROPERTY VALUE 0)
else()
  message(CHECK_PASS "yes")
  set_property(CACHE ZEND_SIGNALS PROPERTY VALUE 1)
endif()

# Check Zend max execution timers.
message(CHECK_START "Checking whether to enable Zend max execution timers")
if(ZEND_MAX_EXECUTION_TIMERS AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
  php_search_libraries(
    timer_create
    "time.h"
    HAVE_TIMER_CREATE
    TIMER_CREATE_LIBRARY
    LIBRARIES rt
  )

  if(NOT HAVE_TIMER_CREATE)
    set_property(CACHE ZEND_MAX_EXECUTION_TIMERS PROPERTY VALUE 0)
  else()
    if(TIMER_CREATE_LIBRARY)
      target_link_libraries(zend PRIVATE ${TIMER_CREATE_LIBRARY})
    endif()
  endif()

  if(ZEND_MAX_EXECUTION_TIMERS)
    set_property(CACHE ZEND_MAX_EXECUTION_TIMERS PROPERTY VALUE 1)
  endif()
else()
  set_property(CACHE ZEND_MAX_EXECUTION_TIMERS PROPERTY VALUE 0)
endif()
if(ZEND_MAX_EXECUTION_TIMERS)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

# Check if dlsym() needs underscore.
include(Zend/CheckDlsym)

# Check MM alignment.
include(Zend/CheckMMAlignment)

# Check for global register variables.
if(ZEND_GCC_GLOBAL_REGS)
  include(Zend/CheckGlobalRegisterVars)
endif()

# Check if stack grows downward.
include(Zend/CheckStackLimit)

# Check float precision.
include(Zend/CheckFloatPrecision)

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
# Generate Zend engine lexers and parsers.
################################################################################

if(BISON_FOUND)
  bison_target(zend_ini_parser zend_ini_parser.y "${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_parser.c"
    COMPILE_FLAGS "-Wall -v -d"
    DEFINES_FILE "${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_parser.h"
  )

  bison_target(zend_language_parser zend_language_parser.y "${CMAKE_CURRENT_SOURCE_DIR}/zend_language_parser.c"
    COMPILE_FLAGS "-Wall -v -d"
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
    COMMENT "[Zend] Patching Zend language parser files"
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
  target_sources(zend PRIVATE
    asm/jump_${FIBER_ASM_FILE}.S
    asm/make_${FIBER_ASM_FILE}.S
  )

  # The ASM files can't see macro from defined constant, workaround this via CFLAG.
  if(SHADOW_STACK_SYSCALL)
    target_compile_definitions(zend PRIVATE
      $<$<COMPILE_LANGUAGE:ASM>:SHADOW_STACK_SYSCALL=1>
    )
  endif()
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
