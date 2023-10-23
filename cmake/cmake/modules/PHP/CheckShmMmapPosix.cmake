#[=============================================================================[
Check for mmap() using shm_open() shared memory support.

The module sets the following variables if support is found:

HAVE_SHM_MMAP_POSIX
  Set to 1 if POSIX mmap() SHM support is found.

SHM_MMAP_POSIX_REQUIRED_LIBRARIES
  Required libraries that needs to be appended to the shared extension target.
]=============================================================================]#

include(CheckCSourceRuns)
include(CheckLibraryExists)
include(CheckSymbolExists)
include(CMakePushCheckState)

message(STATUS "Checking for mmap() using shm_open() shared memory support")

# First, check for shm_open() and link required libraries.
check_symbol_exists(shm_open sys/mman.h HAVE_SHM_OPEN)

if(NOT HAVE_SHM_OPEN)
  # Check if librt library is required for shm_open to work.
  check_library_exists(rt shm_open "" HAVE_SHM_OPEN)

  if(HAVE_SHM_OPEN)
    set(SHM_OPEN_REQUIRED_LIBRARIES "rt")
  endif()

  # Check for Haiku system where shm_open is available with libroot library.
  check_library_exists(root shm_open "" HAVE_SHM_OPEN)

  if(HAVE_SHM_OPEN)
    set(SHM_OPEN_REQUIRED_LIBRARIES "root")
  endif()
endif()

# Append the required libraries to EXTRA_LIBS.
if(SHM_OPEN_REQUIRED_LIBRARIES)
  set(EXTRA_LIBS ${EXTRA_LIBS} ${SHM_OPEN_REQUIRED_LIBRARIES})
endif()

if(NOT CMAKE_CROSSCOMPILING)
  cmake_push_check_state(RESET)
    if(SHM_OPEN_REQUIRED_LIBRARIES)
      set(CMAKE_REQUIRED_LIBRARIES ${SHM_OPEN_REQUIRED_LIBRARIES})
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
  check_symbol_exists(shm_unlink "sys/mman.h" HAVE_SHM_UNLINK)
  if(NOT HAVE_SHM_UNLINK)
    check_library_exists(rt shm_unlink "" HAVE_SHM_UNLINK)

    if(HAVE_SHM_UNLINK)
      set(SHM_MMAP_POSIX_REQUIRED_LIBRARIES "rt")
    endif()
  endif()
endif()
