#[=============================================================================[
Checks for shared memory (SHM) operations functions and required libraries.
If no SHM support is found, a FATAL error is thrown.

Result variables:

* HAVE_SHM_IPC - Whether SysV IPC SHM support is available.
* HAVE_SHM_MMAP_ANON - Whether mmap(MAP_ANON) SHM support is found.
* HAVE_SHM_MMAP_POSIX - Whether POSIX mmap() SHM support is found.
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

function(_php_ext_opcache_check_shm_ipc result)
  set(${result} FALSE)

  if(DEFINED PHP_EXT_OPCACHE_HAS_SHM_IPC)
    if(PHP_EXT_OPCACHE_HAS_SHM_IPC)
      set(${result} TRUE)
    endif()

    return(PROPAGATE ${result})
  endif()

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
    ]] PHP_EXT_OPCACHE_HAS_SHM_IPC)
  cmake_pop_check_state()

  if(PHP_EXT_OPCACHE_HAS_SHM_IPC)
    set(${result} TRUE)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()

  return(PROPAGATE ${result})
endfunction()

################################################################################
# Check for mmap() using MAP_ANON SHM.
################################################################################

function(_php_ext_opcache_check_shm_mmap_anon result)
  set(${result} FALSE)

  if(DEFINED PHP_EXT_OPCACHE_HAS_SHM_MMAP_ANON)
    if(PHP_EXT_OPCACHE_HAS_SHM_MMAP_ANON)
      set(${result} TRUE)
    endif()

    return(PROPAGATE ${result})
  endif()

  message(CHECK_START "Checking for mmap() with MAP_ANON shared memory support")

  if(
    CMAKE_CROSSCOMPILING
    AND NOT CMAKE_CROSSCOMPILING_EMULATOR
    AND NOT DEFINED PHP_EXT_OPCACHE_HAS_SHM_MMAP_ANON_EXITCODE
    AND CMAKE_SYSTEM_NAME MATCHES "^(Linux|Midipix)$"
  )
    set(PHP_EXT_OPCACHE_HAS_SHM_MMAP_ANON_EXITCODE 0)
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
    ]] PHP_EXT_OPCACHE_HAS_SHM_MMAP_ANON)
  cmake_pop_check_state()

  if(PHP_EXT_OPCACHE_HAS_SHM_MMAP_ANON)
    set(${result} TRUE)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()

  return(PROPAGATE ${result})
endfunction()

################################################################################
# Check for mmap() using shm_open() SHM.
################################################################################

function(_php_ext_opcache_check_shm_open result)
  set(${result} FALSE)

  # Check for POSIX shared memory functions (shm_open(), shm_unlink()...) and
  # link required library as needed. Most systems have them in the C library:
  # newer Linux, Solaris 11.4, illumos, macOS, BSD-based systems, etc. Haiku has
  # them in the C library called root, which is linked by default when using
  # compilers on Haiku.
  php_search_libraries(
    shm_open
    HEADERS sys/mman.h
    LIBRARIES
      rt # Solaris <= 10, older Linux
    VARIABLE PHP_EXT_OPCACHE_HAS_SHM_OPEN
    LIBRARY_VARIABLE PHP_EXT_OPCACHE_HAS_SHM_OPEN_LIBRARY
  )

  if(PHP_EXT_OPCACHE_HAS_SHM_OPEN_LIBRARY)
    target_link_libraries(
      php_ext_opcache
      PRIVATE ${PHP_EXT_OPCACHE_HAS_SHM_OPEN_LIBRARY}
    )
  endif()

  if(DEFINED PHP_EXT_OPCACHE_HAS_SHM_MMAP_POSIX)
    if(PHP_EXT_OPCACHE_HAS_SHM_MMAP_POSIX)
      set(${result} TRUE)
    endif()

    return(PROPAGATE ${result})
  endif()

  if(PHP_EXT_OPCACHE_HAS_SHM_OPEN)
    message(CHECK_START "Checking for mmap() with shm_open() shared memory support")
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
      ]] PHP_EXT_OPCACHE_HAS_SHM_MMAP_POSIX)
    cmake_pop_check_state()
  endif()

  if(PHP_EXT_OPCACHE_HAS_SHM_MMAP_POSIX)
    set(${result} TRUE)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()

  return(PROPAGATE ${result})
endfunction()

_php_ext_opcache_check_shm_ipc(HAVE_SHM_IPC)
_php_ext_opcache_check_shm_mmap_anon(HAVE_SHM_MMAP_ANON)
_php_ext_opcache_check_shm_open(HAVE_SHM_MMAP_POSIX)

if(NOT HAVE_SHM_IPC AND NOT HAVE_SHM_MMAP_ANON AND NOT HAVE_SHM_MMAP_POSIX)
  message(
    FATAL_ERROR
    "No supported shared memory caching support was found when configuring "
    "opcache extension."
  )
endif()
