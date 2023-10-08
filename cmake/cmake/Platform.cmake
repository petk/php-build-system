#[=============================================================================[
Platform specific configuration.
]=============================================================================]#

message(STATUS "Host system: ${CMAKE_HOST_SYSTEM}")
message(STATUS "Target system: ${CMAKE_SYSTEM}")

add_compile_definitions("$<$<COMPILE_LANGUAGE:C>:_GNU_SOURCE>")

# Set GNU standard installation directories.
include(GNUInstallDirs)

if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  set(DARWIN 1 CACHE INTERNAL "Define if the target system is Darwin")
endif()

if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
  # TODO: Fix this properly and add it to required definitions.
  set(_DARWIN_C_SOURCE 1 CACHE INTERNAL "")

  # On macOS, the ar command runs the ranlib, which causes the "has no symbols" errors.
  message(STATUS "Setting -no_warning_for_no_symbols for targets")

  set(CMAKE_C_ARCHIVE_CREATE   "<CMAKE_AR> Scr <TARGET> <LINK_FLAGS> <OBJECTS>")
  set(CMAKE_CXX_ARCHIVE_CREATE "<CMAKE_AR> Scr <TARGET> <LINK_FLAGS> <OBJECTS>")
  set(CMAKE_ASM_ARCHIVE_CREATE "<CMAKE_AR> Scr <TARGET> <LINK_FLAGS> <OBJECTS>")

  # Xcode's libtool supports the -no_warning_for_no_symbols but llvm-ranlib doesn't.
  if(NOT ${CMAKE_RANLIB} MATCHES ".*llvm-ranlib$")
    set(CMAKE_C_ARCHIVE_FINISH   "<CMAKE_RANLIB> -no_warning_for_no_symbols -c <TARGET>")
    set(CMAKE_CXX_ARCHIVE_FINISH "<CMAKE_RANLIB> -no_warning_for_no_symbols -c <TARGET>")
    set(CMAKE_ASM_ARCHIVE_FINISH "<CMAKE_RANLIB> -no_warning_for_no_symbols -c <TARGET>")
  endif()
endif()

# TODO: Fix these properly if really needed.
set(_TANDEM_SOURCE 1 CACHE INTERNAL "")
set(__STDC_WANT_MATH_SPEC_FUNCS__ 1 CACHE INTERNAL "")
set(__STDC_WANT_LIB_EXT2__ 1 CACHE INTERNAL "")
set(__STDC_WANT_IEC_60559_FUNCS_EXT__ 1 CACHE INTERNAL "")
set(ODBCVER 0x0350 CACHE INTERNAL "")
set(STDC_HEADERS 1 CACHE INTERNAL "")
set(_ALL_SOURCE 1 CACHE INTERNAL "")
set(__EXTENSIONS__ 1 CACHE INTERNAL "")
set(_GNU_SOURCE 1 CACHE INTERNAL "")
set(_POSIX_PTHREAD_SEMANTICS 1 CACHE INTERNAL "")
set(__STDC_WANT_IEC_60559_ATTRIBS_EXT__ 1 CACHE INTERNAL "")
set(__STDC_WANT_IEC_60559_BFP_EXT__ 1 CACHE INTERNAL "")
set(__STDC_WANT_IEC_60559_DFP_EXT__ 1 CACHE INTERNAL "")
set(__STDC_WANT_IEC_60559_TYPES_EXT__ 1 CACHE INTERNAL "")
set(_OPENBSD_SOURCE 1 CACHE INTERNAL "")
# TODO: See ext/pcre/pcre2lib.
set(_NETBSD_SOURCE 1 CACHE INTERNAL "")
set(_HPUX_ALT_XOPEN_SOCKET_API 1 CACHE INTERNAL "")