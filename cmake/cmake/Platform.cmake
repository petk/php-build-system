#[=============================================================================[
Platform specific configuration.
]=============================================================================]#

message(STATUS "Host system: ${CMAKE_HOST_SYSTEM}")
message(STATUS "Target system: ${CMAKE_SYSTEM}")

target_compile_definitions(
  php_configuration
  INTERFACE $<$<COMPILE_LANGUAGE:ASM,C,CXX>:_GNU_SOURCE>
)

# Set GNU standard installation directories.
include(GNUInstallDirs)

set(CMAKE_INSTALL_INCLUDEDIR "${CMAKE_INSTALL_INCLUDEDIR}/php")

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

# Detect C standard library implementation.
# TODO: Fix this better.
execute_process(
  COMMAND ldd --version
  OUTPUT_VARIABLE _php_ldd_version
  ERROR_QUIET
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
if(_php_ldd_version MATCHES ".*musl libc.*")
  set(__MUSL__ 1 CACHE INTERNAL "Whether musl libc is used")
  set(PHP_STD_LIBRARY "musl")
elseif(_php_ldd_version MATCHES ".*uclibc.*")
  set(PHP_STD_LIBRARY "uclibc")
endif()

# See bug #28605.
if(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^alpha")
  if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
    target_compile_options(php_configuration
      INTERFACE
        "$<$<COMPILE_LANGUAGE:ASM,C>:-mieee>"
    )
  else()
    target_compile_options(php_configuration
      INTERFACE
        "$<$<COMPILE_LANGUAGE:ASM,C>:-ieee>"
    )
  endif()
elseif(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^sparc")
  if(CMAKE_C_COMPILER_ID STREQUAL "SunPro")
    target_compile_options(php_configuration
      INTERFACE
        "$<$<COMPILE_LANGUAGE:ASM,C>:-xmemalign=8s>"
    )
  endif()
endif()

if(CMAKE_HOST_SYSTEM_NAME STREQUAL "SunOS")
  target_compile_definitions(php_configuration
    INTERFACE "$<$<COMPILE_LANGUAGE:ASM,C,CXX>:_POSIX_PTHREAD_SEMANTICS>"
  )
elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "HP-UX")
  target_compile_definitions(php_configuration
    INTERFACE
      "$<$<COMPILE_LANG_AND_ID:ASM,GNU>:_XOPEN_SOURCE_EXTENDED>"
      "$<$<COMPILE_LANG_AND_ID:C,GNU>:_XOPEN_SOURCE_EXTENDED>"
      "$<$<COMPILE_LANG_AND_ID:CXX,GNU>:_XOPEN_SOURCE_EXTENDED>"
  )
endif()

# TODO: Should this be removed?
if(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^mips")
  target_compile_definitions(php_configuration
    INTERFACE "$<$<COMPILE_LANGUAGE:ASM,C,CXX>:_XPG_IV>"
  )
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
