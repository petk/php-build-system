################################################################################
# Zend engine.
################################################################################

# Read the Zend engine version.
file(READ "zend.h" _)
string(REGEX MATCH "#[ \t]*define[ \t]+ZEND_VERSION[ \t]+\"([0-9.]+)([^\"]*)" _ "${_}")
set(Zend_VERSION_LABEL "${CMAKE_MATCH_2}")

project(
  Zend
  VERSION ${CMAKE_MATCH_1}
  DESCRIPTION "Zend engine library"
  LANGUAGES C CXX ASM
)

string(APPEND Zend_VERSION "${Zend_VERSION_LABEL}")
message(STATUS "Zend engine version: ${Zend_VERSION}")

file(READ "zend_extensions.h" _)
string(REGEX MATCH "#[ \t]*define[ \t]+ZEND_EXTENSION_API_NO[ \t]+([0-9]+)" _ "${_}")
message(STATUS "Zend extension API number: ${CMAKE_MATCH_1}")

file(READ "zend_modules.h" _)
string(REGEX MATCH "#[ \t]*define[ \t]+ZEND_MODULE_API_NO[ \t]+([0-9]+)" _ "${_}")
message(STATUS "Zend module API number: ${CMAKE_MATCH_1}")

include(CheckIncludeFile)
include(CheckSourceCompiles)
include(CheckSourceRuns)
include(CheckSymbolExists)
include(CMakePushCheckState)
include(PHP/SearchLibraries)

################################################################################
# Configuration.
################################################################################

option(ZEND_GCC_GLOBAL_REGS "Enable GCC global register variables" ON)

option(ZEND_FIBER_ASM "Enable the use of Boost fiber assembly files" ON)

option(ZEND_SIGNALS "Enable Zend signal handling" ON)

# TODO: Check if default value can be improved. Once cached variable is set, it
# can't be changed based on PHP_THREAD_SAFETY value on the 2nd configuration run.
option(ZEND_MAX_EXECUTION_TIMERS "Enable Zend max execution timers" ${PHP_THREAD_SAFETY})

# TODO: Fix this better.
if(PHP_THREAD_SAFETY)
  set(ZTS 1 PARENT_SCOPE)
endif()

################################################################################
# Add library.
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

target_include_directories(zend
  INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}"
            "${CMAKE_CURRENT_BINARY_DIR}"
)

target_link_libraries(zend PUBLIC PHP::TSRM)

target_compile_definitions(zend PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

################################################################################
# Configuration checks.
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
check_source_compiles(C "
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
if(PHP_THREAD_SAFETY)
  target_compile_definitions(zend PRIVATE ZTS)
endif()

if(ZEND_SIGNALS)
  target_compile_definitions(zend PRIVATE ZEND_SIGNALS)
endif()

if(ZEND_MAX_EXECUTION_TIMERS)
  target_compile_definitions(zend PRIVATE ZEND_MAX_EXECUTION_TIMERS)
endif()

################################################################################
# Generate lexers and parsers.
################################################################################

if(BISON_FOUND)
  bison_target(
    zend_ini_parser
    zend_ini_parser.y
    "${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_parser.c"
    COMPILE_FLAGS "-Wall -v -d"
    DEFINES_FILE "${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_parser.h"
  )

  bison_target(
    zend_language_parser
    zend_language_parser.y
    "${CMAKE_CURRENT_SOURCE_DIR}/zend_language_parser.c"
    COMPILE_FLAGS "-Wall -v -d"
    DEFINES_FILE "${CMAKE_CURRENT_SOURCE_DIR}/zend_language_parser.h"
  )

  # Tweak zendparse to be exported through ZEND_API. This has to be revisited
  # once bison supports foreign skeletons and that bison version is used. Read
  # https://git.savannah.gnu.org/cgit/bison.git/tree/data/README.md for more.
  file(
    GENERATE
    OUTPUT CMakeFiles/PatchZendLanguageParserFiles.cmake
    CONTENT [[
      file(READ "${SRC}/zend_language_parser.h" content)
      string(REPLACE "int zendparse" "ZEND_API int zendparse" content "${content}")
      file(WRITE "${SRC}/zend_language_parser.h" "${content}")
      file(READ "${SRC}/zend_language_parser.c" content)
      string(REPLACE "int zendparse" "ZEND_API int zendparse" content "${content}")
      file(WRITE "${SRC}/zend_language_parser.c" "${content}")
    ]]
  )
  add_custom_target(
    zend_patch_language_parser_files
    COMMAND ${CMAKE_COMMAND}
      -D SRC=${CMAKE_CURRENT_SOURCE_DIR}
      -P "CMakeFiles/PatchZendLanguageParserFiles.cmake"
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

# Check whether syscall to create shadow stack exists.
message(CHECK_START "Whether syscall to create shadow stack exists")
if(NOT CMAKE_CROSSCOMPILING)
  check_source_runs(C "
    #include <unistd.h>
    #include <sys/mman.h>
    int main(void) {
      void* base = (void *)syscall(451, 0, 0x20000, 0x1);
      if (base != (void*)-1) {
        munmap(base, 0x20000);
        return 0;
      }
      else
        return 1;
    }
  " SHADOW_STACK_SYSCALL)
endif()
if(SHADOW_STACK_SYSCALL)
  message(CHECK_PASS "yes")
else()
  # If the syscall doesn't exist, we may block the final ELF from
  # __PROPERTY_SHSTK via redefine macro as "-D__CET__=1".
  message(CHECK_FAIL "no")
endif()

message(CHECK_START "Checking fibers ASM support")

if(ZEND_FIBER_ASM)
  if(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^(x86_64|amd64)$")
    set(_zend_fiber_asm_file_prefix "x86_64_sysv")
  elseif(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "x86.*|amd.*|i.?86.*|pentium")
    set(_zend_fiber_cpu "i386")
    set(_zend_fiber_asm_file_prefix "i386_sysv")
  elseif(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "aarch64.*|arm64.*")
    set(_zend_fiber_asm_file_prefix "arm64_aapcs")
  elseif(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "arm.*")
    set(_zend_fiber_asm_file_prefix "arm_aapcs")
  elseif(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "ppc64.*|powerpc64.*")
    set(_zend_fiber_asm_file_prefix "ppc64_sysv")
  elseif(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "ppc.*|powerpc.*")
    set(_zend_fiber_asm_file_prefix "ppc32_sysv")
  elseif(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "riscv64.*")
    set(_zend_fiber_asm_file_prefix "riscv64_sysv")
  elseif(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "s390x.*")
    set(_zend_fiber_asm_file_prefix "s390x_sysv")
  elseif(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "mips64")
    set(_zend_fiber_asm_file_prefix "mips64_n64")
  elseif(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "mips")
    set(_zend_fiber_asm_file_prefix "mips32_o32")
  else()
    set(_zend_fiber_asm_file_prefix "unknown")
  endif()

  if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
    set(_zend_fiber_asm_file "combined_sysv_macho_gas")
  elseif(CMAKE_HOST_SYSTEM_NAME MATCHES "^(AIX|OS400)$")
    # AIX uses a different calling convention (shared with non-_CALL_ELF Linux).
    # The AIX assembler isn't GNU, but the file is compatible.
    set(_zend_fiber_asm_file "${_zend_fiber_asm_file_prefix}_xcoff_gas")
  elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "FreeBSD")
    if(NOT _zend_fiber_cpu STREQUAL "i386")
      set(_zend_fiber_asm_file "${_zend_fiber_asm_file_prefix}_elf_gas")
    endif()
  elseif(NOT _zend_fiber_asm_file_prefix STREQUAL "unknown")
    set(_zend_fiber_asm_file "${_zend_fiber_asm_file_prefix}_elf_gas")
  endif()
endif()

if(_zend_fiber_asm_file)
  message(CHECK_PASS "yes - ${_zend_fiber_asm_file}")

  target_sources(zend PRIVATE
    asm/jump_${_zend_fiber_asm_file}.S
    asm/make_${_zend_fiber_asm_file}.S
  )

  # The ASM files can't see macro from defined constant, workaround via CFLAG.
  if(SHADOW_STACK_SYSCALL)
    target_compile_definitions(zend PRIVATE
      $<$<COMPILE_LANGUAGE:ASM>:SHADOW_STACK_SYSCALL=1>
    )
  endif()
else()
  message(CHECK_FAIL "no")

  cmake_push_check_state(RESET)
    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
      set(CMAKE_REQUIRED_DEFINITIONS -D_XOPEN_SOURCE)
      # TODO: Fix this better.
      set(_XOPEN_SOURCE 1 CACHE INTERNAL "")
    endif()

    check_include_file(ucontext.h ZEND_FIBER_UCONTEXT)
  cmake_pop_check_state()

  if(NOT ZEND_FIBER_UCONTEXT)
    message(
      FATAL_ERROR
      "Fibers are not available on this platform, ucontext.h not found"
    )
  endif()
endif()

################################################################################
# Create files and set installation.
################################################################################

if(NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
  message(STATUS "Creating Zend/zend_config.h")

  file(
    WRITE
    "${CMAKE_CURRENT_BINARY_DIR}/zend_config.h"
    "#include <../main/php_config.h>\n"
  )
endif()

file(GLOB _zend_headers "${CMAKE_CURRENT_SOURCE_DIR}/*.h")
# Exclude Windows header and specify it below separately.
list(FILTER _zend_headers EXCLUDE REGEX ".*zend_config\\.w32\\.h$")

target_sources(
  zend
  PUBLIC FILE_SET headers_source TYPE HEADERS
    BASE_DIRS "${PHP_SOURCE_DIR}"
    FILES
      ${_zend_headers}
      $<$<PLATFORM_ID:Windows>:zend_config.w32.h>
      Optimizer/zend_call_graph.h
      Optimizer/zend_cfg.h
      Optimizer/zend_dfg.h
      Optimizer/zend_dump.h
      Optimizer/zend_func_info.h
      Optimizer/zend_inference.h
      Optimizer/zend_optimizer.h
      Optimizer/zend_ssa.h
      Optimizer/zend_worklist.h
  # A separate file set so binary dir can also be created within a source dir.
  PUBLIC FILE_SET headers_binary TYPE HEADERS
    BASE_DIRS "${PHP_BINARY_DIR}"
    FILES
      $<$<NOT:$<PLATFORM_ID:Windows>>:${CMAKE_CURRENT_BINARY_DIR}/zend_config.h>
)

install(
  TARGETS zend
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET headers_source
  FILE_SET headers_binary
)
