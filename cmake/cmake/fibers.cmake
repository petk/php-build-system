include(CheckCSourceRuns)

option(FIBER_ASM "Enable the use of boost fiber assembly files" ON)

message(STATUS "Discovering system processor")
if(${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "x86_64.*|amd64.*")
  set(fiber_cpu "x86_64")
  set(fiber_asm_file_prefix "x86_64_sysv")
elseif(${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "x86.*|amd.*|i.?86.*|pentium")
  set(fiber_cpu "i386")
  set(fiber_asm_file_prefix "i386_sysv")
elseif(${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "aarch64.*|arm64.*")
  set(fiber_cpu "arm64")
  set(fiber_asm_file_prefix "arm64_aapcs")
elseif(${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "arm.*")
  set(fiber_cpu "arm32")
  set(fiber_asm_file_prefix "arm_aapcs")
elseif(${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "ppc64.*|powerpc64.*")
  set(fiber_cpu "ppc64")
  set(fiber_asm_file_prefix "ppc64_sysv")
elseif(${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "ppc.*|powerpc.*")
  set(fiber_cpu "ppc32")
  set(fiber_asm_file_prefix "ppc32_sysv")
elseif(${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "riscv64.*")
  set(fiber_cpu "riscv64")
  set(fiber_asm_file_prefix "riscv64_sysv")
elseif(${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "s390x.*")
  set(fiber_cpu "s390x")
  set(fiber_asm_file_prefix "s390x_sysv")
elseif(${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "mips64.*")
  set(fiber_cpu "mips64")
  set(fiber_asm_file_prefix "mips64_n64")
elseif(${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "mips.*")
  set(fiber_cpu "mips32")
  set(fiber_asm_file_prefix "mips32_o32")
else()
  set(fiber_cpu "unknown")
  set(fiber_asm_file_prefix "unknown")
endif()

message(STATUS "fiber_cpu is set to ${fiber_cpu}")

message(STATUS "Checking for host operating system")

string(TOLOWER "${CMAKE_HOST_SYSTEM_NAME}" host_os)

if(${host_os} MATCHES "darwin.*")
  set(fiber_os "mac")
elseif(${host_os} MATCHES "aix.*|os400.*")
  set(fiber_os "aix")
elseif(${host_os} MATCHES "freebsd.*")
  set(fiber_os "freebsd")
else()
  set(fiber_os "other")
endif()

if(${fiber_os} STREQUAL "mac")
  set(fiber_asm_file "combined_sysv_macho_gas")
elseif(${fiber_os} STREQUAL "aix")
  # AIX uses a different calling convention (shared with non-_CALL_ELF Linux).
  # The AIX assembler isn't GNU, but the file is compatible.
  set(fiber_asm_file "${fiber_asm_file_prefix}_xcoff_gas")
elseif(${fiber_os} STREQUAL "freebsd")
  if(${fiber_cpu} STREQUAL "i386")
    set(FIBER_ASM OFF)
  else()
    set(fiber_asm_file "${fiber_asm_file_prefix}_elf_gas")
  endif()
elseif(NOT ${fiber_asm_file_prefix} STREQUAL "unknown")
  set(fiber_asm_file "${fiber_asm_file_prefix}_elf_gas")
else()
  set(FIBER_ASM OFF)
endif()

set(CMAKE_REQUIRED_LIBRARIES "c")
set(CMAKE_REQUIRED_DEFINITIONS "-D_GNU_SOURCE")

# Check whether syscall to create shadow stack exists, should be a better way, but...
message(STATUS "Whether syscall to create shadow stack exists")
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
" SYSCALL_SHADOW_STACK_EXISTS)

if(SYSCALL_SHADOW_STACK_EXISTS)
  message(STATUS "syscall to create shadow stack exists")
  set(SHADOW_STACK_SYSCALL 1)
else()
  # TODO: If the syscall doesn't exist, we may block the final ELF from __PROPERTY_SHSTK
  # via redefine macro as "-D__CET__=1"
  message(STATUS "syscall to create shadow stack does not exist")
endif()

if(FIBER_ASM)
  set(ZEND_FIBER_ASM 1)
else()
  if(${fiber_os} STREQUAL "mac")
    set(_XOPEN_SOURCE 1)
  endif()

  check_include_file(ucontext.h ZEND_FIBER_UCONTEXT)

  if(NOT ZEND_FIBER_UCONTEXT)
    message(FATAL_ERROR "Fibers are not available on this platform, ucontext.h not found")
  endif()
endif()
