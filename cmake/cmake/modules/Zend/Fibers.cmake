#[=============================================================================[
Check if Fibers can be used.

This module adds Boost fiber assembly files support if available for the
platform, otherwise it checks if ucontext can be used.

Interface library:

  Zend::Fibers
    Library using Boost fiber assembly files if available.

Cache variables:

  SHADOW_STACK_SYSCALL
    Whether syscall to create shadow stack exists.

  ZEND_FIBER_UCONTEXT
    Whether ucontext.h is available and should be used.

Control variables:

  ZEND_FIBER_ASM
    Whether to use Boost fiber assembly files.
]=============================================================================]#

include_guard(GLOBAL)

include(CheckIncludeFile)
include(CheckSourceRuns)
include(CMakePushCheckState)

add_library(zend_fibers INTERFACE)
add_library(Zend::Fibers ALIAS zend_fibers)

message(CHECK_START "Whether syscall to create shadow stack exists")
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  if(NOT CMAKE_CROSSCOMPILING)
    check_source_runs(C [[
      #include <unistd.h>
      #include <sys/mman.h>
      int main(void) {
        void* base = (void *)syscall(451, 0, 0x20000, 0x1);
        if (base != (void*)-1) {
          munmap(base, 0x20000);
          return 0;
        }
        return 1;
      }
    ]] SHADOW_STACK_SYSCALL)
  endif()
cmake_pop_check_state()
if(SHADOW_STACK_SYSCALL)
  message(CHECK_PASS "yes")
else()
  # If the syscall doesn't exist, we may block the final ELF from
  # __PROPERTY_SHSTK via redefine macro as "-D__CET__=1".
  message(CHECK_FAIL "no")
endif()

block(PROPAGATE zend_fibers_asm_file zend_fibers_asm_sources)
  # Determine files based on the architecture and platform.
  if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|amd64)$")
    set(prefix "x86_64_sysv")
  elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86.*|amd.*|i.?86.*|pentium)$")
    set(cpu "i386")
    set(prefix "i386_sysv")
  elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64.*|arm64.*)")
    set(prefix "arm64_aapcs")
  elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "arm.*")
    set(prefix "arm_aapcs")
  elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "ppc64.*|powerpc64.*")
    set(prefix "ppc64_sysv")
  elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "ppc.*|powerpc.*")
    set(prefix "ppc32_sysv")
  elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^riscv64.*")
    set(prefix "riscv64_sysv")
  elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^sparc64.*")
    set(prefix "sparc64_sysv")
  elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "s390x.*")
    set(prefix "s390x_sysv")
  elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^loongarch64.*")
    set(prefix "loongarch_sysv")
  elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL "mips64")
    set(prefix "mips64_n64")
  elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL "mips")
    set(prefix "mips32_o32")
  endif()

  if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(zend_fibers_asm_file "combined_sysv_macho_gas.S")
  elseif(CMAKE_SYSTEM_NAME STREQUAL "AIX")
    # AIX uses a different calling convention (shared with non-_CALL_ELF Linux).
    # The AIX assembler isn't GNU, but the file is compatible.
    set(zend_fibers_asm_file "${prefix}_xcoff_gas.S")
  elseif(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
    if(NOT cpu STREQUAL "i386")
      set(zend_fibers_asm_file "${prefix}_elf_gas.S")
    endif()
  elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|amd64|AMD64)$")
      set(zend_fibers_asm_file "x86_64_ms_pe_masm.asm")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86|i.?86.*|pentium)$")
      set(zend_fibers_asm_file "i386_ms_pe_masm.asm")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(arm64|ARM64)$")
      set(zend_fibers_asm_file "arm64_aapcs_pe_armasm.asm")

      set(
        compile_options
        /nologo
        # TODO: Recheck; "-machine" is a linker option.
        -machine ARM64
      )
    endif()

    if(
      zend_fibers_asm_file
      AND NOT CMAKE_SYSTEM_PROCESSOR MATCHES "^(arm64|ARM64)$"
    )
      set(
        compile_options
        /nologo
      )

      set(
        compile_definitions
        "BOOST_CONTEXT_EXPORT=EXPORT"
      )
    endif()
  elseif(CMAKE_SYSTEM_NAME STREQUAL "Midipix")
    if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|amd64)$")
      set(zend_fibers_asm_file "x86_64_ms_pe_gas.S")
    endif()
  elseif(prefix)
    set(zend_fibers_asm_file "${prefix}_elf_gas.S")
  endif()

  if(NOT zend_fibers_asm_file)
    return()
  endif()

  set(
    zend_fibers_asm_sources
    ${CMAKE_CURRENT_SOURCE_DIR}/asm/jump_${zend_fibers_asm_file}
    ${CMAKE_CURRENT_SOURCE_DIR}/asm/make_${zend_fibers_asm_file}
  )

  # Workaround with compile definitions, because ASM files can't see macro
  # definitions from configuration header.
  if(SHADOW_STACK_SYSCALL)
    list(APPEND
      compile_definitions
      "SHADOW_STACK_SYSCALL=1"
    )
  endif()

  if(compile_options)
    set_source_files_properties(
      ${zend_fibers_asm_sources}
      PROPERTIES
        COMPILE_OPTIONS ${compile_options}
    )
  endif()

  if(compile_definitions)
    set_source_files_properties(
      ${zend_fibers_asm_sources}
      PROPERTIES
        COMPILE_DEFINITIONS ${compile_definitions}
    )
  endif()
endblock()

message(CHECK_START "Checking for fibers switching context support")

if(ZEND_FIBER_ASM AND zend_fibers_asm_file)
  message(CHECK_PASS "yes, Zend/asm/*.${zend_fibers_asm_file}")

  target_sources(
    zend_fibers
    INTERFACE
      ${zend_fibers_asm_sources}
  )
else()
  cmake_push_check_state(RESET)
    # To use ucontext.h on macOS, the _XOPEN_SOURCE needs to be defined to any
    # value. POSIX marked ucontext functions as obsolete and on macOS, the
    # ucontext.h functions are marked as deprecated. At the time of writing no
    # solution is on the horizon yet.
    if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
      set(CMAKE_REQUIRED_DEFINITIONS -D_XOPEN_SOURCE)
    endif()

    check_include_file(ucontext.h ZEND_FIBER_UCONTEXT)
  cmake_pop_check_state()

  if(ZEND_FIBER_UCONTEXT)
    message(CHECK_PASS "yes, ucontext")
  else()
    message(CHECK_FAIL "no")
    message(
      FATAL_ERROR
      "Fibers are not available on this platform, ucontext.h not found"
    )
  endif()
endif()
