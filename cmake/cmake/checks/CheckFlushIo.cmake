#[=============================================================================[
Check if flush should be called explicitly after buffered io.

Result variables:

* HAVE_FLUSHIO
#]=============================================================================]

include(CheckIncludeFiles)
include(CheckSourceRuns)
include(CMakePushCheckState)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(HAVE_FLUSHIO FALSE)
  return()
endif()

# Skip in consecutive configuration phases.
if(DEFINED PHP_HAS_FLUSHIO)
  set(HAVE_FLUSHIO ${PHP_HAS_FLUSHIO})
  return()
endif()

message(
  CHECK_START
  "Checking whether flush should be called explicitly after a buffered io"
)

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)

  check_include_files(unistd.h PHP_HAVE_UNISTD_H)

  if(PHP_HAVE_UNISTD_H)
    set(CMAKE_REQUIRED_DEFINITIONS -DHAVE_UNISTD_H)
  endif()

  check_source_runs(C [[
    #include <stdio.h>
    #include <stdlib.h>
    #ifdef HAVE_UNISTD_H
    # include <unistd.h>
    #endif
    #include <string.h>

    int main(void)
    {
      char *filename = tmpnam(NULL);
      char buffer[64];
      int result = 1;

      FILE *fp = fopen(filename, "wb");
      if (NULL == fp) {
        return 1;
      }

      fputs("line 1\n", fp);
      fputs("line 2\n", fp);
      fclose(fp);

      fp = fopen(filename, "rb+");
      if (NULL == fp) {
        return 1;
      }

      if (fgets(buffer, sizeof(buffer), fp) == NULL) {
        fclose(fp);
        return 1;
      }

      fputs("line 3\n", fp);
      rewind(fp);
      if (fgets(buffer, sizeof(buffer), fp) == NULL) {
        fclose(fp);
        return 1;
      }

      if (0 != strcmp(buffer, "line 1\n")) {
        result = 0;
      }

      if (fgets(buffer, sizeof(buffer), fp) == NULL) {
        fclose(fp);
        return 1;
      }

      if (0 != strcmp(buffer, "line 3\n")) {
        result = 0;
      }

      fclose(fp);
      unlink(filename);

      return result;
    }
  ]] PHP_HAS_FLUSHIO)
cmake_pop_check_state()

if(PHP_HAS_FLUSHIO)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

set(HAVE_FLUSHIO ${PHP_HAS_FLUSHIO})
