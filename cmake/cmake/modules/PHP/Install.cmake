#[=============================================================================[
# PHP/Install

Set the `CMAKE_INSTALL_*` variables inside the `install(CODE|SCRIPT)`.

This is built on top of the CMake's
[`GNUInstallDirs`](https://cmake.org/cmake/help/latest/module/GNUInstallDirs.html)
module and the
[`install()`](https://cmake.org/cmake/help/latest/command/install.html) command.
At the time of writing, CMake documentation mentions special cases where, for
example, the `CMAKE_INSTALL_FULL_SYSCONFDIR` variable becomes the `/etc`, when
the install prefix is `/usr`, and similar.

However, some of these special cases aren't taken into account when using the
`install()` commands. See: https://gitlab.kitware.com/cmake/cmake/-/issues/25852

This module exposes the following function:

```cmake
php_install(CODE <code> ...)
```

It acts the same as `install(CODE <code> ...)`, except that also the
`CMAKE_INSTALL_*` variables are available inside the <code> argument, like in
the rest of the CMake code.

```cmake
php_install(CODE "
  message(STATUS \"CMAKE_INSTALL_SYSCONFDIR=\${CMAKE_INSTALL_SYSCONFDIR}\")
")
```
#]=============================================================================]

include_guard(GLOBAL)

if(NOT CMAKE_SCRIPT_MODE_FILE)
  include(GNUInstallDirs)
endif()

function(_php_install_set_absolute var)
  if(IS_ABSOLUTE "${CMAKE_INSTALL_${var}}")
    set(CMAKE_INSTALL_FULL_${var} "${CMAKE_INSTALL_${var}}" PARENT_SCOPE)
  else()
    set(
      CMAKE_INSTALL_FULL_${var}
      "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_${var}}"
      PARENT_SCOPE
    )
  endif()
endfunction()

function(_php_install_set_absolute_special var)
  if(var STREQUAL "RUNSTATEDIR")
    set(directoryName "var/run")
  elseif(var STREQUAL "LOCALSTATEDIR")
    set(directoryName "var")
  elseif(var STREQUAL "SYSCONFDIR")
    set(directoryName "etc")
  else()
    message(
      FATAL_ERROR
      "CMAKE_INSTALL_${var} is not a special-case GNU standard variable")
  endif()

  if(IS_ABSOLUTE "${CMAKE_INSTALL_${var}}")
    set(dir "${CMAKE_INSTALL_${var}}")
    set(fulldir "${CMAKE_INSTALL_${var}}")
  elseif(
    CMAKE_INSTALL_${var} MATCHES "^(etc|var|var/run)$"
    AND CMAKE_INSTALL_PREFIX MATCHES "^/usr[/]?$"
  )
    set(dir "${CMAKE_INSTALL_${var}}")
    set(fulldir "/${CMAKE_INSTALL_${var}}")
  elseif(
    CMAKE_INSTALL_${var} MATCHES "^(etc|var|var/run)$"
    AND NOT CMAKE_INSTALL_PREFIX MATCHES "^/opt/homebrew$|^/opt/homebrew/.*$"
    AND CMAKE_INSTALL_PREFIX MATCHES "^/opt/(.*)"
  )
    set(dir "${CMAKE_INSTALL_${var}}")
    set(fulldir "/${directoryName}/opt/${CMAKE_MATCH_1}")
  else()
    set(dir "${CMAKE_INSTALL_${var}}")
    set(fulldir "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_${var}}")
  endif()

  set(CMAKE_INSTALL_${var} "${dir}" PARENT_SCOPE)
  set(CMAKE_INSTALL_FULL_${var} "${fulldir}" PARENT_SCOPE)
endfunction()

macro(_php_install_gnu_install_dirs)
  foreach(
    var
      BINDIR
      SBINDIR
      LIBEXECDIR
      SHAREDSTATEDIR
      LIBDIR
      INCLUDEDIR
      OLDINCLUDEDIR
      DATAROOTDIR
      DATADIR
      INFODIR
      LOCALEDIR
      MANDIR
      DOCDIR
  )
    _php_install_set_absolute(${var})
  endforeach()

  _php_install_set_absolute_special(LOCALSTATEDIR)
  _php_install_set_absolute_special(RUNSTATEDIR)
  _php_install_set_absolute_special(SYSCONFDIR)
endmacro()

function(php_install type code)
  if(NOT type STREQUAL "CODE")
    message(FATAL_ERROR "Type ${type} is not supported.")
  endif()

  install(CODE "
    set(CMAKE_INSTALL_BINDIR \"${CMAKE_INSTALL_BINDIR}\")
    set(CMAKE_INSTALL_SBINDIR \"${CMAKE_INSTALL_SBINDIR}\")
    set(CMAKE_INSTALL_LIBEXECDIR \"${CMAKE_INSTALL_LIBEXECDIR}\")
    set(CMAKE_INSTALL_SYSCONFDIR \"${CMAKE_INSTALL_SYSCONFDIR}\")
    set(CMAKE_INSTALL_SHAREDSTATEDIR \"${CMAKE_INSTALL_SHAREDSTATEDIR}\")
    set(CMAKE_INSTALL_LOCALSTATEDIR \"${CMAKE_INSTALL_LOCALSTATEDIR}\")
    set(CMAKE_INSTALL_RUNSTATEDIR \"${CMAKE_INSTALL_RUNSTATEDIR}\")
    set(CMAKE_INSTALL_LIBDIR \"${CMAKE_INSTALL_LIBDIR}\")
    set(CMAKE_INSTALL_INCLUDEDIR \"${CMAKE_INSTALL_INCLUDEDIR}\")
    set(CMAKE_INSTALL_OLDINCLUDEDIR \"${CMAKE_INSTALL_OLDINCLUDEDIR}\")
    set(CMAKE_INSTALL_DATAROOTDIR \"${CMAKE_INSTALL_DATAROOTDIR}\")
    set(CMAKE_INSTALL_DATADIR \"${CMAKE_INSTALL_DATADIR}\")
    set(CMAKE_INSTALL_INFODIR \"${CMAKE_INSTALL_INFODIR}\")
    set(CMAKE_INSTALL_LOCALEDIR \"${CMAKE_INSTALL_LOCALEDIR}\")
    set(CMAKE_INSTALL_MANDIR \"${CMAKE_INSTALL_MANDIR}\")
    set(CMAKE_INSTALL_DOCDIR \"${CMAKE_INSTALL_DOCDIR}\")

    include(${CMAKE_CURRENT_FUNCTION_LIST_FILE})

    _php_install_gnu_install_dirs()

    ${code}
  " ${ARGN})
endfunction()
