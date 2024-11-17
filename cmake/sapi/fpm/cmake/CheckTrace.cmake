#[=============================================================================[
Check FPM trace implementation.

## Cache variables

* `HAVE_PTRACE`

  Whether `ptrace()` is present and working as expected.

* `HAVE_MACH_VM_READ`

  Whether `ptrace()` didn't work and the `mach_vm_read()` is present.

## Result variables

* `PROC_MEM_FILE`

  If neither `ptrace()` or mach_vm_read()` works, the `/proc/pid/<file>`
  interface (`mem` or `as`) is set if found and works as expected.
#]=============================================================================]

include_guard(GLOBAL)

include(CheckSourceCompiles)
include(CheckSourceRuns)
include(CheckSymbolExists)
include(CMakePushCheckState)

message(CHECK_START "Checking FPM trace implementation")

message(CHECK_START "Checking whether ptrace works")

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_source_compiles(C [[
    #include <sys/types.h>
    #include <sys/ptrace.h>

    int main(void)
    {
      ptrace(0, 0, (void *) 0, 0);
      return 0;
    }
  ]] _HAVE_PTRACE)
cmake_pop_check_state()

if(_HAVE_PTRACE)
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
    ]] HAVE_PTRACE)
  cmake_pop_check_state()
endif()

if(HAVE_PTRACE)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

if(NOT HAVE_PTRACE)
  check_symbol_exists(mach_vm_read "mach/mach.h;mach/mach_vm.h" HAVE_MACH_VM_READ)
endif()

if(NOT HAVE_PTRACE AND NOT HAVE_MACH_VM_READ)
  message(CHECK_START "Checking for process memory access file")

  if(NOT CMAKE_CROSSCOMPILING)
    set(PROC_MEM_FILE)
    if(EXISTS /proc/self/mem)
      set(PROC_MEM_FILE "mem")
    elseif(EXISTS /proc/self/as)
      set(PROC_MEM_FILE "as")
    endif()

    if(PROC_MEM_FILE)
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
            sprintf(buf, \"/proc/%d/${PROC_MEM_FILE}\", getpid());
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
        " _HAVE_PROC_MEM_FILE)
      cmake_pop_check_state()

      if(NOT _HAVE_PROC_MEM_FILE)
        unset(PROC_MEM_FILE)
      endif()
    endif()
  endif()

  if(PROC_MEM_FILE)
    message(CHECK_PASS "yes (${PROC_MEM_FILE})")
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
