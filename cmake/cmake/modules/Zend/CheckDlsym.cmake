#[=============================================================================[
Check if dlsym() requires a leading underscore in symbol name.

Cache variables:

  DLSYM_NEEDS_UNDERSCORE
    Whether dlsym() requires a leading underscore in symbol names.
]=============================================================================]#

message(
  CHECK_START
  "Checking whether dlsym() requires a leading underscore in symbol names"
)

if(NOT CMAKE_CROSSCOMPILING)
  if(HAVE_DLFCN_H)
    set(_zend_dlfcn_definitions "-DHAVE_DLFCN_H=1")
  endif()

  try_run(
    ZEND_DLSYM_RUN_RESULT
    ZEND_DLSYM_COMPILE_RESULT
    SOURCE_FROM_CONTENT src.c "
      #if HAVE_DLFCN_H
      #include <dlfcn.h>
      #endif

      #include <stdio.h>
      #include <stdlib.h>

      #ifdef RTLD_GLOBAL
      #  define LT_DLGLOBAL RTLD_GLOBAL
      #else
      #  ifdef DL_GLOBAL
      #    define LT_DLGLOBAL DL_GLOBAL
      #  else
      #    define LT_DLGLOBAL 0
      #  endif
      #endif

      /* We may have to define LT_DLLAZY_OR_NOW in the command line if we find
         out it does not work in some platform. */
      #ifndef LT_DLLAZY_OR_NOW
      #  ifdef RTLD_LAZY
      #    define LT_DLLAZY_OR_NOW       RTLD_LAZY
      #  else
      #    ifdef DL_LAZY
      #      define LT_DLLAZY_OR_NOW     DL_LAZY
      #    else
      #      ifdef RTLD_NOW
      #        define LT_DLLAZY_OR_NOW   RTLD_NOW
      #      else
      #        ifdef DL_NOW
      #          define LT_DLLAZY_OR_NOW DL_NOW
      #        else
      #          define LT_DLLAZY_OR_NOW 0
      #        endif
      #      endif
      #    endif
      #  endif
      #endif

      void fnord() {
        int i = 42;
      }

      int main(void) {
        void *self = dlopen(0, LT_DLGLOBAL|LT_DLLAZY_OR_NOW);
        int status = 0;

        if (self) {
          if (dlsym(self,\"fnord\"))       status = 1;
          else if (dlsym(self,\"_fnord\")) status = 2;
          /* dlclose(self); */
        } else {
          puts(dlerror());
        }

        return (status);
      }
    "
    COMPILE_DEFINITIONS ${_zend_dlfcn_definitions}
    RUN_OUTPUT_STDOUT_VARIABLE ZEND_DLSYM_OUTPUT
  )

  unset(_zend_dlfcn_definitions)

  if(ZEND_DLSYM_COMPILE_RESULT AND ZEND_DLSYM_RUN_RESULT EQUAL 2)
    set(
      DLSYM_NEEDS_UNDERSCORE 1
      CACHE INTERNAL
      "Whether dlsym() requires a leading underscore in symbol names."
    )
  endif()
endif()

if(DLSYM_NEEDS_UNDERSCORE)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
