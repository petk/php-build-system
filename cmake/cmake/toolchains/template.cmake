# This is a list of all exitcodes or result variables required when
# cross-compiling to help identify the target system when cross-compiling
# emulator is not available.

# Set to 0 if GNU C compiler has broken strlen, and 1 if not.
set(HAVE_BROKEN_OPTIMIZE_STRLEN_EXITCODE 1)

# Set to 0 if target system has clock_get_time(), and to 1 if not.
set(HAVE_CLOCK_GET_TIME_EXITCODE 0)

# Set to 0 if flush should be called explicitly after a buffered io, and to 1 if
# not.
set(HAVE_FLUSHIO_EXITCODE 1)

# Set to 0 if target system has POSIX fnmatch() and to 0 if not.
set(HAVE_FNMATCH_EXITCODE 0)

# TODO: Fix this better.
set(ZEND_MM_OUTPUT "(size_t)8 (size_t)3 0")
