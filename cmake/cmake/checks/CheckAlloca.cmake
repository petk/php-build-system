#[=============================================================================[
This check determines whether the system supports alloca() and follows the
behavior of Autoconf's AC_FUNC_ALLOCA macro, with some adjustments for obsolete
systems:

* Autoconf also checks whether <alloca.h> works on certain obsolete systems.
* Autoconf provides variable substitution to integrate a custom alloca.c
  implementation if alloca() is not available on the system. However, PHP
  doesn't use this feature.

Result variables:

* HAVE_ALLOCA
* HAVE_ALLOCA_H
#]=============================================================================]

include(CheckIncludeFiles)
include(CheckSymbolExists)

# On Windows, alloca is defined in malloc.h as _alloca. Cache variables are
# overridden to speed up the check and commands used for documentation purposes.
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(PHP_HAS_ALLOCA_H FALSE)
  set(PHP_HAS_ALLOCA TRUE)
  check_symbol_exists(alloca malloc.h PHP_HAS_ALLOCA)
else()
  check_include_files(alloca.h PHP_HAS_ALLOCA_H)

  if(PHP_HAS_ALLOCA_H)
    # Most *.nix systems (Linux, macOS, Solaris/illumos, Haiku).
    check_symbol_exists(alloca alloca.h PHP_HAS_ALLOCA)
  else()
    # BSD-based systems, old Linux.
    check_symbol_exists(alloca stdlib.h PHP_HAS_ALLOCA)
  endif()
endif()

set(HAVE_ALLOCA ${PHP_HAS_ALLOCA})
set(HAVE_ALLOCA_H ${PHP_HAS_ALLOCA_H})
