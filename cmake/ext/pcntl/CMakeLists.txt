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

cmake_minimum_required(VERSION 4.2...4.3)

project(
  PHP_EXT_PCNTL
  LANGUAGES C
)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

include(CheckSourceCompiles)
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

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(pcntl)

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
  check_symbol_exists(fork unistd.h PHP_HAVE_FORK)
  check_symbol_exists(sigaction signal.h PHP_HAVE_SIGACTION)
  check_symbol_exists(waitpid sys/wait.h PHP_HAVE_WAITPID)

  foreach(function fork sigaction waitpid)
    string(TOUPPER ${function} const)
    if(NOT PHP_HAVE_${const})
      message(
        FATAL_ERROR
        "ext/pcntl: required function '${function}()' not found."
      )
    endif()
  endforeach()
endblock()

check_symbol_exists(forkx sys/fork.h PHP_EXT_PCNTL_HAVE_FORKX)
set(HAVE_FORKX ${PHP_EXT_PCNTL_HAVE_FORKX})

check_symbol_exists(getcpuid sys/processor.h PHP_EXT_PCNTL_HAVE_GETCPUID)
set(HAVE_GETCPUID ${PHP_EXT_PCNTL_HAVE_GETCPUID})

check_symbol_exists(getpriority sys/resource.h PHP_EXT_PCNTL_HAVE_GETPRIORITY)
set(HAVE_GETPRIORITY ${PHP_EXT_PCNTL_HAVE_GETPRIORITY})

check_symbol_exists(pset_bind sys/pset.h PHP_EXT_PCNTL_HAVE_PSET_BIND)
set(HAVE_PSET_BIND ${PHP_EXT_PCNTL_HAVE_PSET_BIND})

check_symbol_exists(
  pthread_set_qos_class_self_np
  pthread/qos.h
  PHP_EXT_PCNTL_HAVE_PTHREAD_SET_QOS_CLASS_SELF_NP
)
set(
  HAVE_PTHREAD_SET_QOS_CLASS_SELF_NP
  ${PHP_EXT_PCNTL_HAVE_PTHREAD_SET_QOS_CLASS_SELF_NP}
)

check_symbol_exists(rfork unistd.h PHP_EXT_PCNTL_HAVE_RFORK)
set(HAVE_RFORK ${PHP_EXT_PCNTL_HAVE_RFORK})

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(
    sched_setaffinity
    sched.h
    PHP_EXT_PCNTL_HAVE_SCHED_SETAFFINITY
  )
  set(HAVE_SCHED_SETAFFINITY ${PHP_EXT_PCNTL_HAVE_SCHED_SETAFFINITY})
cmake_pop_check_state()

check_symbol_exists(setpriority sys/resource.h PHP_EXT_PCNTL_HAVE_SETPRIORITY)
set(HAVE_SETPRIORITY ${PHP_EXT_PCNTL_HAVE_SETPRIORITY})

check_symbol_exists(sigtimedwait signal.h PHP_EXT_PCNTL_HAVE_SIGTIMEDWAIT)
set(HAVE_SIGTIMEDWAIT ${PHP_EXT_PCNTL_HAVE_SIGTIMEDWAIT})

check_symbol_exists(sigwaitinfo signal.h PHP_EXT_PCNTL_HAVE_SIGWAITINFO)
set(HAVE_SIGWAITINFO ${PHP_EXT_PCNTL_HAVE_SIGWAITINFO})

check_symbol_exists(
  SYS_pidfd_open
  sys/syscall.h
  PHP_EXT_PCNTL_HAVE_DECL_SYS_PIDFD_OPEN
)
set(HAVE_DECL_SYS_PIDFD_OPEN ${PHP_EXT_PCNTL_HAVE_DECL_SYS_PIDFD_OPEN})

check_symbol_exists(SYS_waitid sys/syscall.h PHP_EXT_PCNTL_HAVE_DECL_SYS_WAITID)
set(HAVE_DECL_SYS_WAITID ${PHP_EXT_PCNTL_HAVE_DECL_SYS_WAITID})

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(syscall "sys/syscall.h;unistd.h" PHP_EXT_PCNTL_HAVE_SYSCALL)
  set(HAVE_SYSCALL ${PHP_EXT_PCNTL_HAVE_SYSCALL})
cmake_pop_check_state()

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(unshare sched.h PHP_EXT_PCNTL_HAVE_UNSHARE)
  set(HAVE_UNSHARE ${PHP_EXT_PCNTL_HAVE_UNSHARE})
cmake_pop_check_state()

check_symbol_exists(wait6 sys/wait.h PHP_EXT_PCNTL_HAVE_WAIT6)
set(HAVE_WAIT6 ${PHP_EXT_PCNTL_HAVE_WAIT6})

check_symbol_exists(wait3 sys/wait.h PHP_EXT_PCNTL_HAVE_WAIT3)
set(HAVE_WAIT3 ${PHP_EXT_PCNTL_HAVE_WAIT3})

check_symbol_exists(wait4 sys/wait.h PHP_EXT_PCNTL_HAVE_WAIT4)
set(HAVE_WAIT4 ${PHP_EXT_PCNTL_HAVE_WAIT4})

check_symbol_exists(waitid sys/wait.h PHP_EXT_PCNTL_HAVE_WAITID)
set(HAVE_WAITID ${PHP_EXT_PCNTL_HAVE_WAITID})

check_symbol_exists(WCONTINUED sys/wait.h PHP_EXT_PCNTL_HAVE_DECL_WCONTINUED)
set(HAVE_DECL_WCONTINUED ${PHP_EXT_PCNTL_HAVE_DECL_WCONTINUED})

check_symbol_exists(WEXITED sys/wait.h PHP_EXT_PCNTL_HAVE_DECL_WEXITED)
set(HAVE_DECL_WEXITED ${PHP_EXT_PCNTL_HAVE_DECL_WEXITED})

check_symbol_exists(WIFCONTINUED sys/wait.h PHP_EXT_PCNTL_HAVE_WIFCONTINUED)
set(HAVE_WIFCONTINUED ${PHP_EXT_PCNTL_HAVE_WIFCONTINUED})

check_symbol_exists(WNOWAIT sys/wait.h PHP_EXT_PCNTL_HAVE_DECL_WNOWAIT)
set(HAVE_DECL_WNOWAIT ${PHP_EXT_PCNTL_HAVE_DECL_WNOWAIT})

check_symbol_exists(WSTOPPED sys/wait.h PHP_EXT_PCNTL_HAVE_DECL_WSTOPPED)
set(HAVE_DECL_WSTOPPED ${PHP_EXT_PCNTL_HAVE_DECL_WSTOPPED})

cmake_push_check_state(RESET)
  # Some of these enum values require _GNU_SOURCE.
  set(CMAKE_REQUIRED_LIBRARIES PHP::SystemExtensions)

  check_source_compiles(C [[
    #include <sys/wait.h>
    int main(void) { idtype_t e = P_ALL; (void)e; return 0; }
  ]] PHP_EXT_PCNTL_HAVE_DECL_P_ALL)
  set(HAVE_DECL_P_ALL ${PHP_EXT_PCNTL_HAVE_DECL_P_ALL})

  check_source_compiles(C [[
    #include <sys/wait.h>
    int main(void) { idtype_t e = P_JAILID; (void)e; return 0; }
  ]] PHP_EXT_PCNTL_HAVE_DECL_P_JAILID)
  set(HAVE_DECL_P_JAILID ${PHP_EXT_PCNTL_HAVE_DECL_P_JAILID})

  check_source_compiles(C [[
    #include <sys/wait.h>
    int main(void) { idtype_t e = P_PIDFD; (void)e; return 0; }
  ]] PHP_EXT_PCNTL_HAVE_DECL_P_PIDFD)
  set(HAVE_DECL_P_PIDFD ${PHP_EXT_PCNTL_HAVE_DECL_P_PIDFD})

  check_source_compiles(C [[
    #include <sys/wait.h>
    int main(void) { idtype_t e = P_UID; (void)e; return 0; }
  ]] PHP_EXT_PCNTL_HAVE_DECL_P_UID)
  set(HAVE_DECL_P_UID ${PHP_EXT_PCNTL_HAVE_DECL_P_UID})
cmake_pop_check_state()

cmake_push_check_state(RESET)
  set(CMAKE_EXTRA_INCLUDE_FILES "signal.h")
  check_type_size(
    siginfo_t
    PHP_EXT_PCNTL_SIZEOF_STRUCT_SIGINFO_T
    RESULT_VARIABLE PHP_EXT_PCNTL_HAVE_STRUCT_SIGINFO_T
  )
cmake_pop_check_state()

if(PHP_EXT_PCNTL_HAVE_STRUCT_SIGINFO_T)
  target_compile_definitions(php_ext_pcntl PRIVATE HAVE_STRUCT_SIGINFO_T)
endif()

# Check if sched_getcpu() is supported. Value -1 means ENOSYS in this context.
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)

  php_search_libraries(
    SOURCE_RUNS [[
      #include <sched.h>
      int main(void)
      {
        if (sched_getcpu() == -1) {
          return 1;
        }
        return 0;
      }
    ]]
    HEADERS sched.h
    LIBRARIES
      gnu # Haiku
    RESULT_VARIABLE PHP_EXT_PCNTL_HAVE_SCHED_GETCPU
    LIBRARY_VARIABLE PHP_EXT_PCNTL_HAVE_SCHED_GETCPU_LIBRARY
    TARGET php_ext_pcntl PRIVATE
  )

  set(HAVE_SCHED_GETCPU ${PHP_EXT_PCNTL_HAVE_SCHED_GETCPU})
cmake_pop_check_state()

configure_file(cmake/config.h.in config.h)
