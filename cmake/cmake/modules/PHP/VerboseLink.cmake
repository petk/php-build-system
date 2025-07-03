#[=============================================================================[
# PHP/VerboseLink

This module checks whether to enable verbose output by linker:

```cmake
include(PHP/VerboseLink)
```

This module provides the `PHP_VERBOSE_LINK` option to control enabling the
verbose link output. Verbose linker flag is added to the global `php_config`
target.

## Examples

When configuring project, enable the `PHP_VERBOSE_LINK` option to get verbose
output at the link step:

```sh
cmake -B php-build -D PHP_VERBOSE_LINK=ON
cmake --build php-build -j
```
#]=============================================================================]

include_guard(GLOBAL)

include(CheckLinkerFlag)

option(PHP_VERBOSE_LINK "Whether to show additional info at the link step")
mark_as_advanced(PHP_VERBOSE_LINK)

if(NOT PHP_VERBOSE_LINK)
  return()
endif()

block()
  get_property(enabledLanguages GLOBAL PROPERTY ENABLED_LANGUAGES)

  foreach(lang IN ITEMS C CXX)
    if(NOT lang IN_LIST enabledLanguages)
      continue()
    endif()

    if(CMAKE_${lang}_COMPILER_LINKER_ID STREQUAL "MSVC")
      set(flags "LINKER:/VERBOSE")
    elseif(MSVC AND CMAKE_${lang}_COMPILER_LINKER_ID STREQUAL "LLD")
      set(flags "LINKER:-verbose")
    elseif(CMAKE_${lang}_COMPILER_LINKER_ID MATCHES "^(GNU|GNUgold|LLD)$")
      set(flags "LINKER:--verbose")
    else()
      set(flags "LINKER:--verbose")
      check_linker_flag(${lang} "${flags}" PHP_HAS_VERBOSE_LINK_FLAG_${lang})
      if(NOT PHP_HAS_VERBOSE_LINK_FLAG_${lang})
        set(flags "")
      endif()
    endif()

    if(flags)
      target_link_options(
        php_config
        INTERFACE $<$<LINK_LANGUAGE:${lang}>:${flags}>
      )
    endif()
  endforeach()
endblock()
