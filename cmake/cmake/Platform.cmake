#[=============================================================================[
Platform specific configuration.
]=============================================================================]#

include_guard(GLOBAL)

message(STATUS "Host system: ${CMAKE_HOST_SYSTEM}")
message(STATUS "Target system: ${CMAKE_SYSTEM}")

# Enable C and POSIX extensions.
include(PHP/SystemExtensions)

target_compile_definitions(
  php_configuration
  INTERFACE
    $<$<COMPILE_LANGUAGE:ASM,C,CXX>:_GNU_SOURCE>
)

# Set GNU standard installation directories.
include(GNUInstallDirs)

set(CMAKE_INSTALL_INCLUDEDIR "${CMAKE_INSTALL_INCLUDEDIR}/php")

if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
  # On macOS, the ar command runs the ranlib, which causes the "has no symbols" errors.
  message(STATUS "Setting -no_warning_for_no_symbols for targets")

  set(CMAKE_C_ARCHIVE_CREATE   "<CMAKE_AR> Scr <TARGET> <LINK_FLAGS> <OBJECTS>")
  set(CMAKE_CXX_ARCHIVE_CREATE "<CMAKE_AR> Scr <TARGET> <LINK_FLAGS> <OBJECTS>")
  set(CMAKE_ASM_ARCHIVE_CREATE "<CMAKE_AR> Scr <TARGET> <LINK_FLAGS> <OBJECTS>")

  # Xcode's libtool supports the -no_warning_for_no_symbols but llvm-ranlib doesn't.
  if(NOT CMAKE_RANLIB MATCHES ".*llvm-ranlib$")
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
if(CMAKE_SYSTEM_PROCESSOR MATCHES "^alpha")
  if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
    target_compile_options(
      php_configuration
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C>:-mieee>
    )
  else()
    target_compile_options(
      php_configuration
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C>:-ieee>
    )
  endif()
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^sparc")
  if(CMAKE_C_COMPILER_ID STREQUAL "SunPro")
    target_compile_options(
      php_configuration
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C>:-xmemalign=8s>
    )
  endif()
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "SunOS")
  target_compile_definitions(
    php_configuration
    INTERFACE
      $<$<COMPILE_LANGUAGE:ASM,C,CXX>:_POSIX_PTHREAD_SEMANTICS>
  )
elseif(CMAKE_SYSTEM_NAME STREQUAL "HP-UX")
  target_compile_definitions(
    php_configuration
    INTERFACE
      $<$<COMPILE_LANG_AND_ID:ASM,GNU>:_XOPEN_SOURCE_EXTENDED>
      $<$<COMPILE_LANG_AND_ID:C,GNU>:_XOPEN_SOURCE_EXTENDED>
      $<$<COMPILE_LANG_AND_ID:CXX,GNU>:_XOPEN_SOURCE_EXTENDED>
  )
endif()

# Check unused linked libraries on executable and shared/module library targets.
include(PHP/LinkWhatYouUse)

# Platform specific configuration.
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  include(${CMAKE_CURRENT_LIST_DIR}/platform/Windows.cmake)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  include(${CMAKE_CURRENT_LIST_DIR}/platform/Darwin.cmake)
endif()
