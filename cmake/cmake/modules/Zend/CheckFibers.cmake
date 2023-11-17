#[=============================================================================[
Check for Fibers support.
]=============================================================================]#

include(CheckCSourceRuns)
include(CheckIncludeFile)

message(STATUS "Checking fibers support")

message(STATUS "Discovering system processor")
if(${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "x86_64.*|amd64.*")
  set(_fiber_cpu "x86_64")
  set(_fiber_asm_file_prefix "x86_64_sysv")
elseif(${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "x86.*|amd.*|i.?86.*|pentium")
  set(_fiber_cpu "i386")
  set(_fiber_asm_file_prefix "i386_sysv")
elseif(${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "aarch64.*|arm64.*")
  set(_fiber_cpu "arm64")
  set(_fiber_asm_file_prefix "arm64_aapcs")
elseif(${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "arm.*")
  set(_fiber_cpu "arm32")
  set(_fiber_asm_file_prefix "arm_aapcs")
elseif(${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "ppc64.*|powerpc64.*")
  set(_fiber_cpu "ppc64")
  set(_fiber_asm_file_prefix "ppc64_sysv")
elseif(${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "ppc.*|powerpc.*")
  set(_fiber_cpu "ppc32")
  set(_fiber_asm_file_prefix "ppc32_sysv")
elseif(${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "riscv64.*")
  set(_fiber_cpu "riscv64")
  set(_fiber_asm_file_prefix "riscv64_sysv")
elseif(${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "s390x.*")
  set(_fiber_cpu "s390x")
  set(_fiber_asm_file_prefix "s390x_sysv")
elseif(${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "mips64.*")
  set(_fiber_cpu "mips64")
  set(_fiber_asm_file_prefix "mips64_n64")
elseif(${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "mips.*")
  set(_fiber_cpu "mips32")
  set(_fiber_asm_file_prefix "mips32_o32")
else()
  set(_fiber_cpu "unknown")
  set(_fiber_asm_file_prefix "unknown")
endif()

message(STATUS "fiber_cpu is set to ${_fiber_cpu}")

message(STATUS "Checking for host operating system")

string(TOLOWER "${CMAKE_HOST_SYSTEM_NAME}" host_os)

if(${host_os} MATCHES "darwin.*")
  set(_fiber_os "mac")
elseif(${host_os} MATCHES "aix.*|os400.*")
  set(_fiber_os "aix")
elseif(${host_os} MATCHES "freebsd.*")
  set(_fiber_os "freebsd")
else()
  set(_fiber_os "other")
endif()

if(${_fiber_os} STREQUAL "mac")
  set(FIBER_ASM_FILE "combined_sysv_macho_gas")
elseif(${_fiber_os} STREQUAL "aix")
  # AIX uses a different calling convention (shared with non-_CALL_ELF Linux).
  # The AIX assembler isn't GNU, but the file is compatible.
  set(FIBER_ASM_FILE "${_fiber_asm_file_prefix}_xcoff_gas")
elseif(${_fiber_os} STREQUAL "freebsd")
  if(${_fiber_cpu} STREQUAL "i386")
    set(ZEND_FIBER_ASM OFF PARENT_SCOPE)
  else()
    set(FIBER_ASM_FILE "${_fiber_asm_file_prefix}_elf_gas")
  endif()
elseif(NOT ${_fiber_asm_file_prefix} STREQUAL "unknown")
  set(FIBER_ASM_FILE "${_fiber_asm_file_prefix}_elf_gas")
else()
  set(ZEND_FIBER_ASM OFF PARENT_SCOPE)
endif()

set(CMAKE_REQUIRED_LIBRARIES "c")
set(CMAKE_REQUIRED_DEFINITIONS "-D_GNU_SOURCE")

# Check whether syscall to create shadow stack exists, should be a better way,
# but...
message(CHECK_START "Whether syscall to create shadow stack exists")
check_c_source_runs("
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

if(SHADOW_STACK_SYSCALL)
  message(CHECK_PASS "yes")
else()
  # If the syscall doesn't exist, we may block the final ELF from
  # __PROPERTY_SHSTK via redefine macro as "-D__CET__=1".
  message(CHECK_PASS "no")
endif()

if(NOT ZEND_FIBER_ASM)
  if(${_fiber_os} STREQUAL "mac")
    set(_XOPEN_SOURCE 1 CACHE INTERNAL "")
  endif()

  check_include_file(ucontext.h ZEND_FIBER_UCONTEXT)

  if(NOT ZEND_FIBER_UCONTEXT)
    message(FATAL_ERROR "Fibers are not available on this platform, ucontext.h not found")
  endif()
endif()
