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

# Set to 0 if curl library is linked against OpenSSL 1.1 or earlier, and to 1 if
# or greater if it is linked against newer OpenSSL.
set(HAVE_CURL_OLD_OPENSSL_EXITCODE 4)

# Set to 0 if the bundled PCRE library can have JIT supported on the target
# architecture, and to 1 if not.
set(HAVE_PCRE_JIT_SUPPORT_EXITCODE 0)

# Set to 0 if fopencookie seeker uses off64_t, and to 1 if regular off_t type
# can be used.
set(COOKIE_SEEKER_USES_OFF64_T_EXITCODE 0)

# Set to 0 if reentrant time-related functions are HP-UX style, and to 1 if not.
set(PHP_HPUX_TIME_R_EXITCODE 1)

# Set to 0 if reentrant time-related functions are IRIX style, and to 1 if not.
set(PHP_IRIX_TIME_R_EXITCODE 1)

# Set the exit code whether the external gd library has support for the given
# format.
set(HAVE_GD_PNG_EXITCODE 1)
set(HAVE_GD_AVIF_EXITCODE 1)
set(HAVE_GD_WEBP_EXITCODE 1)
set(HAVE_GD_JPG_EXITCODE 1)
set(HAVE_GD_XPM_EXITCODE 1)
set(HAVE_GD_BMP_EXITCODE 1)
set(HAVE_GD_TGA_EXITCODE 1)

# Set to 0 if syscall to create shadow stack exists, and to 1 if it doesn't.
set(SHADOW_STACK_SYSCALL_EXITCODE 1)

# Set to exit code for the getaddrinfo() check.
set(HAVE_GETADDRINFO_EXITCODE 0)

# Set to exit code for the writing to stdout check.
set(PHP_WRITE_STDOUT_EXITCODE 0)

# TODO: Fix this better.
set(ZEND_MM_OUTPUT "(size_t)8 (size_t)3 0")

# Set to exit code of the stack limit check.
set(ZEND_CHECK_STACK_LIMIT_EXITCODE 1)
