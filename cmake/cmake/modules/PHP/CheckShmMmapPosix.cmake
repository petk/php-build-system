#[=============================================================================[
Check for mmap() using shm_open() shared memory support.

Cache variables:

  HAVE_SHM_MMAP_POSIX
    Whether POSIX mmap() SHM support is found.

Interface library:

  PHP::CheckShmMmapPosix
    If there are additional libraries that need to be linked.
]=============================================================================]#

include_guard(GLOBAL)

include(CheckCSourceRuns)
include(CheckLibraryExists)
include(CheckSymbolExists)
include(CMakePushCheckState)
include(PHP/SearchLibraries)

message(CHECK_START "Checking for mmap() using shm_open() shared memory support")

# First, check for shm_open() and link required libraries.
php_search_libraries(
  shm_open
  "sys/mman.h"
  HAVE_SHM_OPEN
  SHM_OPEN_LIBRARY
  LIBRARIES
    rt
    root # Haiku system has shm_open in root library.
)

if(SHM_OPEN_LIBRARY)
  add_library(php_check_shm_mmap_posix INTERFACE)
  add_library(PHP::CheckShmMmapPosix ALIAS php_check_shm_mmap_posix)

  target_link_libraries(php_check_shm_mmap_posix INTERFACE ${SHM_OPEN_LIBRARY})
endif()

if(NOT CMAKE_CROSSCOMPILING)
  cmake_push_check_state(RESET)
    if(TARGET PHP::CheckShmMmapPosix)
      set(CMAKE_REQUIRED_LIBRARIES PHP::CheckShmMmapPosix)
    endif()

    check_c_source_runs("
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

      int main(void) {
        pid_t pid;
        int status;
        int fd;
        char *shm;
        char tmpname[4096];

        sprintf(tmpname,\"/opcache.test.shm.%dXXXXXX\", getpid());
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

        strcpy(shm, \"hello\");

        pid = fork();
        if (pid < 0) {
          return 5;
        } else if (pid == 0) {
          strcpy(shm, \"bye\");
          return 6;
        }
        if (wait(&status) != pid) {
          return 7;
        }
        if (!WIFEXITED(status) || WEXITSTATUS(status) != 6) {
          return 8;
        }
        if (strcmp(shm, \"bye\") != 0) {
          return 9;
        }
        return 0;
      }
    " HAVE_SHM_MMAP_POSIX)
  cmake_pop_check_state()
endif()

if(HAVE_SHM_MMAP_POSIX)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
