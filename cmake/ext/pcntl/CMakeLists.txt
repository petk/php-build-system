# Extension is only for *nix systems.
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

# TODO: pcntl is a cli/cgi extension.
include(CheckSourceCompiles)
include(CheckSourceRuns)
include(CheckSymbolExists)
include(CheckTypeSize)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)
include(PHP/SearchLibraries)

option(EXT_PCNTL "Enable the pcntl extension (CLI/CGI only)" OFF)

add_feature_info(
  "ext/pcntl"
  EXT_PCNTL
  "Process control support (CLI/CGI only)"
)

cmake_dependent_option(
  EXT_PCNTL_SHARED
  "Build the pcntl extension as a shared library"
  OFF
  "EXT_PCNTL;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_PCNTL)
  return()
endif()

if(EXT_PCNTL_SHARED)
  add_library(php_pcntl SHARED)
else()
  add_library(php_pcntl)
endif()

target_sources(
  php_pcntl
  PRIVATE
    pcntl.c
    php_signal.c
)

target_compile_definitions(php_pcntl PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

# Check for required functions.
block()
  check_symbol_exists(fork "unistd.h" HAVE_FORK)
  check_symbol_exists(sigaction "signal.h" HAVE_SIGACTION)
  check_symbol_exists(waitpid "sys/wait.h" HAVE_WAITPID)

  foreach(function fork sigaction waitpid)
    string(TOUPPER ${function} const)
    if(NOT HAVE_${const})
      message(
        FATAL_ERROR
        "ext/pcntl: required function ${function}() not found."
      )
    endif()
  endforeach()
endblock()

check_symbol_exists(forkx "sys/fork.h" HAVE_FORKX)
check_symbol_exists(getcpuid "sys/processor.h" HAVE_GETCPUID)
check_symbol_exists(getpriority "sys/resource.h" HAVE_GETPRIORITY)

cmake_push_check_state(RESET)
  # Some of these enum values require _GNU_SOURCE.
  set(CMAKE_REQUIRED_LIBRARIES PHP::SystemExtensions)

  check_source_compiles(C [[
    #include <sys/wait.h>
    int main(void) { idtype_t e = P_ALL; (void)e; return 0; }
  ]] HAVE_DECL_P_ALL)

  check_source_compiles(C [[
    #include <sys/wait.h>
    int main(void) { idtype_t e = P_JAILID; (void)e; return 0; }
  ]] HAVE_DECL_P_JAILID)

  check_source_compiles(C [[
    #include <sys/wait.h>
    int main(void) { idtype_t e = P_PIDFD; (void)e; return 0; }
  ]] HAVE_DECL_P_PIDFD)

  check_source_compiles(C [[
    #include <sys/wait.h>
    int main(void) { idtype_t e = P_UID; (void)e; return 0; }
  ]] HAVE_DECL_P_UID)
cmake_pop_check_state()

check_symbol_exists(pset_bind "sys/pset.h" HAVE_PSET_BIND)
check_symbol_exists(
  pthread_set_qos_class_self_np
  "pthread/qos.h"
  HAVE_PTHREAD_SET_QOS_CLASS_SELF_NP
)
check_symbol_exists(rfork "unistd.h" HAVE_RFORK)
check_symbol_exists(setpriority "sys/resource.h" HAVE_SETPRIORITY)
check_symbol_exists(sigtimedwait "signal.h" HAVE_SIGTIMEDWAIT)
check_symbol_exists(sigwaitinfo "signal.h" HAVE_SIGWAITINFO)
check_symbol_exists(SYS_pidfd_open "sys/syscall.h" HAVE_PIDFD_OPEN)
check_symbol_exists(wait3 "sys/wait.h" HAVE_WAIT3)
check_symbol_exists(wait4 "sys/wait.h" HAVE_WAIT4)
check_symbol_exists(waitid "sys/wait.h" HAVE_WAITID)
check_symbol_exists(WCONTINUED "sys/wait.h" HAVE_DECL_WCONTINUED)
check_symbol_exists(WEXITED "sys/wait.h" HAVE_DECL_WEXITED)
check_symbol_exists(WIFCONTINUED "sys/wait.h" HAVE_WIFCONTINUED)
check_symbol_exists(WNOWAIT "sys/wait.h" HAVE_DECL_WNOWAIT)
check_symbol_exists(WSTOPPED "sys/wait.h" HAVE_DECL_WSTOPPED)

cmake_push_check_state(RESET)
  set(CMAKE_EXTRA_INCLUDE_FILES "signal.h")
  check_type_size(siginfo_t HAVE_STRUCT_SIGINFO_T)
cmake_pop_check_state()

if(HAVE_STRUCT_SIGINFO_T)
  target_compile_definitions(php_pcntl PRIVATE HAVE_STRUCT_SIGINFO_T=1)
endif()

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)

  check_symbol_exists(unshare "sched.h" HAVE_UNSHARE)
  check_symbol_exists(sched_setaffinity "sched.h" HAVE_SCHED_SETAFFINITY)

  # Check if sched_getcpu() is supported. Value -1 means ENOSYS in this context.
  block()
    php_search_libraries(
      sched_getcpu
      _HAVE_SCHED_GETCPU
      HEADERS sched.h
      LIBRARIES
        gnu # Haiku
      LIBRARY_VARIABLE library
    )

    if(_HAVE_SCHED_GETCPU AND NOT CMAKE_CROSSCOMPILING)
      set(CMAKE_REQUIRED_LIBRARIES ${library})
      check_source_runs(C [[
        #include <sched.h>
        int main(void) {
          if (sched_getcpu() == -1) {
              return 1;
          }
          return 0;
        }
      ]] HAVE_SCHED_GETCPU)
    endif()

    if(HAVE_SCHED_GETCPU)
      target_link_libraries(php_pcntl PRIVATE ${library})
    endif()
  endblock()
cmake_pop_check_state()
