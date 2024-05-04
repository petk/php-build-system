################################################################################
# Zend engine.
################################################################################

# Read the Zend engine version.
block(PROPAGATE Zend_VERSION Zend_VERSION_LABEL)
  file(READ zend.h content)
  string(
    REGEX MATCH
    "#[ \t]*define[ \t]+ZEND_VERSION[ \t]+\"([0-9.]+)([^\"]*)"
    _
    "${content}"
  )
  set(Zend_VERSION "${CMAKE_MATCH_1}")
  set(Zend_VERSION_LABEL "${CMAKE_MATCH_2}")
endblock()

project(
  Zend
  VERSION ${Zend_VERSION}
  DESCRIPTION "Zend engine library"
  LANGUAGES C CXX ASM
)

string(APPEND Zend_VERSION "${Zend_VERSION_LABEL}")
message(STATUS "Zend engine version: ${Zend_VERSION}")

block()
  file(READ zend_extensions.h content)
  string(
    REGEX MATCH
    "#[ \t]*define[ \t]+ZEND_EXTENSION_API_NO[ \t]+([0-9]+)"
    _
    "${content}"
  )
  message(STATUS "Zend extension API number: ${CMAKE_MATCH_1}")

  file(READ zend_modules.h content)
  string(
    REGEX MATCH
    "#[ \t]*define[ \t]+ZEND_MODULE_API_NO[ \t]+([0-9]+)"
    _
    "${content}"
  )
  message(STATUS "Zend module API number: ${CMAKE_MATCH_1}")
endblock()

include(CheckIncludeFile)
include(CheckSourceCompiles)
include(CheckSymbolExists)
include(CMakePushCheckState)
include(PHP/SearchLibraries)

################################################################################
# Configuration.
################################################################################

option(ZEND_GCC_GLOBAL_REGS "Enable GCC global register variables" ON)
mark_as_advanced(ZEND_GCC_GLOBAL_REGS)

option(ZEND_FIBER_ASM "Enable the use of Boost fiber assembly files" ON)
mark_as_advanced(ZEND_FIBER_ASM)

option(ZEND_SIGNALS "Enable Zend signal handling" ON)
mark_as_advanced(ZEND_SIGNALS)

# TODO: Check if default value can be improved. Once cached variable is set, it
# can't be changed to PHP_THREAD_SAFETY value on the 2nd configuration run.
option(
  ZEND_MAX_EXECUTION_TIMERS
  "Enable Zend max execution timers"
  ${PHP_THREAD_SAFETY}
)
mark_as_advanced(ZEND_MAX_EXECUTION_TIMERS)

# TODO: Fix this better.
if(PHP_THREAD_SAFETY)
  set(ZTS 1 PARENT_SCOPE)
endif()

################################################################################
# Add library.
################################################################################

add_library(zend STATIC)
add_library(Zend::Zend ALIAS zend)

file(GLOB _zend_headers ${CMAKE_CURRENT_SOURCE_DIR}/*.h)
# Exclude Windows header and specify it below separately.
list(FILTER _zend_headers EXCLUDE REGEX ".*zend_config\\.w32\\.h$")

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
    $<$<NOT:$<PLATFORM_ID:Windows>>:zend_gdb.c>
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
    $<$<NOT:$<PLATFORM_ID:Windows>>:zend_max_execution_timer.c>
    zend_multibyte.c
    zend_object_handlers.c
    zend_objects_API.c
    zend_objects.c
    zend_observer.c
    zend_opcode.c
    zend_operators.c
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
    zend.c
  PUBLIC
    FILE_SET HEADERS
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
  PUBLIC
    FILE_SET HEADERS
      BASE_DIRS ${CMAKE_CURRENT_BINARY_DIR}
      FILES
        $<$<NOT:$<PLATFORM_ID:Windows>>:${CMAKE_CURRENT_BINARY_DIR}/zend_config.h>
)

target_link_libraries(zend PRIVATE PHP::configuration)

target_include_directories(
  zend
  INTERFACE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
)

target_link_libraries(zend PUBLIC PHP::TSRM)

target_compile_definitions(
  zend
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
    $<$<PLATFORM_ID:Windows>:LIBZEND_EXPORTS>
)

# Add Zend PUBLIC/INTERFACE compile options to configuration.
# Cleaner COMPILE_ONLY generator expression is available in CMake >= 3.27.
if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.27)
  target_link_libraries(php_configuration INTERFACE $<COMPILE_ONLY:Zend::Zend>)
else()
  target_include_directories(
    php_configuration
    INTERFACE
      $<TARGET_PROPERTY:Zend::Zend,INTERFACE_INCLUDE_DIRECTORIES>
  )
endif()

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

# BSD-based systems have pthread_attr_get_np in pthread_np.h.
block()
  check_include_file(pthread_np.h _HAVE_PTHREAD_NP_H)

  if(_HAVE_PTHREAD_NP_H)
    set(headers "pthread_np.h")
  endif()

  check_symbol_exists(
    pthread_attr_get_np
    "${headers};pthread.h"
    HAVE_PTHREAD_ATTR_GET_NP
  )
endblock()

check_symbol_exists(
  pthread_get_stackaddr_np
  "pthread.h"
  HAVE_PTHREAD_GET_STACKADDR_NP
)
check_symbol_exists(
  pthread_attr_getstack
  "pthread.h"
  HAVE_PTHREAD_ATTR_GETSTACK
)
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
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_source_compiles(C [[
    #include <cpuid.h>
    int main(void) {
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
if(ZEND_MAX_EXECUTION_TIMERS AND CMAKE_SYSTEM_NAME STREQUAL "Linux")
  php_search_libraries(
    timer_create
    HAVE_TIMER_CREATE
    HEADERS time.h
    LIBRARIES
      rt # Solaris <= 10, older Linux
    TARGET zend PRIVATE
  )

  if(NOT HAVE_TIMER_CREATE)
    set_property(CACHE ZEND_MAX_EXECUTION_TIMERS PROPERTY VALUE 0)
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

# zend_config.h (or its parent php_config.h) isn't included in some zend_*
# files, therefore also compilation definitions need to be added.
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
    ${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_parser.c
    COMPILE_FLAGS "-Wall -v -d"
    DEFINES_FILE ${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_parser.h
  )

  add_custom_target(zend_ini_parser DEPENDS ${BISON_TARGET_outputs})
  add_dependencies(php_generate_files zend_ini_parser)

  bison_target(
    zend_language_parser
    zend_language_parser.y
    ${CMAKE_CURRENT_SOURCE_DIR}/zend_language_parser.c
    COMPILE_FLAGS "-Wall -v -d"
    DEFINES_FILE ${CMAKE_CURRENT_SOURCE_DIR}/zend_language_parser.h
  )

  # Tweak zendparse to be exported through ZEND_API. This has to be revisited
  # once bison supports foreign skeletons and that bison version is used. Read
  # https://git.savannah.gnu.org/cgit/bison.git/tree/data/README.md for more.
  file(
    GENERATE
    OUTPUT CMakeFiles/PatchZendLanguageParserFiles.cmake
    CONTENT [[
      file(READ "${SRC}/zend_language_parser.h" content)
      string(
        REPLACE
        "int zendparse"
        "ZEND_API int zendparse"
        content
        "${content}"
      )
      file(WRITE "${SRC}/zend_language_parser.h" "${content}")
      file(READ "${SRC}/zend_language_parser.c" content)
      string(
        REPLACE
        "int zendparse"
        "ZEND_API int zendparse"
        content
        "${content}"
      )
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

  add_dependencies(php_generate_files zend_patch_language_parser_files)
endif()

if(RE2C_FOUND)
  re2c_target(
    NAME zend_language_scanner
    INPUT zend_language_scanner.l
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/zend_language_scanner.c
    OPTIONS
      --no-generation-date
      --case-inverted
      -cbdF
      -t ${CMAKE_CURRENT_SOURCE_DIR}/zend_language_scanner_defs.h
  )

  re2c_target(
    NAME zend_ini_scanner
    INPUT zend_ini_scanner.l
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_scanner.c
    OPTIONS
      --no-generation-date
      --case-inverted
      -cbdF
      -t ${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_scanner_defs.h
  )

  add_dependencies(php_generate_files zend_language_scanner zend_ini_scanner)
endif()

################################################################################
# Configure fibers.
################################################################################

include(Zend/Fibers)
if(TARGET Zend::Fibers)
  target_link_libraries(zend PRIVATE Zend::Fibers)
endif()

################################################################################
# Create files and set installation.
################################################################################

if(PHPSystem_EXECUTABLE)
  set(PHP_EXECUTABLE ${PHPSystem_EXECUTABLE})
elseif(NOT CMAKE_CROSSCOMPILING)
  set(PHP_EXECUTABLE "$<TARGET_FILE:php_cli>")
endif()

if(PHP_EXECUTABLE)
  # Run the Zend/zend_vm_gen.php script.
  file(
    GENERATE
    OUTPUT CMakeFiles/GenerateZendVm.cmake
    CONTENT [[
      if(EXISTS ${PHP_EXECUTABLE})
        execute_process(
          COMMAND ${PHP_EXECUTABLE} ${CURRENT_SOURCE_DIR}/zend_vm_gen.php
        )
      endif()
    ]]
  )

  add_custom_command(
    OUTPUT zend_vm
    COMMAND ${CMAKE_COMMAND}
            -D PHP_EXECUTABLE=${PHP_EXECUTABLE}
            -D CURRENT_SOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}
            -P CMakeFiles/GenerateZendVm.cmake
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/zend_vm_execute.skl
    COMMENT "[Zend] Regenerating zend_vm_execute.h and zend_vm_opcodes.{h,c}"
    VERBATIM
  )

  add_custom_target(zend_generate_vm ALL DEPENDS zend_vm)

  set_property(SOURCE zend_vm PROPERTY SYMBOLIC TRUE)
endif()

if(NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
  message(STATUS "Creating Zend/zend_config.h")

  file(
    WRITE
    ${CMAKE_CURRENT_BINARY_DIR}/zend_config.h
    "#include <../main/php_config.h>\n"
  )
endif()

install(
  TARGETS zend
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET HEADERS
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/Zend
)
