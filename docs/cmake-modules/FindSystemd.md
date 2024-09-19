# FindSystemd

Find the systemd library (libsystemd).

Module defines the following IMPORTED target(s):

  Systemd::Systemd
    The package library, if found.

Result variables:

  Systemd_FOUND
    Whether the package has been found.
  Systemd_INCLUDE_DIRS
    Include directories needed to use this package.
  Systemd_LIBRARIES
    Libraries needed to link to the package library.
  Systemd_VERSION
    Package version, if found.

Cache variables:

  Systemd_INCLUDE_DIR
    Directory containing package library headers.
  Systemd_LIBRARY
    The path to the package library.
  Systemd_EXECUTABLE
    A systemd command-line tool, if available.

Hints:

  The Systemd_ROOT variable adds custom search path.
