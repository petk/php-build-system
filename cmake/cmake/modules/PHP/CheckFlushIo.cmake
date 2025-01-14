#[=============================================================================[
# PHP/CheckFlushIo

Check if flush should be called explicitly after buffered io.

## Cache variables

* `HAVE_FLUSHIO`
#]=============================================================================]

include_guard(GLOBAL)

# Skip in consecutive configuration phases.
if(DEFINED HAVE_FLUSHIO)
  return()
endif()

include(CheckIncludeFile)
include(CheckSourceRuns)
include(CMakePushCheckState)

message(CHECK_START
  "Checking whether flush should be called explicitly after a buffered io"
)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  message(CHECK_FAIL "no")
  set(
    HAVE_FLUSHIO
    FALSE
    CACHE INTERNAL
    "Whether flush should be called explicitly after a buffered io."
  )
  return()
endif()

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)

  check_include_file(unistd.h HAVE_UNISTD_H)

  if(HAVE_UNISTD_H)
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
  ]] HAVE_FLUSHIO)
cmake_pop_check_state()

if(HAVE_FLUSHIO)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
