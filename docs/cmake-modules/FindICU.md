# FindICU

Find the ICU library.

See: https://cmake.org/cmake/help/latest/module/FindICU.html

This module overrides the upstream CMake FindICU module with few customizations:

- Added pkgconf.
- Marked ICU_INCLUDE_DIR as advanced variable (fixed upstream in CMake 3.29).
