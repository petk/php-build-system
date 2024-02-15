#[=============================================================================[
Check whether pread() works.

Cache variables:

  HAVE_PREAD
    Whether pread() is available.
  PHP_PREAD_64
    Whether pread64 is default.
]=============================================================================]#

include_guard(GLOBAL)

include(CheckSourceRuns)
include(CMakePushCheckState)

message(CHECK_START "Checking whether pread() works")

if(NOT CMAKE_CROSSCOMPILING)
  set(
    _php_check_pread_file
    "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/php_check_pread"
  )

  file(WRITE "${_php_check_pread_file}" "test\n")

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)
    check_source_runs(C "
      #include <sys/types.h>
      #include <sys/stat.h>
      #include <fcntl.h>
      #include <unistd.h>
      #include <errno.h>
      #include <stdlib.h>

      int main(void) {
        char buf[3];
        int fd = open(\"${_php_check_pread_file}\", O_RDONLY);
        if (fd < 0) return 1;
        if (pread(fd, buf, 2, 0) != 2) return 1;
        /* Linux glibc breakage until 2.2.5 */
        if (pread(fd, buf, 2, -1) != -1 || errno != EINVAL) return 1;

        return 0;
      }
    " HAVE_PREAD)
  cmake_pop_check_state()
endif()

if(NOT HAVE_PREAD AND NOT CMAKE_CROSSCOMPILING)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)
    check_source_runs(C "
      #include <sys/types.h>
      #include <sys/stat.h>
      #include <fcntl.h>
      #include <unistd.h>
      #include <errno.h>
      #include <stdlib.h>

      ssize_t pread(int, void *, size_t, off64_t);

      int main(void) {
        char buf[3];
        int fd = open(\"${_php_check_pread_file}\", O_RDONLY);
        if (fd < 0) return 1;
        if (pread(fd, buf, 2, 0) != 2) return 1;
        /* Linux glibc breakage until 2.2.5 */
        if (pread(fd, buf, 2, -1) != -1 || errno != EINVAL) return 1;

        return 0;
      }
    " PHP_PREAD_64)
  cmake_pop_check_state()

  if(PHP_PREAD_64)
    set(HAVE_PREAD 1 CACHE INTERNAL "Whether pread() works")
  endif()
endif()

if(HAVE_PREAD)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

unset(_php_check_pread_file)
