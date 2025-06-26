#[=============================================================================[
# The pcntl extension

Configure the `pcntl` extension.

This extension provides support for process control support.

> [!NOTE]
> This extension is available only on \*nix systems.

> [!IMPORTANT]
> This extension should be used only with CLI-based PHP SAPIs.

## PHP_EXT_PCNTL

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_PCNTL_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.0)

project(
  PhpExtensionPcntl
  LANGUAGES C
)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

include(CheckSourceCompiles)
include(CheckSourceRuns)
include(CheckSymbolExists)
include(CheckTypeSize)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)
include(PHP/SearchLibraries)
include(PHP/SystemExtensions)

option(PHP_EXT_PCNTL "Enable the pcntl extension (only for CLI-based SAPIs)")

add_feature_info(
  "ext/pcntl"
  PHP_EXT_PCNTL
  "process control support"
)

cmake_dependent_option(
  PHP_EXT_PCNTL_SHARED
  "Build the pcntl extension as a shared library"
  OFF
  PHP_EXT_PCNTL
  OFF
)

if(NOT PHP_EXT_PCNTL)
  return()
endif()

if(PHP_EXT_PCNTL_SHARED)
  add_library(php_ext_pcntl MODULE)
else()
  add_library(php_ext_pcntl OBJECT)
endif()

set_target_properties(php_ext_pcntl PROPERTIES PHP_CLI TRUE)

target_sources(
  php_ext_pcntl
  PRIVATE
    pcntl.c
    pcntl.stub.php
    php_signal.c
)

target_compile_definitions(php_ext_pcntl PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

# Check for required functions.
block()
  check_symbol_exists(fork unistd.h HAVE_FORK)
  check_symbol_exists(sigaction signal.h HAVE_SIGACTION)
  check_symbol_exists(waitpid sys/wait.h HAVE_WAITPID)

  foreach(function fork sigaction waitpid)
    string(TOUPPER ${function} const)
    if(NOT HAVE_${const})
      message(
        FATAL_ERROR
        "ext/pcntl: required function '${function}()' not found."
      )
    endif()
  endforeach()
endblock()

check_symbol_exists(forkx sys/fork.h HAVE_FORKX)
check_symbol_exists(getcpuid sys/processor.h HAVE_GETCPUID)
check_symbol_exists(getpriority sys/resource.h HAVE_GETPRIORITY)
check_symbol_exists(pset_bind sys/pset.h HAVE_PSET_BIND)
check_symbol_exists(
  pthread_set_qos_class_self_np
  pthread/qos.h
  HAVE_PTHREAD_SET_QOS_CLASS_SELF_NP
)
check_symbol_exists(rfork unistd.h HAVE_RFORK)
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(sched_setaffinity sched.h HAVE_SCHED_SETAFFINITY)
cmake_pop_check_state()
check_symbol_exists(setpriority sys/resource.h HAVE_SETPRIORITY)
check_symbol_exists(sigtimedwait signal.h HAVE_SIGTIMEDWAIT)
check_symbol_exists(sigwaitinfo signal.h HAVE_SIGWAITINFO)
check_symbol_exists(SYS_pidfd_open sys/syscall.h HAVE_DECL_SYS_PIDFD_OPEN)
check_symbol_exists(SYS_waitid sys/syscall.h HAVE_DECL_SYS_WAITID)
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(syscall "sys/syscall.h;unistd.h" HAVE_SYSCALL)
cmake_pop_check_state()
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(unshare sched.h HAVE_UNSHARE)
cmake_pop_check_state()
check_symbol_exists(wait3 sys/wait.h HAVE_WAIT3)
check_symbol_exists(wait4 sys/wait.h HAVE_WAIT4)
check_symbol_exists(wait6 sys/wait.h HAVE_WAIT6)
check_symbol_exists(waitid sys/wait.h HAVE_WAITID)
check_symbol_exists(WCONTINUED sys/wait.h HAVE_DECL_WCONTINUED)
check_symbol_exists(WEXITED sys/wait.h HAVE_DECL_WEXITED)
check_symbol_exists(WIFCONTINUED sys/wait.h HAVE_WIFCONTINUED)
check_symbol_exists(WNOWAIT sys/wait.h HAVE_DECL_WNOWAIT)
check_symbol_exists(WSTOPPED sys/wait.h HAVE_DECL_WSTOPPED)

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

cmake_push_check_state(RESET)
  set(CMAKE_EXTRA_INCLUDE_FILES "signal.h")
  check_type_size(siginfo_t STRUCT_SIGINFO_T)
cmake_pop_check_state()

if(HAVE_STRUCT_SIGINFO_T)
  target_compile_definitions(php_ext_pcntl PRIVATE HAVE_STRUCT_SIGINFO_T)
endif()

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)

  # Check if sched_getcpu() is supported. Value -1 means ENOSYS in this context.
  block()
    php_search_libraries(
      sched_getcpu
      HEADERS sched.h
      LIBRARIES
        gnu # Haiku
      VARIABLE PHP_EXT_PCNTL_HAS_SCHED_GETCPU
      LIBRARY_VARIABLE library
    )

    if(PHP_EXT_PCNTL_HAS_SCHED_GETCPU)
      if(library)
        set(CMAKE_REQUIRED_LIBRARIES ${library})
      endif()
      check_source_runs(C [[
        #include <sched.h>
        int main(void)
        {
          if (sched_getcpu() == -1) {
              return 1;
          }
          return 0;
        }
      ]] HAVE_SCHED_GETCPU)
    endif()

    if(HAVE_SCHED_GETCPU AND library)
      target_link_libraries(php_ext_pcntl PRIVATE ${library})
    endif()
  endblock()
cmake_pop_check_state()

configure_file(cmake/config.h.in config.h)
