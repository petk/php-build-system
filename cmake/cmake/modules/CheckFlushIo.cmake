#[=============================================================================[
Check if flush should be called explicitly after buffered io.

Function: check_flush_io()
]=============================================================================]#

include(CheckCSourceCompiles)

function(check_flush_io)
  message(STATUS "Checking whether flush should be called explicitly after a buffered io")

  check_c_source_compiles("
  #include <stdio.h>
  #include <stdlib.h>
  #ifdef HAVE_UNISTD_H
  #include <unistd.h>
  #endif
  #include <string.h>

  int main(int argc, char **argv)
  {
    char *filename = tmpnam(NULL);
    char buffer[64];
    int result = 0;

    FILE *fp = fopen(filename, \"wb\");
    if (NULL == fp)
      return 0;
    fputs(\"line 1\\\\n\", fp);
    fputs(\"line 2\\\\n\", fp);
    fclose(fp);

    fp = fopen(filename, \"rb+\");
    if (NULL == fp)
      return 0;
    fgets(buffer, sizeof(buffer), fp);
    fputs(\"line 3\\\\n\", fp);
    rewind(fp);
    fgets(buffer, sizeof(buffer), fp);
    if (0 != strcmp(buffer, \"line 1\\\\n\"))
      result = 1;
    fgets(buffer, sizeof(buffer), fp);
    if (0 != strcmp(buffer, \"line 3\\\\n\"))
      result = 1;
    fclose(fp);
    unlink(filename);

    exit(result);
  }
  " HAVE_FLUSHIO)

  if(HAVE_FLUSHIO)
    set(HAVE_FLUSHIO 1 CACHE STRING "Define if flush should be called explicitly after a buffered io.")
  endif()
endfunction()
