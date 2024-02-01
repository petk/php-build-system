# Extension is only for *nix systems.
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

# TODO: pcntl is a cli/cgi extension.
include(CheckSourceCompiles)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(EXT_PCNTL "Enable the pcntl extension (CLI/CGI only)" OFF)

add_feature_info(
  "ext/pcntl"
  EXT_PCNTL
  "Process control support (CLI/CGI only)."
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

check_symbol_exists(fork "unistd.h" HAVE_FORK)

if(NOT HAVE_FORK)
  message(FATAL_ERROR "pcntl: fork() is not supported by this platform")
endif()

check_symbol_exists(waitpid "sys/wait.h" HAVE_WAITPID)

if(NOT HAVE_WAITPID)
  message(FATAL_ERROR "pcntl: waitpid() is not supported by this platform")
endif()

check_symbol_exists(sigaction "signal.h" HAVE_SIGACTION)

if(NOT HAVE_SIGACTION)
  message(FATAL_ERROR "pcntl: sigaction() is not supported by this platform")
endif()

check_symbol_exists(getpriority "sys/resource.h" HAVE_GETPRIORITY)
check_symbol_exists(setpriority "sys/resource.h" HAVE_SETPRIORITY)
check_symbol_exists(wait3 "sys/wait.h" HAVE_WAIT3)
check_symbol_exists(wait4 "sys/wait.h" HAVE_WAIT4)
check_symbol_exists(sigwaitinfo "signal.h" HAVE_SIGWAITINFO)
check_symbol_exists(sigtimedwait "signal.h" HAVE_SIGTIMEDWAIT)
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(unshare "sched.h" HAVE_UNSHARE)
cmake_pop_check_state()
check_symbol_exists(rfork "unistd.h" HAVE_RFORK)
check_symbol_exists(forkx "sys/fork.h" HAVE_FORKX)

# The siginfo_t is defined in signal.h according to POSIX. Some systems don't
# conform to POSIX and have siginfo_t defined in siginfo.h.
# TODO: Recheck siginfo.h again if this is still needed on current systems.
message(CHECK_START "Checking for siginfo_t")
check_include_file(siginfo.h HAVE_SIGINFO_H)
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)

  if(HAVE_SIGINFO_H)
    list(APPEND CMAKE_REQUIRED_DEFINITIONS -DHAVE_SIGINFO_H)
  endif()

  check_source_compiles(C "
    #include <signal.h>

    #ifdef HAVE_SIGINFO_H
    # include <siginfo.h>
    #endif

    int main(void) {
      siginfo_t info;
      return 0;
    }
  " HAVE_STRUCT_SIGINFO_T)
cmake_pop_check_state()

if(HAVE_STRUCT_SIGINFO_T)
  message(CHECK_PASS "yes")
  target_compile_definitions(php_pcntl PRIVATE HAVE_STRUCT_SIGINFO_T=1)
else()
  message(CHECK_FAIL "no")
endif()
