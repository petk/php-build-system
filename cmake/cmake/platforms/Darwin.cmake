#[=============================================================================[
Specific configuration for Darwin platform (macOS, OS X, etc.).
]=============================================================================]#

include_guard(GLOBAL)

include(CheckLinkerFlag)

if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
  # On macOS, the ar command runs the ranlib, which causes the "has no symbols"
  # errors.
  message(STATUS "Setting -no_warning_for_no_symbols for targets")

  set(CMAKE_C_ARCHIVE_CREATE   "<CMAKE_AR> Scr <TARGET> <LINK_FLAGS> <OBJECTS>")
  set(CMAKE_CXX_ARCHIVE_CREATE "<CMAKE_AR> Scr <TARGET> <LINK_FLAGS> <OBJECTS>")
  set(CMAKE_ASM_ARCHIVE_CREATE "<CMAKE_AR> Scr <TARGET> <LINK_FLAGS> <OBJECTS>")

  # Xcode's libtool supports the -no_warning_for_no_symbols but llvm-ranlib
  # doesn't.
  if(NOT CMAKE_RANLIB MATCHES ".*llvm-ranlib$")
    set(CMAKE_C_ARCHIVE_FINISH   "<CMAKE_RANLIB> -no_warning_for_no_symbols -c <TARGET>")
    set(CMAKE_CXX_ARCHIVE_FINISH "<CMAKE_RANLIB> -no_warning_for_no_symbols -c <TARGET>")
    set(CMAKE_ASM_ARCHIVE_FINISH "<CMAKE_RANLIB> -no_warning_for_no_symbols -c <TARGET>")
  endif()
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  set(DARWIN 1 CACHE INTERNAL "Define if the target system is Darwin")

  # TODO: This is still needed for shared extensions on macOS, otherwise
  # undefined symbol errors happen in the linking step when using Clang.
  check_linker_flag(
    C
    "LINKER:-undefined,dynamic_lookup"
    HAVE_UNDEFINED_DYNAMIC_LOOKUP_FLAG_C
  )
  if(HAVE_UNDEFINED_DYNAMIC_LOOKUP_FLAG_C)
    target_link_options(
      php_configuration
      INTERFACE
        $<$<IN_LIST:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>:LINKER:-undefined,dynamic_lookup>
    )
  endif()

  # Help Darwin systems a bit, because these are not available there.
  set(SAPI_FPM_SYSTEMD OFF)
  set(SAPI_FPM_ACL OFF)
  set(SAPI_FPM_APPARMOR OFF)
  set(SAPI_FPM_SELINUX OFF)
endif()
