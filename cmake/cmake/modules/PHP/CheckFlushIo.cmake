#[=============================================================================[
Check if flush should be called explicitly after buffered io.

Cache variables:

  HAVE_FLUSHIO
    Whether flush should be called explicitly after a buffered io.
]=============================================================================]#

include(CheckCSourceRuns)
include(CMakePushCheckState)

message(CHECK_START
  "Checking whether flush should be called explicitly after a buffered io"
)

list(APPEND CMAKE_MESSAGE_INDENT "  ")

if(NOT CMAKE_CROSSCOMPILING)
  cmake_push_check_state(RESET)
    if(HAVE_UNISTD_H)
      set(CMAKE_REQUIRED_DEFINITIONS -DHAVE_UNISTD_H)
    endif()

    check_c_source_runs("
      #include <stdio.h>
      #include <stdlib.h>
      #ifdef HAVE_UNISTD_H
      # include <unistd.h>
      #endif
      #include <string.h>

      int main(int argc, char **argv) {
        char *filename = tmpnam(NULL);
        char buffer[64];
        int result = 1;

        FILE *fp = fopen(filename, \"wb\");
        if (NULL == fp)
          return 1;
        fputs(\"line 1\\\\n\", fp);
        fputs(\"line 2\\\\n\", fp);
        fclose(fp);

        fp = fopen(filename, \"rb+\");
        if (NULL == fp)
          return 1;
        fgets(buffer, sizeof(buffer), fp);
        fputs(\"line 3\\\\n\", fp);
        rewind(fp);
        fgets(buffer, sizeof(buffer), fp);
        if (0 != strcmp(buffer, \"line 1\\\\n\"))
          result = 0;
        fgets(buffer, sizeof(buffer), fp);
        if (0 != strcmp(buffer, \"line 3\\\\n\"))
          result = 0;
        fclose(fp);
        unlink(filename);

        exit(result);
      }
    " HAVE_FLUSHIO)
  cmake_pop_check_state()
endif()

list(POP_BACK CMAKE_MESSAGE_INDENT)

if(HAVE_FLUSHIO)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
