#[=============================================================================[
Check for ptrace().

Result variables:

  PHP_TRACE_TYPE
    Name of the trace type that should be used in FPM.

Cache variables:

  HAVE_PTRACE
    Whether ptrace() is present and working as expected.
  HAVE_MACH_VM_READ
    Whether ptrace() didn't work and the mach_vm_read() is present.
  PROC_MEM_FILE
    String of the /proc/pid/mem interface.
]=============================================================================]#

include_guard(GLOBAL)

include(CheckSourceCompiles)
include(CheckSourceRuns)
include(CheckSymbolExists)
include(CMakePushCheckState)

check_symbol_exists(ptrace "sys/ptrace.h" _have_ptrace)

if(_have_ptrace)
  message(CHECK_START "Checking whether ptrace works")

  if(NOT CMAKE_CROSSCOMPILING)
    check_source_runs(C [[
      #include <unistd.h>
      #include <signal.h>
      #include <sys/wait.h>
      #include <sys/types.h>
      #include <sys/ptrace.h>
      #include <errno.h>

      #if !defined(PTRACE_ATTACH) && defined(PT_ATTACH)
      #define PTRACE_ATTACH PT_ATTACH
      #endif

      #if !defined(PTRACE_DETACH) && defined(PT_DETACH)
      #define PTRACE_DETACH PT_DETACH
      #endif

      #if !defined(PTRACE_PEEKDATA) && defined(PT_READ_D)
      #define PTRACE_PEEKDATA PT_READ_D
      #endif

      int main(void) {
        /* copy will fail if sizeof(long) == 8 and we've got "int ptrace()" */
        long v1 = (unsigned int) -1;
        long v2;
        pid_t child;
        int status;

        if ( (child = fork()) ) { /* parent */
          int ret = 0;

          if (0 > ptrace(PTRACE_ATTACH, child, 0, 0)) {
            return 2;
          }

          waitpid(child, &status, 0);

      #ifdef PT_IO
          struct ptrace_io_desc ptio = {
            .piod_op = PIOD_READ_D,
            .piod_offs = &v1,
            .piod_addr = &v2,
            .piod_len = sizeof(v1)
          };

          if (0 > ptrace(PT_IO, child, (void *) &ptio, 0)) {
            ret = 3;
          }
      #else
          errno = 0;

          v2 = ptrace(PTRACE_PEEKDATA, child, (void *) &v1, 0);

          if (errno) {
            ret = 4;
          }
      #endif
          ptrace(PTRACE_DETACH, child, (void *) 1, 0);

          kill(child, SIGKILL);

          return ret ? ret : (v1 != v2);
        } else { /* child */
          sleep(10);
          return 0;
        }
      }
    ]] HAVE_PTRACE)
  else()
    set(HAVE_PTRACE 1 CACHE INTERNAL "Whether ptrace() is present and works")
  endif()

  if(HAVE_PTRACE)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
endif()

if(NOT HAVE_PTRACE)
  check_source_compiles(C [[
    #include <mach/mach.h>
    #include <mach/mach_vm.h>

    int main(void) {
      mach_vm_read((vm_map_t)0, (mach_vm_address_t)0, (mach_vm_size_t)0, (vm_offset_t *)0, (mach_msg_type_number_t*)0);
      return 0;
    }
  ]] HAVE_MACH_VM_READ)
endif()

# TODO: Check if /proc/self is sufficient location instead of the /proc/$$ as in
# Autoconf.
message(CHECK_START "Checking for proc mem file")
if(EXISTS /proc/self/mem)
  set(_php_proc_mem_file "mem")
elseif(EXISTS /proc/self/as)
  set(_php_proc_mem_file "as")
endif()

if(_php_proc_mem_file)
  if(NOT CMAKE_CROSSCOMPILING)
    check_source_runs(C "
      #ifndef _GNU_SOURCE
      #define _GNU_SOURCE
      #endif
      #define _FILE_OFFSET_BITS 64
      #include <stdint.h>
      #include <unistd.h>
      #include <sys/types.h>
      #include <sys/stat.h>
      #include <fcntl.h>
      #include <stdio.h>

      int main(void) {
        long v1 = (unsigned int) -1, v2 = 0;
        char buf[128];
        int fd;
        sprintf(buf, \"/proc/%d/${_php_proc_mem_file}\", getpid());
        fd = open(buf, O_RDONLY);
        if (0 > fd) {
          return 1;
        }
        if (sizeof(long) != pread(fd, &v2, sizeof(long), (uintptr_t) &v1)) {
          close(fd);
          return 1;
        }
        close(fd);
        return v1 != v2;
      }
    " _php_proc_mem_successful)
  endif()
endif()

if(_php_proc_mem_file AND _php_proc_mem_successful)
  set(
    PROC_MEM_FILE "${_php_proc_mem_file}"
    CACHE INTERNAL "/proc/pid/mem interface"
  )
endif()

if(HAVE_PTRACE)
  set(PHP_TRACE_TYPE "ptrace")
elseif(_php_proc_mem_file)
  set(PHP_TRACE_TYPE "pread")
elseif(HAVE_MACH_VM_READ)
  set(PHP_TRACE_TYPE "mach")
endif()

if(PHP_TRACE_TYPE)
  message(CHECK_PASS "${PHP_TRACE_TYPE}")
else()
  message(CHECK_FAIL "not found")
  message(WARNING "FPM Trace - ptrace, pread, or mach: could not be found")
endif()
