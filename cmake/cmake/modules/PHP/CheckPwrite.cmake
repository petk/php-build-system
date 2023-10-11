#[=============================================================================[
Check whether pwrite() works.

The module sets the following variables:

HAVE_PWRITE
  Set to 1 if pwrite() is available.
PHP_PWRITE_64
  Set to 1 if pwrite64 is default.
]=============================================================================]#

include(CheckCSourceRuns)

message(STATUS "Checking whether pwrite() works")

function(_php_check_pwrite)
  if(NOT CMAKE_CROSSCOMPILING)
    check_c_source_runs("
      #include <sys/types.h>
      #include <sys/stat.h>
      #include <fcntl.h>
      #include <unistd.h>
      #include <errno.h>
      #include <stdlib.h>

      int main(void) {
        int fd = open(\"${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/php_check_pwrite\", O_WRONLY|O_CREAT, 0600);

        if (fd < 0) return 1;
        if (pwrite(fd, \"text\", 4, 0) != 4) return 1;
        /* Linux glibc breakage until 2.2.5 */
        if (pwrite(fd, \"text\", 4, -1) != -1 || errno != EINVAL) return 1;

        return 0;
      }
    " pwrite_works)
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
          int fd = open(\"${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/php_check_pwrite64\", O_WRONLY|O_CREAT, 0600);

          if (fd < 0) return 1;
          if (pwrite(fd, \"text\", 4, 0) != 4) return 1;
          /* Linux glibc breakage until 2.2.5 */
          if (pwrite(fd, \"text\", 4, -1) != -1 || errno != EINVAL) return 1;

          return 0;
        }
      " PHP_PWRITE_64)
    endif()
  endif()

  if(pwrite_works OR PHP_PWRITE_64)
    set(HAVE_PWRITE 1 CACHE INTERNAL "Whether pwrite() works")
  endif()
endfunction()

_php_check_pwrite()
