#[=============================================================================[
Check for mmap() using MAP_ANON shared memory support.

Cache variables:

  HAVE_SHM_MMAP_ANON
    Set to 1 if mmap(MAP_ANON) SHM support is found.
]=============================================================================]#

include(CheckCSourceRuns)

message(CHECK_START "Checking for mmap() using MAP_ANON shared memory support")

list(APPEND CMAKE_MESSAGE_INDENT "  ")

if(NOT CMAKE_CROSSCOMPILING)
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
  " HAVE_SHM_MMAP_ANON)
elseif(CMAKE_CROSSCOMPILING AND CMAKE_SYSTEM_NAME STREQUAL "Linux")
  set(
    HAVE_SHM_MMAP_ANON 1
    CACHE INTERNAL "Whether mmap(MAP_ANON) SHM support is available"
  )
endif()

list(POP_BACK CMAKE_MESSAGE_INDENT)

if(HAVE_SHM_MMAP_ANON)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
