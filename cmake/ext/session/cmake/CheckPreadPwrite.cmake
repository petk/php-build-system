#[=============================================================================[
Check whether `pread()` and `pwrite()` work.

Module first checks whether functions are available on the system, and then
checks if they work as expected. The last checks are for some obsolete systems,
where function declaration with `off64_t` type in the 3rd argument was missing
in the system headers. On modern systems this module is obsolescent in favor of
a simpler:

```cmake
check_symbol_exists(<symbol> unistd.h HAVE_<SYMBOL>)
```

## Cache variables

* `HAVE_PREAD`
    Whether `pread()` is available.
* `PHP_PREAD_64`
    Whether pread64 is default.
* `HAVE_PWRITE`
    Whether `pwrite()` is available.
* `PHP_PWRITE_64`
    Whether pwrite64 is default.
#]=============================================================================]

include_guard(GLOBAL)

include(CheckFunctionExists)
include(CheckSourceRuns)
include(CMakePushCheckState)
include(PHP/SystemExtensions)

################################################################################
# Check pread().
################################################################################

function(_php_check_pread)
  message(CHECK_START "Checking whether pread() works")

  # Check if linker sees the pread().
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)
    check_function_exists(pread _HAVE_PREAD)
  cmake_pop_check_state()

  if(NOT _HAVE_PREAD)
    message(CHECK_FAIL "no (not found)")
    return()
  endif()

  set(
    temporaryFile
    ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/php_check_pread.tmp
  )

  file(WRITE "${temporaryFile}" "test\n")

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)
    set(CMAKE_REQUIRED_DEFINITIONS -DTMP_FILE=${temporaryFile})

    check_source_runs(C [[
      #define xstr(s) str(s)
      #define str(s) #s

      #include <sys/types.h>
      #include <sys/stat.h>
      #include <fcntl.h>
      #include <unistd.h>
      #include <errno.h>
      #include <stdlib.h>

      int main(void)
      {
        char buf[3];
        int fd = open(xstr(TMP_FILE), O_RDONLY);

        if (fd < 0) return 1;
        if (pread(fd, buf, 2, 0) != 2) return 1;
        /* Linux glibc breakage until 2.2.5 */
        if (pread(fd, buf, 2, -1) != -1 || errno != EINVAL) return 1;

        return 0;
      }
    ]] HAVE_PREAD)
  cmake_pop_check_state()

  # This check is obsolete. Some systems once had pread() available with 3rd
  # argument of type 'off64_t', but didn't provide declaration in the headers.
  if(NOT HAVE_PREAD)
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_QUIET TRUE)
      set(CMAKE_REQUIRED_DEFINITIONS -DTMP_FILE=${temporaryFile})

      # Needs '_GNU_SOURCE' to enable '_LARGEFILE64_SOURCE' for using 'off64_t'.
      # Default way would be the '_FILE_OFFSET_BITS=64' but this is skipped to
      # match the current php-src code.
      set(CMAKE_REQUIRED_LIBRARIES PHP::SystemExtensions)

      check_source_runs(C [[
        #define xstr(s) str(s)
        #define str(s) #s

        #include <sys/types.h>
        #include <sys/stat.h>
        #include <fcntl.h>
        #include <unistd.h>
        #include <errno.h>
        #include <stdlib.h>

        /* Provide a missing declaration. */
        ssize_t pread(int, void *, size_t, off64_t);

        int main(void)
        {
          char buf[3];
          int fd = open(xstr(TMP_FILE), O_RDONLY);

          if (fd < 0) return 1;
          if (pread(fd, buf, 2, 0) != 2) return 1;
          /* Linux glibc breakage until 2.2.5 */
          if (pread(fd, buf, 2, -1) != -1 || errno != EINVAL) return 1;

          return 0;
        }
      ]] PHP_PREAD_64)
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
endfunction()

################################################################################
# Check pwrite().
################################################################################

function(_php_check_pwrite)
  message(CHECK_START "Checking whether pwrite() works")

  # Check if linker sees the pwrite().
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)
    check_function_exists(pwrite _HAVE_PWRITE)
  cmake_pop_check_state()

  if(NOT _HAVE_PWRITE)
    message(CHECK_FAIL "no (not found)")
    return()
  endif()

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)
    set(
      CMAKE_REQUIRED_DEFINITIONS
      -DTMP_FILE=${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/php_check_pwrite.tmp
    )

    check_source_runs(C [[
      #define xstr(s) str(s)
      #define str(s) #s

      #include <sys/types.h>
      #include <sys/stat.h>
      #include <fcntl.h>
      #include <unistd.h>
      #include <errno.h>
      #include <stdlib.h>

      int main(void)
      {
        int fd = open(xstr(TMP_FILE), O_WRONLY|O_CREAT, 0600);

        if (fd < 0) return 1;
        if (pwrite(fd, "text", 4, 0) != 4) return 1;
        /* Linux glibc breakage until 2.2.5 */
        if (pwrite(fd, "text", 4, -1) != -1 || errno != EINVAL) return 1;

        return 0;
      }
    ]] HAVE_PWRITE)
  cmake_pop_check_state()

  # This check is obsolete. Some systems once had pwrite() available with 3rd
  # argument of type 'off64_t', but didn't provide declaration in the headers.
  # On later systems the 2nd argument of pwrite() should also have the 'const'
  # keyword.
  if(NOT HAVE_PWRITE)
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_QUIET TRUE)
      set(
        CMAKE_REQUIRED_DEFINITIONS
        -DTMP_FILE=${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/php_check_pwrite64.tmp
      )

      # Needs '_GNU_SOURCE' to enable '_LARGEFILE64_SOURCE' for using 'off64_t'.
      # Default way would be the '_FILE_OFFSET_BITS=64' but this is skipped to
      # match the current php-src code.
      set(CMAKE_REQUIRED_LIBRARIES PHP::SystemExtensions)

      check_source_runs(C [[
        #define xstr(s) str(s)
        #define str(s) #s

        #include <sys/types.h>
        #include <sys/stat.h>
        #include <fcntl.h>
        #include <unistd.h>
        #include <errno.h>
        #include <stdlib.h>

        /* Provide a missing declaration. */
        ssize_t pwrite(int, void *, size_t, off64_t);

        int main(void)
        {
          int fd = open(xstr(TMP_FILE), O_WRONLY|O_CREAT, 0600);

          if (fd < 0) return 1;
          if (pwrite(fd, "text", 4, 0) != 4) return 1;
          /* Linux glibc breakage until 2.2.5 */
          if (pwrite(fd, "text", 4, -1) != -1 || errno != EINVAL) return 1;

          return 0;
        }
      ]] PHP_PWRITE_64)
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
endfunction()

_php_check_pread()
_php_check_pwrite()
