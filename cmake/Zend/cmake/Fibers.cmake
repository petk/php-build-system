#[=============================================================================[
Determine whether Fibers can be used and add Boost fiber assembly files support
if available for the platform. As a Boost fallback alternative ucontext support
is checked if it can be used.

Result variables:

* ZEND_FIBER_UCONTEXT
#]=============================================================================]

include(CheckIncludeFiles)
include(CheckSourceRuns)
include(CMakePushCheckState)

# Create interface library for using Boost fiber assembly files and compile
# options if available.
add_library(zend_fibers INTERFACE)
add_library(Zend::Fibers ALIAS zend_fibers)
target_link_libraries(zend PRIVATE Zend::Fibers)

################################################################################
# Check shadow stack.
################################################################################

function(_php_zend_fibers_shadow_stack_syscall)
  if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(PHP_ZEND_SHADOW_STACK_SYSCALL FALSE)
  endif()

  if(NOT DEFINED PHP_ZEND_SHADOW_STACK_SYSCALL)
    message(CHECK_START "Whether syscall to create shadow stack exists")
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_QUIET TRUE)

      check_source_runs(C [[
        #include <unistd.h>
        #include <sys/mman.h>
        int main(void)
        {
          void* base = (void *)syscall(451, 0, 0x20000, 0x1);
          if (base != (void*)-1) {
            munmap(base, 0x20000);
            return 0;
          }
          return 1;
        }
      ]] PHP_ZEND_SHADOW_STACK_SYSCALL)
    cmake_pop_check_state()

    if(PHP_ZEND_SHADOW_STACK_SYSCALL)
      message(CHECK_PASS "yes")
    else()
      # If the syscall doesn't exist, we may block the final ELF from
      # __PROPERTY_SHSTK via redefine macro as "-D__CET__=1".
      message(CHECK_FAIL "no")
    endif()
  endif()

  # Use compile definitions because ASM files can't see macro definitions from
  # the PHP configuration header (php_config.h/config.w32.h).
  target_compile_definitions(
    zend_fibers
    INTERFACE
      $<IF:$<BOOL:${PHP_ZEND_SHADOW_STACK_SYSCALL}>,SHADOW_STACK_SYSCALL=1,SHADOW_STACK_SYSCALL=0>
  )
endfunction()

################################################################################
# Configure fibers.
################################################################################

block()
  set(cpu "")
  set(asmFile "")
  set(prefix "")
  set(compileOptions "")
  set(compileDefinitions "")

  # Determine files based on the architecture and platform.
  if(CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "x86_64")
    set(prefix "x86_64_sysv")
  elseif(CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "i[3456]86")
    set(cpu "i386")
    set(prefix "i386_sysv")
  elseif(CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "(aarch64|arm64)")
    set(prefix "arm64_aapcs")
  elseif(CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "arm")
    set(prefix "arm_aapcs")
  elseif(CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "(ppc64|PPC64)")
    set(prefix "ppc64_sysv")
  elseif(CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "(ppc|PPC)")
    set(prefix "ppc32_sysv")
  elseif(CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "(riscv64|RISCV)")
    set(prefix "riscv64_sysv")
  elseif(CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "sparc64")
    set(prefix "sparc64_sysv")
  elseif(CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "s390x")
    set(prefix "s390x_sysv")
  elseif(CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "loongarch64")
    set(prefix "loongarch_sysv")
  elseif(CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "mips64")
    set(prefix "mips64_n64")
  elseif(CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "mips")
    set(prefix "mips32_o32")
  endif()

  if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(asmFile "combined_sysv_macho_gas.S")
  elseif(CMAKE_SYSTEM_NAME STREQUAL "AIX")
    # AIX uses a different calling convention (shared with non-_CALL_ELF Linux).
    # The AIX assembler isn't GNU, but the file is compatible.
    set(asmFile "${prefix}_xcoff_gas.S")
  elseif(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
    if(NOT cpu STREQUAL "i386")
      set(asmFile "${prefix}_elf_gas.S")
    endif()
  elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    if(CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "(x86_64|x64)")
      set(asmFile "x86_64_ms_pe_masm.asm")
    elseif(CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "(X86|i[3456]86)")
      set(asmFile "i386_ms_pe_masm.asm")
    elseif(CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "(ARM64|aarch64)")
      set(asmFile "arm64_aapcs_pe_armasm.asm")
      set(compileOptions /nologo -machine ARM64)
    endif()

    if(asmFile AND NOT CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "(ARM64|aarch64)")
      set(compileOptions /nologo)

      set(compileDefinitions "BOOST_CONTEXT_EXPORT=EXPORT")
    endif()
  elseif(CMAKE_SYSTEM_NAME STREQUAL "Midipix")
    if(CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "x86_64")
      set(asmFile "x86_64_ms_pe_gas.S")
    endif()
  elseif(prefix)
    set(asmFile "${prefix}_elf_gas.S")
  endif()

  if(asmFile)
    set(
      asmSources
      ${CMAKE_CURRENT_SOURCE_DIR}/asm/jump_${asmFile}
      ${CMAKE_CURRENT_SOURCE_DIR}/asm/make_${asmFile}
    )

    if(CMAKE_SYSTEM_NAME STREQUAL "Windows" AND CMAKE_SIZEOF_VOID_P EQUAL 8)
      list(
        APPEND
        asmSources
        ${CMAKE_CURRENT_SOURCE_DIR}/asm/save_xmm_x86_64_ms_masm.asm
      )
    endif()

    if(compileOptions)
      set_source_files_properties(
        ${asmSources}
        PROPERTIES
          COMPILE_OPTIONS ${compileOptions}
      )
    endif()

    if(compileDefinitions)
      set_source_files_properties(
        ${asmSources}
        PROPERTIES
          COMPILE_DEFINITIONS ${compileDefinitions}
      )
    endif()
  endif()

  message(CHECK_START "Checking for fibers switching context support")

  if(PHP_ZEND_FIBER_ASM AND asmFile)
    message(CHECK_PASS "yes, Zend/asm/*.${asmFile}")

    target_sources(zend_fibers INTERFACE ${asmSources})

    _php_zend_fibers_shadow_stack_syscall()
  else()
    cmake_push_check_state(RESET)
      # To use ucontext.h on macOS, the _XOPEN_SOURCE needs to be defined to any
      # value. POSIX marked ucontext functions as obsolete and on macOS the
      # ucontext.h functions are deprecated. At the time of writing no solution is
      # on the horizon yet. Here, the _XOPEN_SOURCE is defined to empty value to
      # enable proper X/Open symbols yet still to not enable some of the Single
      # Unix specification definitions (values 500 or greater where the PHP
      # thread-safe build would fail).
      if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
        set(CMAKE_REQUIRED_DEFINITIONS -D_XOPEN_SOURCE)

        set_property(
          SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/zend_fibers.c
          APPEND
          PROPERTY
            COMPILE_DEFINITIONS _XOPEN_SOURCE
        )
      endif()

      check_include_files(ucontext.h PHP_ZEND_FIBER_UCONTEXT)
    cmake_pop_check_state()

    if(NOT PHP_ZEND_FIBER_UCONTEXT)
      message(CHECK_FAIL "no")
      message(
        FATAL_ERROR
        "Fibers are not available on this platform, <ucontext.h> not found."
      )
    endif()
    message(CHECK_PASS "yes, ucontext")
    set(ZEND_FIBER_UCONTEXT TRUE PARENT_SCOPE)
  endif()
endblock()
