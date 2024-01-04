# Extension is only for *nix systems.
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

include(CheckSourceCompiles)
include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_SYSVSEM "Enable the sysvsem extension" OFF)

add_feature_info("ext/sysvsem" EXT_SYSVSEM
  "System V semaphore support."
)

cmake_dependent_option(
  EXT_SYSVSEM_SHARED
  "Build the sysvsem extension as a shared library"
  OFF
  "EXT_SYSVSEM;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_SYSVSEM)
  return()
endif()

if(EXT_SYSVSEM_SHARED)
  add_library(php_sysvsem SHARED)
else()
  add_library(php_sysvsem)
endif()

target_sources(php_sysvsem PRIVATE
  sysvsem.c
)

message(CHECK_START "Checking for union semun")

check_source_compiles(C "
  #include <sys/types.h>
  #include <sys/ipc.h>
  #include <sys/sem.h>

  int main(void) {
    union semun x;

    return 0;
  }
" HAVE_SEMUN)

if(HAVE_SEMUN)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
