#[=============================================================================[
Check whether pwrite() works.

Cache variables:

  HAVE_PWRITE
    Whether pwrite() is available.
  PHP_PWRITE_64
    Whether pwrite64 is default.
]=============================================================================]#

include_guard(GLOBAL)

include(CheckSourceRuns)
include(CMakePushCheckState)

message(CHECK_START "Checking whether pwrite() works")

if(NOT CMAKE_CROSSCOMPILING)
  set(
    _php_check_pwrite_file
    "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/php_check_pwrite"
  )

  cmake_push_check_state(RESET)
    cmake_language(GET_MESSAGE_LOG_LEVEL log_level)
    if(NOT log_level IN_LIST "VERBOSE;DEBUG;TRACE")
      set(CMAKE_REQUIRED_QUIET TRUE)
    endif()
    check_source_runs(C "
      #include <sys/types.h>
      #include <sys/stat.h>
      #include <fcntl.h>
      #include <unistd.h>
      #include <errno.h>
      #include <stdlib.h>

      int main(void) {
        int fd = open(\"${_php_check_pwrite_file}\", O_WRONLY|O_CREAT, 0600);

        if (fd < 0) return 1;
        if (pwrite(fd, \"text\", 4, 0) != 4) return 1;
        /* Linux glibc breakage until 2.2.5 */
        if (pwrite(fd, \"text\", 4, -1) != -1 || errno != EINVAL) return 1;

        return 0;
      }
    " HAVE_PWRITE)
  cmake_pop_check_state()
endif()

if(NOT HAVE_PWRITE AND NOT CMAKE_CROSSCOMPILING)
  set(
    _php_check_pwrite_file
    "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/php_check_pwrite64"
  )

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)
    check_source_runs(C "
      #include <sys/types.h>
      #include <sys/stat.h>
      #include <fcntl.h>
      #include <unistd.h>
      #include <errno.h>
      #include <stdlib.h>

      ssize_t pwrite(int, void *, size_t, off64_t);

      int main(void) {
        int fd = open(\"${_php_check_pwrite_file}\", O_WRONLY|O_CREAT, 0600);

        if (fd < 0) return 1;
        if (pwrite(fd, \"text\", 4, 0) != 4) return 1;
        /* Linux glibc breakage until 2.2.5 */
        if (pwrite(fd, \"text\", 4, -1) != -1 || errno != EINVAL) return 1;

        return 0;
      }
    " PHP_PWRITE_64)
  cmake_pop_check_state()

  if(PHP_PWRITE_64)
    set(HAVE_PWRITE 1 CACHE INTERNAL "Whether pwrite() works")
  endif()
endif()

if(HAVE_PWRITE)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

unset(_php_check_pwrite_file)
