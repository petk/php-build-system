#[=============================================================================[
Check system requirements and validate basic configuration.
#]=============================================================================]

include_guard(GLOBAL)

include(CheckSourceRuns)
include(CMakePushCheckState)

################################################################################
# Check for supported platforms.
#
# HP-UX: Recent compilers are not supported, EOL in December 2025/2028.
################################################################################

if(CMAKE_SYSTEM_NAME STREQUAL "HP-UX")
  message(
    FATAL_ERROR
    "Unsupported platform detected: ${CMAKE_SYSTEM_NAME}.\n"
    "Please, migrate or upgrade operating system."
  )
endif()

################################################################################
# Check whether some minimum supported compiler is used.
################################################################################

if(CMAKE_C_COMPILER_ID STREQUAL "SunPro")
  message(
    FATAL_ERROR
    "Using unsupported compiler: Oracle Developer Studio.\n"
    "Please, install a compatible C compiler such as GNU C or Clang. You can "
    "set 'CMAKE_C_COMPILER' (and 'CMAKE_CXX_COMPILER') variables to the "
    "compiler path on the system."
  )
elseif(CMAKE_C_COMPILER_ID STREQUAL "MSVC" AND MSVC_VERSION VERSION_LESS 1920)
  message(
    FATAL_ERROR
    "Visual Studio version ${MSVC_VERSION} is no longer supported. Please, "
    "upgrade the Microsoft Visual Studio to 2019 version 16 (1920) or newer."
  )
elseif(
  CMAKE_C_COMPILER_ID STREQUAL "GNU"
  AND CMAKE_C_COMPILER_VERSION VERSION_LESS 4.6
)
  # PHP also has a minimum gcc version required in an undocumented way.
  # See: https://github.com/php/php-src/pull/15397
  message(
    FATAL_ERROR
    "GNU C compiler version ${CMAKE_C_COMPILER_VERSION} is not supported. "
    "Please upgrade GNU C compiler to at least 4.6 or newer."
  )
elseif(
  CMAKE_SYSTEM_NAME STREQUAL "Windows"
  AND CMAKE_C_COMPILER_ID MATCHES "Clang"
  AND CMAKE_C_COMPILER_VERSION VERSION_LESS 4
)
  # Clang on Windows has minimum required version:
  # https://github.com/php/php-src/pull/15415
  message(
    FATAL_ERROR
    "Clang C compiler version ${CMAKE_C_COMPILER_VERSION} is not supported. "
    "Please upgrade Clang C compiler to at least 4.0 or newer."
  )
endif()

################################################################################
# Check whether the system uses EBCDIC (not ASCII) as its native character set.
################################################################################

message(CHECK_START "Checking system character set")
if(CMAKE_CROSSCOMPILING AND NOT CMAKE_CROSSCOMPILING_EMULATOR)
  # EBCDIC targets are obsolete, assume that target uses ASCII when
  # cross-compiling without emulator.
  set(PHP_EBCDIC_EXITCODE 1)
endif()

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_source_runs(C [[
    int main(void) { return (unsigned char)'A' != (unsigned char)0xC1; }
  ]] PHP_EBCDIC)
cmake_pop_check_state()

if(PHP_EBCDIC)
  message(CHECK_FAIL "EBCDIC")
  message(FATAL_ERROR "PHP does not support EBCDIC targets.")
else()
  message(CHECK_PASS "ASCII")
endif()

################################################################################
# Find mailer.
################################################################################

find_package(Sendmail)

################################################################################
# Find PHP installed on the system and set PHP_HOST_EXECUTABLE for development
# such as generating stubs (*_arginfo.h) with build/gen_stub.php, running PHP
# scripts Zend/zend_vm_gen.php and similar. Otherwise the sapi/cli executable
# will be used at the build phase, where possible. The minimum version should
# match the version required to run these PHP scripts.
################################################################################

set(PHP_ARTIFACTS_PREFIX "_HOST")
find_package(PHP 8.0 COMPONENTS Interpreter)
unset(PHP_ARTIFACTS_PREFIX)

# Force further find_package(PHP REQUIRED) calls in php-src as found.
set(PHP_FORCE_AS_FOUND TRUE)
