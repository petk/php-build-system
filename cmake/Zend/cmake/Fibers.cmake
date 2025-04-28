#[=============================================================================[
# Fibers

Check if Fibers can be used.

This module adds Boost fiber assembly files support if available for the
platform, otherwise it checks if ucontext can be used.

## Control variables

* `ZEND_FIBER_ASM`

  Whether to use Boost fiber assembly files.

## Cache variables

* `ZEND_FIBER_UCONTEXT`

  Whether `<ucontext.h>` header file is available and should be used.

## Interface library

* `Zend::Fibers`

  Interface library using Boost fiber assembly files and compile options if
  available.

## Usage

```cmake
# CMakeLists.txt
include(cmake/Fibers.cmake)
```
#]=============================================================================]

include_guard(GLOBAL)

include(CheckIncludeFiles)
include(CheckSourceRuns)
include(CMakePushCheckState)

add_library(zend_fibers INTERFACE)
add_library(Zend::Fibers ALIAS zend_fibers)

if(NOT DEFINED SHADOW_STACK_SYSCALL)
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
    ]] SHADOW_STACK_SYSCALL)
  cmake_pop_check_state()
  if(SHADOW_STACK_SYSCALL)
    message(CHECK_PASS "yes")
  else()
    # If the syscall doesn't exist, we may block the final ELF from
    # __PROPERTY_SHSTK via redefine macro as "-D__CET__=1".
    message(CHECK_FAIL "no")
  endif()
endif()

block()
  set(cpu "")
  set(asmFile "")
  set(prefix "")
  set(compileOptions "")
  set(compileDefinitions "")

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
    if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|amd64|AMD64)$")
      set(asmFile "x86_64_ms_pe_masm.asm")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86|i.?86.*|pentium)$")
      set(asmFile "i386_ms_pe_masm.asm")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(arm64|ARM64)$")
      set(asmFile "arm64_aapcs_pe_armasm.asm")

      set(
        compileOptions
        /nologo
        # TODO: Recheck; "-machine" is a linker option.
        -machine ARM64
      )
    endif()

    if(asmFile AND NOT CMAKE_SYSTEM_PROCESSOR MATCHES "^(arm64|ARM64)$")
      set(compileOptions /nologo)

      set(compileDefinitions "BOOST_CONTEXT_EXPORT=EXPORT")
    endif()
  elseif(CMAKE_SYSTEM_NAME STREQUAL "Midipix")
    if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|amd64)$")
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

  if(ZEND_FIBER_ASM AND asmFile)
    message(CHECK_PASS "yes, Zend/asm/*.${asmFile}")

    target_sources(zend_fibers INTERFACE ${asmSources})

    # Use compile definitions because ASM files can't see macro definitions from
    # the PHP configuration header (php_config.h/config.w32.h).
    target_compile_definitions(
      zend_fibers
      INTERFACE
        $<IF:$<BOOL:${SHADOW_STACK_SYSCALL}>,SHADOW_STACK_SYSCALL=1,SHADOW_STACK_SYSCALL=0>
    )
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

      check_include_files(ucontext.h ZEND_FIBER_UCONTEXT)
    cmake_pop_check_state()

    if(NOT ZEND_FIBER_UCONTEXT)
      message(CHECK_FAIL "no")
      message(
        FATAL_ERROR
        "Fibers are not available on this platform, <ucontext.h> not found."
      )
    endif()
    message(CHECK_PASS "yes, ucontext")
  endif()
endblock()
