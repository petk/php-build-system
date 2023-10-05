include(CheckCSourceCompiles)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)

option(EXT_PCNTL "Whether to enable the pcntl extension (CLI/CGI only)" OFF)

cmake_dependent_option(EXT_PCNTL_SHARED "Whether to build the pcntl extension as shared object" OFF "EXT_PCNTL;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_PCNTL)
  return()
endif()

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

message(STATUS "Checking for siginfo_t")
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_c_source_compiles("
    #include <signal.h>

    int main(void) {
      siginfo_t info;
      return 0;
    }
  " HAVE_STRUCT_SIGINFO_T)
cmake_pop_check_state()

if(EXT_PCNTL_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "pcntl" ${_library_type})

add_library(ext_pcntl ${_library_type}
  pcntl.c
  php_signal.c
)

target_compile_definitions(ext_pcntl PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

if(HAVE_STRUCT_SIGINFO_T)
  target_compile_definitions(ext_pcntl PRIVATE HAVE_STRUCT_SIGINFO_T=1)
endif()

# TODO: pcntl is a cli/cgi extension.
