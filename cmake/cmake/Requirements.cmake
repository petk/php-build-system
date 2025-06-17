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
  set(PHP_IS_EBCDIC_EXITCODE 1)
endif()

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_source_runs(C [[
    int main(void) { return (unsigned char)'A' != (unsigned char)0xC1; }
  ]] PHP_IS_EBCDIC)
cmake_pop_check_state()

if(PHP_IS_EBCDIC)
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
# Find PHP installed on the system for generating stub files (*_arginfo.h),
# Zend/zend_vm_gen.php, and similar where it can be used. Otherwise the built
# cli SAPI is used at the build phase. Minimum supported version for
# gen_stub.php is PHP 7.4.
################################################################################
find_package(PHPSystem 7.4)
