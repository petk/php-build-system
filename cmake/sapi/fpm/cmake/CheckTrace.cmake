#[=============================================================================[
Check FPM trace implementation.

Result variables:

* HAVE_PTRACE
* HAVE_MACH_VM_READ
* PROC_MEM_FILE
#]=============================================================================]

include(CheckSourceRuns)
include(CheckSymbolExists)
include(CMakePushCheckState)

set(HAVE_PTRACE FALSE)
set(HAVE_MACH_VM_READ FALSE)

message(CHECK_START "Checking FPM trace implementation")

message(CHECK_START "Checking whether ptrace works")

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_source_runs(C [[
    #include <unistd.h>
    #include <signal.h>
    #include <sys/wait.h>
    #include <sys/types.h>
    #include <sys/ptrace.h>
    #include <errno.h>

    #if !defined(PTRACE_ATTACH) && defined(PT_ATTACH)
    # define PTRACE_ATTACH PT_ATTACH
    #endif

    #if !defined(PTRACE_DETACH) && defined(PT_DETACH)
    # define PTRACE_DETACH PT_DETACH
    #endif

    #if !defined(PTRACE_PEEKDATA) && defined(PT_READ_D)
    # define PTRACE_PEEKDATA PT_READ_D
    #endif

    int main(void)
    {
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
  ]] PHP_SAPI_FPM_HAS_PTRACE)
cmake_pop_check_state()

if(PHP_SAPI_FPM_HAS_PTRACE)
  message(CHECK_PASS "yes")
  set(HAVE_PTRACE TRUE)
else()
  message(CHECK_FAIL "no")
  check_symbol_exists(
    mach_vm_read
    "mach/mach.h;mach/mach_vm.h"
    PHP_SAPI_FPM_HAS_MACH_VM_READ
  )
  if(PHP_SAPI_FPM_HAS_MACH_VM_READ)
    set(HAVE_MACH_VM_READ TRUE)
  endif()
endif()

if(NOT PHP_SAPI_FPM_HAS_PTRACE AND NOT PHP_SAPI_FPM_HAS_MACH_VM_READ)
  message(CHECK_START "Checking for process memory access file")

  if(NOT CMAKE_CROSSCOMPILING)
    if(NOT DEFINED PHP_SAPI_FPM_PROC_MEM_FILE)
      if(EXISTS /proc/self/mem)
        set(PHP_SAPI_FPM_PROC_MEM_FILE "mem")
      elseif(EXISTS /proc/self/as)
        set(PHP_SAPI_FPM_PROC_MEM_FILE "as")
      endif()
    endif()

    if(PHP_SAPI_FPM_PROC_MEM_FILE)
      cmake_push_check_state(RESET)
        set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
        set(CMAKE_REQUIRED_QUIET TRUE)
        check_source_runs(C "
          #define _FILE_OFFSET_BITS 64
          #include <stdint.h>
          #include <unistd.h>
          #include <sys/types.h>
          #include <sys/stat.h>
          #include <fcntl.h>
          #include <stdio.h>

          int main(void)
          {
            long v1 = (unsigned int) -1, v2 = 0;
            char buf[128];
            int fd;
            sprintf(buf, \"/proc/%d/${PHP_SAPI_FPM_PROC_MEM_FILE}\", getpid());
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
        " PHP_HAS_PROC_MEM_FILE)
      cmake_pop_check_state()

      if(NOT PHP_HAS_PROC_MEM_FILE)
        unset(PHP_SAPI_FPM_PROC_MEM_FILE)
      endif()
    endif()
  endif()

  if(PHP_SAPI_FPM_PROC_MEM_FILE)
    message(CHECK_PASS "yes (${PHP_SAPI_FPM_PROC_MEM_FILE})")
    set(PROC_MEM_FILE "${PHP_SAPI_FPM_PROC_MEM_FILE}")
  else()
    message(CHECK_FAIL "no")
  endif()
endif()

if(HAVE_PTRACE)
  message(CHECK_PASS "found (ptrace)")
elseif(HAVE_MACH_VM_READ)
  message(CHECK_PASS "found (mach)")
elseif(PROC_MEM_FILE)
  message(CHECK_PASS "found (pread)")
else()
  message(CHECK_FAIL "not found, FPM trace implementation is disabled")
endif()
