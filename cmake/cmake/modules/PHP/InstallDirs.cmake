#[=============================================================================[
# PHP/InstallDirs

This module is built on top of the CMake's GNUInstallDirs module and bypasses
some of its known issues when the GNU standards special cases are applied based
on the installation prefix (`CMAKE_INSTALL_PREFIX`). For example, when the
installation prefix is set to `/usr`, the `CMAKE_INSTALL_FULL_SYSCONF` variable
should be set to `/etc` and not `/usr/etc`, or the `CMAKE_INSTALL_LIBDIR`
variable on Debian-based machines should be `lib/<multiarch-tuple>` and not only
`lib` or `lib64`. And similar.

See: https://cmake.org/cmake/help/latest/module/GNUInstallDirs.html

This module solves the following issues:

* When setting the installation prefix in the installation phase (after the
  configuration and build phases) with the `--prefix` option:

  ```sh
  cmake --install <build-dir> --prefix <installation-prefix>
  ```

  the installation variables are adjusted according to GNU standards.

* It provides additional installation variables, for using them in the CMake's
  `install()` commands. The following variables:

  * `CMAKE_INSTALL_LIBDIR`
  * `CMAKE_INSTALL_LOCALSTATEDIR`
  * `CMAKE_INSTALL_RUNSTATEDIR`
  * `CMAKE_INSTALL_SYSCONF`

  can be replaced with their `PHP_INSTALL_*` substitutes, and the paths will be
  set according to the GNU standards.

  For example:

  ```cmake
  install(TARGETS foo LIBRARY DESTINATION ${PHP_INSTALL_LIBDIR})
  install(DIRECTORY DESTINATION ${PHP_INSTALL_LOCALSTATEDIR}/log)
  install(DIRECTORY DESTINATION ${PHP_INSTALL_RUNSTATEDIR})
  install(FILES foo.conf DESTINATION ${PHP_INSTALL_SYSCONFDIR})
  ```

* It enables `CMAKE_INSTALL_*` variables of the `GNUInstallDirs` module in the
 `install(CODE)` and `install(SCRIPT)`.

## Basic usage

```cmake
# CMakeLists.txt

include(PHP/InstallDirs)

install(TARGETS foo LIBRARY DESTINATION ${PHP_INSTALL_LIBDIR})
install(DIRECTORY DESTINATION ${PHP_INSTALL_LOCALSTATEDIR}/log)
install(DIRECTORY DESTINATION ${PHP_INSTALL_RUNSTATEDIR})
install(FILES foo.conf DESTINATION ${PHP_INSTALL_SYSCONFDIR})
install(CODE [[
  # Here the absolute libdir path is available, based on the platform and
  # installation prefix.
  message(STATUS "CMAKE_INSTALL_FULL_LIBDIR=${CMAKE_INSTALL_FULL_LIBDIR}")
]])
#]=============================================================================]

include_guard(GLOBAL)

if(IS_ABSOLUTE "${CMAKE_INSTALL_LIBDIR}")
  set(PHP_INSTALL_LIBDIR "${CMAKE_INSTALL_LIBDIR}")
else()
  set(PHP_INSTALL_LIBDIR "\${CMAKE_INSTALL_LIBDIR}")
endif()

if(IS_ABSOLUTE "${CMAKE_INSTALL_LOCALSTATEDIR}")
  set(PHP_INSTALL_LOCALSTATEDIR "${CMAKE_INSTALL_LOCALSTATEDIR}")
else()
  set(PHP_INSTALL_LOCALSTATEDIR "/\${PHP_INSTALL_LOCALSTATEDIR}")
endif()

if(IS_ABSOLUTE "${CMAKE_INSTALL_RUNSTATEDIR}")
  set(PHP_INSTALL_RUNSTATEDIR "${CMAKE_INSTALL_RUNSTATEDIR}")
else()
  set(PHP_INSTALL_RUNSTATEDIR "/\${PHP_INSTALL_RUNSTATEDIR}")
endif()

if(IS_ABSOLUTE "${CMAKE_INSTALL_SYSCONFDIR}")
  set(PHP_INSTALL_SYSCONFDIR "${CMAKE_INSTALL_SYSCONFDIR}")
else()
  set(PHP_INSTALL_SYSCONFDIR "/\${PHP_INSTALL_SYSCONFDIR}")
endif()

set(code "")
foreach(
  var
    BINDIR
    DATADIR
    DATAROOTDIR
    DOCDIR
    INCLUDEDIR
    INFODIR
    LIBDIR
    LIBEXECDIR
    LOCALEDIR
    LOCALSTATEDIR
    MANDIR
    OLDINCLUDEDIR
    RUNSTATEDIR
    SBINDIR
    SHAREDSTATEDIR
    SYSCONFDIR
)
  get_property(helpString CACHE CMAKE_INSTALL_${var} PROPERTY HELPSTRING)
  if(helpString STREQUAL "No help, variable specified on the command line.")
    string(CONFIGURE [[
      @code@
      set(CMAKE_INSTALL_@var@ "${CMAKE_INSTALL_@var@}")
    ]] code)
  endif()
endforeach()

# Define GNU standard installation directories.
include(GNUInstallDirs)

string(CONFIGURE [[
######################## Added by PHP/InstallDirs.cmake ########################
@code@
set(CMAKE_SYSTEM_NAME "@CMAKE_SYSTEM_NAME@")
set(CMAKE_SIZEOF_VOID_P "@CMAKE_SIZEOF_VOID_P@")
set(CMAKE_LIBRARY_ARCHITECTURE "@CMAKE_LIBRARY_ARCHITECTURE@")
include(GNUInstallDirs)

set(PHP_INSTALL_LOCALSTATEDIR "${CMAKE_INSTALL_FULL_LOCALSTATEDIR}")
cmake_path(GET PHP_INSTALL_LOCALSTATEDIR RELATIVE_PART PHP_INSTALL_LOCALSTATEDIR)

set(PHP_INSTALL_RUNSTATEDIR "${CMAKE_INSTALL_FULL_RUNSTATEDIR}")
cmake_path(GET PHP_INSTALL_RUNSTATEDIR RELATIVE_PART PHP_INSTALL_RUNSTATEDIR)

set(PHP_INSTALL_SYSCONFDIR "${CMAKE_INSTALL_FULL_SYSCONFDIR}")
cmake_path(GET PHP_INSTALL_SYSCONFDIR RELATIVE_PART PHP_INSTALL_SYSCONFDIR)
############################ PHP/InstallDirs.cmake #############################
]] code @ONLY)
install(CODE "${code}" ALL_COMPONENTS)

unset(code)
