#[=============================================================================[
Checks whether pwrite() works.

The module sets the following variables:

``HAVE_PWRITE``
  Set to 1 if pwrite() is available.
``PHP_PWRITE_64``
  Set to 1 if pwrite64 is default.
]=============================================================================]#

include(CheckCSourceRuns)

message(STATUS "Checking whether pwrite() works")

function(php_check_pwrite)
  if(NOT CMAKE_CROSSCOMPILING)
    check_c_source_runs("
      #include <sys/types.h>
      #include <sys/stat.h>
      #include <fcntl.h>
      #include <unistd.h>
      #include <errno.h>
      #include <stdlib.h>

      int main(void) {
        int fd = open(\"${CMAKE_BINARY_DIR}/conftest_in\", O_WRONLY|O_CREAT, 0600);

        if (fd < 0) return 1;
        if (pwrite(fd, \"text\", 4, 0) != 4) return 1;
        /* Linux glibc breakage until 2.2.5 */
        if (pwrite(fd, \"text\", 4, -1) != -1 || errno != EINVAL) return 1;

        return 0;
      }
    " pwrite_works)

    file(REMOVE "${CMAKE_BINARY_DIR}/conftest_in")
  endif()

  if(NOT pwrite_works)
    if(NOT CMAKE_CROSSCOMPILING)
      check_c_source_runs("
        #include <sys/types.h>
        #include <sys/stat.h>
        #include <fcntl.h>
        #include <unistd.h>
        #include <errno.h>
        #include <stdlib.h>

        ssize_t pwrite(int, void *, size_t, off64_t);

        int main(void) {
          int fd = open(\"${CMAKE_BINARY_DIR}/conftest_in\", O_WRONLY|O_CREAT, 0600);

          if (fd < 0) return 1;
          if (pwrite(fd, \"text\", 4, 0) != 4) return 1;
          /* Linux glibc breakage until 2.2.5 */
          if (pwrite(fd, \"text\", 4, -1) != -1 || errno != EINVAL) return 1;

          return 0;
        }
      " pwrite64_works)

      file(REMOVE "${CMAKE_BINARY_DIR}/conftest_in")
    endif()
  endif()

  if(pwrite_works OR pwrite64_works)
    set(HAVE_PWRITE 1 CACHE INTERNAL "Whether pwrite() works")
  endif()

  if(pwrite64_works)
    set(PHP_PWRITE_64 1 CACHE INTERNAL "Whether pwrite64 is default")
  endif()
endfunction()

php_check_pwrite()
