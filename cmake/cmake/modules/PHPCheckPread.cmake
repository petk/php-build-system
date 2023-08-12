#[=============================================================================[
Checks whether pread() works.

The module sets the following variables:

``HAVE_PREAD``
  Set to 1 if pread() is available.
``PHP_PREAD_64``
  Set to 1 if pread64 is default.
]=============================================================================]#

include(CheckCSourceRuns)

message(STATUS "Checking whether pread() works")

function(php_check_pread)
  if(NOT CMAKE_CROSSCOMPILING)
    file(WRITE "${CMAKE_BINARY_DIR}/conftest_in" "test\n")

    check_c_source_runs("
      #include <sys/types.h>
      #include <sys/stat.h>
      #include <fcntl.h>
      #include <unistd.h>
      #include <errno.h>
      #include <stdlib.h>

      int main(void) {
        char buf[3];
        int fd = open(\"${CMAKE_BINARY_DIR}/conftest_in\", O_RDONLY);
        if (fd < 0) return 1;
        if (pread(fd, buf, 2, 0) != 2) return 1;
        /* Linux glibc breakage until 2.2.5 */
        if (pread(fd, buf, 2, -1) != -1 || errno != EINVAL) return 1;

        return 0;
      }
    " pread_works)

    file(REMOVE "${CMAKE_BINARY_DIR}/conftest_in")
  endif()

  if(NOT pread_works)
    if(NOT CMAKE_CROSSCOMPILING)
      file(WRITE "${CMAKE_BINARY_DIR}/conftest_in" "test\n")

      check_c_source_runs("
        #include <sys/types.h>
        #include <sys/stat.h>
        #include <fcntl.h>
        #include <unistd.h>
        #include <errno.h>
        #include <stdlib.h>

        ssize_t pread(int, void *, size_t, off64_t);

        int main(void) {
          char buf[3];
          int fd = open(\"${CMAKE_BINARY_DIR}/conftest_in\", O_RDONLY);
          if (fd < 0) return 1;
          if (pread(fd, buf, 2, 0) != 2) return 1;
          /* Linux glibc breakage until 2.2.5 */
          if (pread(fd, buf, 2, -1) != -1 || errno != EINVAL) return 1;

          return 0;
        }
      " pread64_works)

      file(REMOVE "${CMAKE_BINARY_DIR}/conftest_in")
    endif()
  endif()

  if(pread_works OR pread64_works)
    set(HAVE_PREAD 1 CACHE INTERNAL "Whether pread() works")
  endif()

  if(pread64_works)
    set(PHP_PREAD_64 1 CACHE INTERNAL "Whether pread64 is default")
  endif()
endfunction()

php_check_pread()
