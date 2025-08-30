#[=============================================================================[
Configuration specific to Haiku operating system.
#]=============================================================================]

include_guard(GLOBAL)

include(CheckLinkerFlag)

if(CMAKE_SYSTEM_NAME STREQUAL "Haiku")
  # Explicitly add linker flag to disable executable stack. Zend/asm files
  # already contain the '.note.GNU-stack' directives where needed, but linker on
  # Haiku at time of this writing emits warnings without this flag as it seems
  # to handle PT_GNU_STACK differently to other Unix-like platforms.
  check_linker_flag(C "LINKER:-z,noexecstack" PHP_HAS_NOEXECSTACK_FLAG_C)
  if(PHP_HAS_NOEXECSTACK_FLAG_C)
    target_link_options(
      php_config
      INTERFACE $<$<LINK_LANGUAGE:C>:LINKER:-z,noexecstack>
    )
  endif()

  check_linker_flag(CXX "LINKER:-z,noexecstack" PHP_HAS_NOEXECSTACK_FLAG_CXX)
  if(PHP_HAS_NOEXECSTACK_FLAG_CXX)
    target_link_options(
      php_config
      INTERFACE $<$<LINK_LANGUAGE:CXX>:LINKER:-z,noexecstack>
    )
  endif()
endif()
