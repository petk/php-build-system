#[=============================================================================[
Checks for mmap() using MAP_ANON shared memory support.

The module defines the following variables if support is found:

HAVE_SHM_MMAP_ANON
  Defined to 1 if mmap(MAP_ANON) SHM support is found.
]=============================================================================]#
include(CheckCSourceRuns)

message(STATUS "Checking for mmap() using MAP_ANON shared memory support")

if(CMAKE_CROSSCOMPILING)
  if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(_have_shm_mmap_anon ON)
  else()
    set(_have_shm_mmap_anon OFF)
  endif()
else()
  check_c_source_runs("
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

    int main(void) {
      pid_t pid;
      int status;
      char *shm;

      shm = mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_SHARED | MAP_ANON, -1, 0);
      if (shm == MAP_FAILED) {
        return 1;
      }

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
  " _have_shm_mmap_anon)
endif()

if(_have_shm_mmap_anon)
  set(HAVE_SHM_MMAP_ANON 1 CACHE INTERNAL "Define if you have mmap(MAP_ANON) SHM support")
  message(STATUS "yes")
else()
  message(STATUS "no")
endif()

unset(_have_shm_mmap_anon)
