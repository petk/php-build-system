#[=============================================================================[
Checks for mmap() using shm_open() shared memory support.

The module defines the following variables if support is found:

``HAVE_SHM_MMAP_POSIX``
  Defined to 1 if POSIX mmap() SHM support is found.
]=============================================================================]#
include(CheckCSourceRuns)

# TODO: add PHP_CHECK_FUNC_LIB(shm_open, rt, root)

message(STATUS "Checking for mmap() using shm_open() shared memory support")

if(CMAKE_CROSSCOMPILING)
  message(STATUS "no")
else()
  check_c_source_compiles("
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
  " have_shm_mmap_posix)

  if(have_shm_mmap_posix)
    message(STATUS "yes")
    set(HAVE_SHM_MMAP_POSIX 1 CACHE STRING "Define if you have POSIX mmap() SHM support")
    # TODO: Add PHP_CHECK_LIBRARY(rt, shm_unlink, [PHP_ADD_LIBRARY(rt,1,OPCACHE_SHARED_LIBADD)])
  else()
    message(STATUS "no")
  endif()
endif()
