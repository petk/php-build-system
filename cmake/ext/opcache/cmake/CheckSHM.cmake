#[=============================================================================[
# CheckSHM

Check for shared memory (SHM) operations functions and required libraries.

If no SHM support is found, a FATAL error is thrown.

## Cache variables

* `HAVE_SHM_IPC`

  Whether SysV IPC SHM support is available.

* `HAVE_SHM_MMAP_ANON`

  Whether `mmap(MAP_ANON)` SHM support is found.

* `HAVE_SHM_MMAP_POSIX`

  Whether POSIX `mmap()` SHM support is found.

IMPORTED target:

* `PHP::CheckSHMLibrary`

  If there is additional library to be linked for using SHM POSIX functions.

## Usage

```cmake
# CMakeLists.txt
include(cmake/CheckSHM.cmake)
```
#]=============================================================================]

include_guard(GLOBAL)

include(CheckSourceRuns)
include(CMakePushCheckState)
include(PHP/SearchLibraries)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

################################################################################
# Check for for SysV IPC SHM.
################################################################################

message(CHECK_START "Checking for SysV IPC SHM (shared memory) support")

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)

  check_source_runs(C [[
    #include <sys/types.h>
    #include <sys/wait.h>
    #include <sys/ipc.h>
    #include <sys/shm.h>
    #include <unistd.h>
    #include <string.h>

    int main(void)
    {
      pid_t pid;
      int status;
      int ipc_id;
      char *shm;
      struct shmid_ds shmbuf;

      ipc_id = shmget(IPC_PRIVATE, 4096, (IPC_CREAT | SHM_R | SHM_W));
      if (ipc_id == -1) {
        return 1;
      }

      shm = shmat(ipc_id, NULL, 0);
      if (shm == (void *)-1) {
        shmctl(ipc_id, IPC_RMID, NULL);
        return 2;
      }

      if (shmctl(ipc_id, IPC_STAT, &shmbuf) != 0) {
        shmdt(shm);
        shmctl(ipc_id, IPC_RMID, NULL);
        return 3;
      }

      shmbuf.shm_perm.uid = getuid();
      shmbuf.shm_perm.gid = getgid();
      shmbuf.shm_perm.mode = 0600;

      if (shmctl(ipc_id, IPC_SET, &shmbuf) != 0) {
        shmdt(shm);
        shmctl(ipc_id, IPC_RMID, NULL);
        return 4;
      }

      shmctl(ipc_id, IPC_RMID, NULL);

      strcpy(shm, "hello");

      pid = fork();
      if (pid < 0) {
        return 5;
      } else if (pid == 0) {
        strcpy(shm, "bye");
        return 6;
      }
      if (wait(&status) != pid) {
        return 7;
      }
      if (!WIFEXITED(status) || WEXITSTATUS(status) != 6) {
        return 8;
      }
      if (strcmp(shm, "bye") != 0) {
        return 9;
      }
      return 0;
    }
  ]] HAVE_SHM_IPC)
cmake_pop_check_state()

if(HAVE_SHM_IPC)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

################################################################################
# Check for mmap() using MAP_ANON SHM.
################################################################################

message(CHECK_START "Checking for mmap() using MAP_ANON shared memory support")

if(
  NOT DEFINED HAVE_SHM_MMAP_ANON_EXITCODE
  AND CMAKE_CROSSCOMPILING
  AND NOT CMAKE_CROSSCOMPILING_EMULATOR
  AND CMAKE_SYSTEM_NAME STREQUAL "Linux"
)
  set(HAVE_SHM_MMAP_ANON_EXITCODE 0)
endif()

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)

  check_source_runs(C [[
    #include <sys/types.h>
    #include <sys/wait.h>
    #include <sys/mman.h>
    #include <unistd.h>
    #include <string.h>

    #ifndef MAP_ANON
    # ifdef MAP_ANONYMOUS
    #  define MAP_ANON MAP_ANONYMOUS
    # endif
    #endif
    #ifndef MAP_FAILED
    # define MAP_FAILED ((void*)-1)
    #endif

    int main(void)
    {
      pid_t pid;
      int status;
      char *shm;

      shm = mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_SHARED | MAP_ANON, -1, 0);
      if (shm == MAP_FAILED) {
        return 1;
      }

      strcpy(shm, "hello");

      pid = fork();
      if (pid < 0) {
        return 5;
      } else if (pid == 0) {
        strcpy(shm, "bye");
        return 6;
      }
      if (wait(&status) != pid) {
        return 7;
      }
      if (!WIFEXITED(status) || WEXITSTATUS(status) != 6) {
        return 8;
      }
      if (strcmp(shm, "bye") != 0) {
        return 9;
      }
      return 0;
    }
  ]] HAVE_SHM_MMAP_ANON)
cmake_pop_check_state()

if(HAVE_SHM_MMAP_ANON)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

################################################################################
# Check for mmap() using shm_open() SHM.
################################################################################

message(CHECK_START "Checking for mmap() using shm_open() shared memory support")

# Check for POSIX shared memory functions (shm_open(), shm_unlink()...) and link
# required library as needed. Most systems have them in the C library: newer
# Linux, Solaris 11.4, illumos, macOS, BSD-based systems, etc. Haiku has them in
# the C library called root, which is linked by default when using compilers on
# Haiku.
php_search_libraries(
  shm_open
  HEADERS sys/mman.h
  LIBRARIES
    rt # Solaris <= 10, older Linux
  VARIABLE PHP_HAS_SHM_OPEN
  LIBRARY_VARIABLE libraryForShmOpen
)

if(PHP_HAS_SHM_OPEN)
  cmake_push_check_state(RESET)
    if(libraryForShmOpen)
      set(CMAKE_REQUIRED_LIBRARIES ${libraryForShmOpen})
    endif()

    check_source_runs(C [[
      #include <sys/types.h>
      #include <sys/wait.h>
      #include <sys/mman.h>
      #include <sys/stat.h>
      #include <fcntl.h>
      #include <unistd.h>
      #include <string.h>
      #include <stdlib.h>
      #include <stdio.h>

      #ifndef MAP_FAILED
      # define MAP_FAILED ((void*)-1)
      #endif

      int main(void)
      {
        pid_t pid;
        int status;
        int fd;
        char *shm;
        char tmpname[4096];

        sprintf(tmpname,"/opcache.test.shm.%dXXXXXX", getpid());
        if (mktemp(tmpname) == NULL) {
          return 1;
        }
        fd = shm_open(tmpname, O_RDWR | O_CREAT, S_IRUSR | S_IWUSR);
        if (fd == -1) {
          return 2;
        }
        if (ftruncate(fd, 4096) < 0) {
          close(fd);
          shm_unlink(tmpname);
          return 3;
        }

        shm = mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
        if (shm == MAP_FAILED) {
          return 4;
        }
        shm_unlink(tmpname);
        close(fd);

        strcpy(shm, "hello");

        pid = fork();
        if (pid < 0) {
          return 5;
        } else if (pid == 0) {
          strcpy(shm, "bye");
          return 6;
        }
        if (wait(&status) != pid) {
          return 7;
        }
        if (!WIFEXITED(status) || WEXITSTATUS(status) != 6) {
          return 8;
        }
        if (strcmp(shm, "bye") != 0) {
          return 9;
        }
        return 0;
      }
    ]] HAVE_SHM_MMAP_POSIX)
  cmake_pop_check_state()
endif()

if(HAVE_SHM_MMAP_POSIX)
  if(libraryForShmOpen)
    add_library(PHP::CheckSHMLibrary INTERFACE IMPORTED GLOBAL)
    target_link_libraries(PHP::CheckSHMLibrary INTERFACE ${libraryForShmOpen})
  endif()
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

if(NOT HAVE_SHM_IPC AND NOT HAVE_SHM_MMAP_ANON AND NOT HAVE_SHM_MMAP_POSIX)
  message(
    FATAL_ERROR
    "No supported shared memory caching support was found when configuring "
    "opcache extension."
  )
endif()
