#[=============================================================================[
This check determines whether functions pread() and pwrite() are available on
the system, and then checks if they work as expected. The missing declaration
checks are for obsolete systems, where function declarations for 64-bit variants
(pread64 and pwrite64) with 'off64_t' type in the 3rd argument were missing in
the system headers. On modern systems this check is obsolete in favor of a
simpler:

  check_symbol_exists(<symbol> unistd.h <result>)

When using pread() and pwrite() also '_GNU_SOURCE' is needed to enable the
'_LARGEFILE64_SOURCE' for using 64-bit function variants. A better way would be
to set the '_FILE_OFFSET_BITS=64' but this is skipped to match the current
php-src code.

Result variables:

* HAVE_PREAD - Whether pread() is available.
* HAVE_PWRITE - Whether pwrite() is available.

Cache variables:
* PHP_PREAD_64 - Whether pread() declaration with off64_t is missing (using
  pread64).
* PHP_PWRITE_64 - Whether pwrite() declaration with off64_t is missing (using
  pwrite64).
#]=============================================================================]

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

include(CheckSourceCompiles)
include(CheckSourceRuns)
include(CheckSymbolExists)
include(CMakePushCheckState)
include(PHP/SystemExtensions)

################################################################################
# Check pread().
################################################################################

function(_php_ext_session_check_pread result)
  set(${result} FALSE)

  # Skip in consecutive configuration phases.
  if(DEFINED PHP_EXT_SESSION_HAVE_PREAD_SYMBOL)
    if(PHP_EXT_SESSION_HAVE_PREAD)
      set(${result} TRUE)
    endif()
    return(PROPAGATE ${result})
  endif()

  set(code [[
    #define xstr(s) str(s)
    #define str(s) #s

    #include <sys/types.h>
    #include <sys/stat.h>
    #include <fcntl.h>
    #include <unistd.h>
    #include <errno.h>
    #include <stdlib.h>

    /* Provide a missing declaration. */
    #ifdef PHP_PREAD_64
    ssize_t pread(int, void *, size_t, off64_t);
    #endif

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
  ]])

  check_symbol_exists(pread unistd.h PHP_EXT_SESSION_HAVE_PREAD_SYMBOL)

  set(file ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/php_check_pread.tmp)
  file(WRITE "${file}" "test\n")

  # Check for missing declaration is obsolete. Some systems once didn't provide
  # declaration in the headers when using 64-bit variant of pread() with 3rd
  # argument of type 'off64_t'.
  if(NOT PHP_EXT_SESSION_HAVE_PREAD_SYMBOL)
    cmake_push_check_state(RESET)
      # Needs '_GNU_SOURCE' to enable 64-bit variant.
      set(CMAKE_REQUIRED_LIBRARIES PHP::SystemExtensions)

      set(CMAKE_REQUIRED_DEFINITIONS -DTMP_FILE=${file} -DPHP_PREAD_64)

      check_source_compiles(C "${code}" PHP_PREAD_64)
    cmake_pop_check_state()

    if(NOT PHP_PREAD_64)
      return(PROPAGATE ${result})
    endif()
  endif()

  message(CHECK_START "Checking whether pread() works")

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)

    # Needs '_GNU_SOURCE' to enable 64-bit variant.
    set(CMAKE_REQUIRED_LIBRARIES PHP::SystemExtensions)

    set(CMAKE_REQUIRED_DEFINITIONS -DTMP_FILE=${file})
    if(PHP_PREAD_64)
      list(APPEND CMAKE_REQUIRED_DEFINITIONS -DPHP_PREAD_64)
    endif()

    check_source_runs(C "${code}" PHP_EXT_SESSION_HAVE_PREAD)
  cmake_pop_check_state()

  if(PHP_EXT_SESSION_HAVE_PREAD)
    set(${result} TRUE)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()

  return(PROPAGATE ${result})
endfunction()

################################################################################
# Check pwrite().
################################################################################

function(_php_ext_session_check_pwrite result)
  set(${result} FALSE)

  # Skip in consecutive configuration phases.
  if(DEFINED PHP_EXT_SESSION_HAVE_PWRITE_SYMBOL)
    if(PHP_EXT_SESSION_HAVE_PWRITE)
      set(${result} TRUE)
    endif()
    return(PROPAGATE ${result})
  endif()

  set(code [[
    #define xstr(s) str(s)
    #define str(s) #s

    #include <sys/types.h>
    #include <sys/stat.h>
    #include <fcntl.h>
    #include <unistd.h>
    #include <errno.h>
    #include <stdlib.h>

    /* Provide a missing declaration. */
    #ifdef PHP_PWRITE_64
    ssize_t pwrite(int, void *, size_t, off64_t);
    #endif

    int main(void)
    {
      int fd = open(xstr(TMP_FILE), O_WRONLY|O_CREAT, 0600);

      if (fd < 0) return 1;
      if (pwrite(fd, "text", 4, 0) != 4) return 1;
      /* Linux glibc breakage until 2.2.5 */
      if (pwrite(fd, "text", 4, -1) != -1 || errno != EINVAL) return 1;

      return 0;
    }
  ]])

  check_symbol_exists(pwrite unistd.h PHP_EXT_SESSION_HAVE_PWRITE_SYMBOL)

  # Check for missing declaration is obsolete. Some systems once didn't provide
  # declaration in the headers for 64-bit pwrite() variant with 3rd argument of
  # type 'off64_t'. Additional issue is that on current systems the 2nd argument
  # of pwrite() should have the type 'const void*', otherwise compilation fails.
  if(NOT PHP_EXT_SESSION_HAVE_PWRITE_SYMBOL)
    cmake_push_check_state(RESET)
      # Needs '_GNU_SOURCE' to enable 64-bit variant.
      set(CMAKE_REQUIRED_LIBRARIES PHP::SystemExtensions)

      set(
        CMAKE_REQUIRED_DEFINITIONS
        -DTMP_FILE=${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/php_check_pwrite64.tmp
        -DPHP_PWRITE_64
      )

      check_source_compiles(C "${code}" PHP_PWRITE_64)
    cmake_pop_check_state()

    if(NOT PHP_PWRITE_64)
      return(PROPAGATE ${result})
    endif()
  endif()

  message(CHECK_START "Checking whether pwrite() works")

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)

    # Needs '_GNU_SOURCE' to enable 64-bit variant.
    set(CMAKE_REQUIRED_LIBRARIES PHP::SystemExtensions)

    set(
      CMAKE_REQUIRED_DEFINITIONS
      -DTMP_FILE=${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/php_check_pwrite.tmp
    )
    if(PHP_PWRITE_64)
      list(APPEND CMAKE_REQUIRED_DEFINITIONS -DPHP_PWRITE_64)
    endif()

    check_source_runs(C "${code}" PHP_EXT_SESSION_HAVE_PWRITE)
  cmake_pop_check_state()

  if(PHP_EXT_SESSION_HAVE_PWRITE)
    set(${result} TRUE)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()

  return(PROPAGATE ${result})
endfunction()

_php_ext_session_check_pread(HAVE_PREAD)
_php_ext_session_check_pwrite(HAVE_PWRITE)
