#[=============================================================================[
Specific configuration for Darwin platform (macOS, OS X, etc.).
#]=============================================================================]

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
  set(DARWIN TRUE)

  # Set -undefined <treatment> linker flag to "dynamic_lookup" (default
  # <treatment> is "error"). This is needed for shared and module PHP targets on
  # macOS, otherwise undefined symbol errors happen in the linking step.
  # Autotools with libtool here uses older "suppress" treatment instead and
  # "-flat_namespace" linker option.
  check_linker_flag(
    C
    "LINKER:-undefined,dynamic_lookup"
    PHP_HAS_UNDEFINED_DYNAMIC_LOOKUP_FLAG_C
  )
  if(PHP_HAS_UNDEFINED_DYNAMIC_LOOKUP_FLAG_C)
    target_link_options(
      php_config
      INTERFACE
        $<$<AND:$<LINK_LANGUAGE:C>,$<IN_LIST:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>>:LINKER:-undefined,dynamic_lookup>
    )
  endif()

  check_linker_flag(
    CXX
    "LINKER:-undefined,dynamic_lookup"
    PHP_HAS_UNDEFINED_DYNAMIC_LOOKUP_FLAG_CXX
  )
  if(PHP_HAS_UNDEFINED_DYNAMIC_LOOKUP_FLAG_CXX)
    target_link_options(
      php_config
      INTERFACE
        $<$<AND:$<LINK_LANGUAGE:CXX>,$<IN_LIST:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>>:LINKER:-undefined,dynamic_lookup>
    )
  endif()
endif()
