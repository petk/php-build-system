# FindCcache

Find the Ccache compiler cache tool for faster compilation times.

Result variables:

  Ccache_FOUND
    Whether the package has been found.
  Ccache_VERSION
    Package version, if found.

Cache variables:

  Ccache_EXECUTABLE
    The path to the ccache executable.

Hints:

  The Ccache_ROOT variable adds custom search path.

  CCACHE_DISABLE environment variable disables the ccache and doesn't add it to
  C and CXX launcher, see Ccache documentation for more info.
