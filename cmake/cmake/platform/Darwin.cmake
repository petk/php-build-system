#[=============================================================================[
Specific configuration for Darwin target (macOS, OS X, etc.).
]=============================================================================]#

include_guard(GLOBAL)

include(CheckLinkerFlag)

set(DARWIN 1 CACHE INTERNAL "Define if the target system is Darwin")

# TODO: This is still needed for shared extensions on macOS, otherwise undefined
# symbol errors happen in the linking step when using Clang.
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
