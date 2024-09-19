#[=============================================================================[
Check if `fclose` declaration is missing. Some systems have broken header files
like SunOS has. This check is obsolete on current Solaris/illumos versions.

Result variables:

* MISSING_FCLOSE_DECL
  Whether `fclose` declaration is missing.
#]=============================================================================]

include_guard(GLOBAL)

include(CheckSymbolExists)
include(CMakePushCheckState)

message(CHECK_START "Checking fclose declaration")

# Checking if symbol exists also checks if it is declared.
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_symbol_exists(fclose stdio.h _HAVE_FCLOSE)
cmake_pop_check_state()

if(NOT _HAVE_FCLOSE)
  message(CHECK_FAIL "missing")
  set(MISSING_FCLOSE_DECL 1)
else()
  message(CHECK_PASS "found")
endif()
