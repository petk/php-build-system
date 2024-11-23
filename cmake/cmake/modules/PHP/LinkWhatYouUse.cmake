#[=============================================================================[
# PHP/LinkWhatYouUse

Check whether to enable `CMAKE_LINK_WHAT_YOU_USE`.

When enabled, warnings are emitted during the build phase for diagnostic
purposes if any unused libraries are linked to executables and shared or module
libraries. The CMake versions at the time of writing use `ldd -u -r` on ELF
platforms to determine unused linked libraries
(`CMAKE_LINK_WHAT_YOU_USE_CHECK`). This module also checks whether `ldd` is
available on the host platform and has required options. For example, on Haiku,
where `ldd` is not available, or on Solaris with different `ldd` implementation.

Caveats:

When `CMAKE_LINK_WHAT_YOU_USE` is enabled, CMake will add the `--no-as-needed`
linker flag to executables and shared or module libraries to be able to
determine the redundant libraries on targets. However, this shouldn't be done
for release builds and `CMAKE_LINK_WHAT_YOU_USE` should be disabled for the
`Release` build type to rely on system's default linker flag `--as-needed`, if
set. In ideal case scenario, the linked libraries should be added to targets
only if they are actually needed at the configuration time in the first place.

TODO: Fix unused direct dependencies warnings and add `option()` for
`CMAKE_LINK_WHAT_YOU_USE`.
#]=============================================================================]

include_guard(GLOBAL)

block(PROPAGATE CMAKE_LINK_WHAT_YOU_USE)
  message(CHECK_START "Checking whether to enable CMAKE_LINK_WHAT_YOU_USE")

  # Check whether CMAKE_LINK_WHAT_YOU_USE has been overridden by the user.
  if(DEFINED CMAKE_LINK_WHAT_YOU_USE)
    message(CHECK_PASS "CMAKE_LINK_WHAT_YOU_USE=${CMAKE_LINK_WHAT_YOU_USE}")
    return()
  endif()

  if(NOT CMAKE_EXECUTABLE_FORMAT STREQUAL "ELF")
    message(CHECK_FAIL "no (non-ELF platform)")
    return()
  endif()

  # Check whether ldd works as expected.
  execute_process(
    COMMAND ldd --help
    OUTPUT_VARIABLE output
    ERROR_QUIET
  )

  if(output MATCHES "(-r, --function-relocs.*-u, --unused.*)")
    set(CMAKE_LINK_WHAT_YOU_USE ON)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no (ldd unsupported)")
  endif()
endblock()
