include(CheckGccGlobalRegisterVars)
include(CheckMMAlignment)

message(STATUS "Building Zend Engine library")

message(STATUS "Generating zend_ini_parser.c")
bison_target(ZendIniParser zend_ini_parser.y ${CMAKE_CURRENT_BINARY_DIR}/zend_ini_parser.c
  COMPILE_FLAGS "-v -d"
  DEFINES_FILE ${CMAKE_CURRENT_BINARY_DIR}/zend_ini_parser.h
)

# TODO: generated zend_language_parser.c and zend_language_parser.h should be
# also patched. See Zend/Makefile.frag for more info.
message(STATUS "Generating zend_language_parser.c")
bison_target(ZendLanguageParser zend_language_parser.y ${CMAKE_CURRENT_BINARY_DIR}/zend_language_parser.c
  COMPILE_FLAGS "-v -d"
  DEFINES_FILE ${CMAKE_CURRENT_BINARY_DIR}/zend_language_parser.h
)

RE2C_TARGET(
  NAME ZendLanguageScanner
  INPUT ${CMAKE_CURRENT_BINARY_DIR}/zend_language_scanner.l
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/zend_language_scanner.c
  OPTIONS "--no-generation-date --case-inverted -cbdFt ${CMAKE_CURRENT_BINARY_DIR}/zend_language_scanner_defs.h"
)

RE2C_TARGET(
  NAME ZendIniScanner
  INPUT ${CMAKE_CURRENT_BINARY_DIR}/zend_ini_scanner.l
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/zend_ini_scanner.c
  OPTIONS "--no-generation-date --case-inverted -cbdFt ${CMAKE_CURRENT_BINARY_DIR}/zend_ini_scanner_defs.h"
)

check_mm_alignment()

message(STATUS "Creating Zend/zend_config.h")
file(WRITE zend_config.h "#include <../main/php_config.h>\n")

add_library(Zend
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
  ${BISON_ZendLanguageParser_OUTPUTS}
)

target_include_directories(
  Zend
  INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}
)

target_compile_definitions(Zend PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

# Check for global register variables.
check_gcc_global_register_vars()

# Check for fibers support.
include(CheckFibers)

if(FIBER_ASM)
  add_library(ZendAsm
    "asm/make_${fiber_asm_file}.S"
    "asm/jump_${fiber_asm_file}.S"
  )

  # The asm file can't see macro from defined constant, workaround this via cflag.
  if(SYSCALL_SHADOW_STACK_EXISTS)
    message(STATUS "Adding compile definition for Zend: SHADOW_STACK_SYSCALL")
    target_compile_definitions(ZendAsm PUBLIC SHADOW_STACK_SYSCALL=1)
  endif()

  target_link_libraries(Zend PUBLIC ZendAsm)
endif()

include(CheckFloatPrecision)
include(CheckStackLimit)
include(CheckZendSignals)
