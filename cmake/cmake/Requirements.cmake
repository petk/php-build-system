#[=============================================================================[
Check system requirements and validate basic configuration.
#]=============================================================================]

include_guard(GLOBAL)

include(CheckSourceRuns)
include(CMakePushCheckState)

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
# Find PHP installed on the system and set PHP_EXECUTABLE for development such
# as generating stubs (*_arginfo.h) with build/gen_stub.php, running PHP scripts
# Zend/zend_vm_gen.php and similar. Otherwise the sapi/cli executable will be
# used at the build phase, where possible. The minimum version should match the
# version required to run these PHP scripts.
################################################################################
block(PROPAGATE PHP_FOUND)
  find_package(PHP 7.4)
endblock()
