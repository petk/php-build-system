#[=============================================================================[
Check whether pwrite() works.

Cache variables:

  HAVE_PWRITE
    Set to 1 if pwrite() is available.
  PHP_PWRITE_64
    Set to 1 if pwrite64 is default.
]=============================================================================]#

include(CheckCSourceRuns)

message(CHECK_START "Checking whether pwrite() works")

list(APPEND CMAKE_MESSAGE_INDENT "  ")

if(NOT CMAKE_CROSSCOMPILING)
  set(
    _php_check_pwrite_file
    "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/php_check_pwrite"
  )

  check_c_source_runs("
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
endif()

if(NOT HAVE_PWRITE AND NOT CMAKE_CROSSCOMPILING)
  set(
    _php_check_pwrite_file
    "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/php_check_pwrite64"
  )

  check_c_source_runs("
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

  if(PHP_PWRITE_64)
    set(HAVE_PWRITE 1 CACHE INTERNAL "Whether pwrite() works")
  endif()
endif()

list(POP_BACK CMAKE_MESSAGE_INDENT)

if(HAVE_PWRITE)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

unset(_php_check_pwrite_file)
