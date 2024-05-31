#[=============================================================================[
Check if dlsym() requires a leading underscore in symbol name.

Some non-ELF platforms, such as OpenBSD, FreeBSD, NetBSD, Mac OSX (~10.3),
needed underscore character (_) prefix for symbols, when using dlsym(). This
module is obsolete on current platforms.

Cache variables:

  DLSYM_NEEDS_UNDERSCORE
    Whether dlsym() requires a leading underscore in symbol names.
]=============================================================================]#

include_guard(GLOBAL)

include(CheckIncludeFile)

message(
  CHECK_START
  "Checking whether dlsym() requires a leading underscore in symbol names"
)

if(NOT CMAKE_CROSSCOMPILING)
  check_include_file(dlfcn.h HAVE_DLFCN_H)

  block()
    if(HAVE_DLFCN_H)
      set(definitions "-DHAVE_DLFCN_H=1")
    endif()

    try_run(
      ZEND_DLSYM_RUN_RESULT
      ZEND_DLSYM_COMPILE_RESULT
      SOURCE_FROM_CONTENT src.c [[
        #ifdef HAVE_DLFCN_H
        #include <dlfcn.h>
        #endif

        #include <stdio.h>

        #ifdef RTLD_GLOBAL
        #  define LT_DLGLOBAL RTLD_GLOBAL
        #else
        #  ifdef DL_GLOBAL
        #    define LT_DLGLOBAL DL_GLOBAL
        #  else
        #    define LT_DLGLOBAL 0
        #  endif
        #endif

        /* We may need to define LT_DLLAZY_OR_NOW on the command line if we
          discover that it does not work on some platform. */
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

        /* When -fvisibility=hidden is used, assume the code has been annotated
           correspondingly for the symbols needed.  */
        #if defined __GNUC__ && (((__GNUC__ == 3) && (__GNUC_MINOR__ >= 3)) || (__GNUC__ > 3))
        int fnord(void) __attribute__((visibility("default")));
        #endif

        int fnord(void) { return 42; }

        int main(void) {
          void *self = dlopen(0, LT_DLGLOBAL|LT_DLLAZY_OR_NOW);
          int status = 0;

          if (self) {
            if (dlsym(self, "fnord")) {
              status = 1;
            } else if (dlsym(self, "_fnord")) {
              status = 2;
            } else {
              puts (dlerror());
            }
            /* dlclose(self); */
          } else {
            puts(dlerror());
          }

          return (status);
        }
      ]]
      COMPILE_DEFINITIONS ${definitions}
      LINK_LIBRARIES ${CMAKE_DL_LIBS}
    )
  endblock()

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
