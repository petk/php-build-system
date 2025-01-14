#[=============================================================================[
# CheckFclose

Check if `fclose` declaration is missing. Some systems have broken header files
like SunOS has. This check is obsolete on current Solaris/illumos versions.

## Result variables

* `MISSING_FCLOSE_DECL`
#]=============================================================================]

include_guard(GLOBAL)

# Skip in consecutive configuration phases.
if(DEFINED MISSING_FCLOSE_DECL)
  return()
endif()

include(CheckSymbolExists)
include(CMakePushCheckState)

message(CHECK_START "Checking fclose declaration")

# Checking if symbol exists also checks if it is declared.
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_symbol_exists(fclose stdio.h _PHP_HAVE_FCLOSE)
cmake_pop_check_state()

set(
  MISSING_FCLOSE_DECL
  ""
  CACHE INTERNAL
  "Whether the 'fclose()' declaration is missing."
)

if(_PHP_HAVE_FCLOSE)
  message(CHECK_PASS "found")
  set_property(CACHE MISSING_FCLOSE_DECL PROPERTY VALUE FALSE)
else()
  message(CHECK_FAIL "missing")
  set_property(CACHE MISSING_FCLOSE_DECL PROPERTY VALUE TRUE)
endif()
