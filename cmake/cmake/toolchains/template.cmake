# This is a list of all exitcodes or result variables required when
# cross-compiling to help identify the target system when cross-compiling
# emulator is not available.

# Set the exit code for the GNU C compiler with broken strlen check.
set(HAVE_BROKEN_OPTIMIZE_STRLEN_EXITCODE 1)

# Set the exit code for the clock_get_time() check.
set(HAVE_CLOCK_GET_TIME_EXITCODE 0)

# Set the exit code if flush should be called explicitly after a buffered io.
set(HAVE_FLUSHIO_EXITCODE 1)

# Set the exit code for the POSIX fnmatch() check.
set(HAVE_FNMATCH_EXITCODE 0)

# Set the exit code for the check whether the curl library is linked with
# OpenSSL 1.1 or earlier.
set(HAVE_CURL_OLD_OPENSSL_EXITCODE 4)

# Set the exit code for the check whether the bundled PCRE library has JIT
# supported on the target architecture.
set(HAVE_PCRE_JIT_SUPPORT_EXITCODE 0)

# Set the exit code for the fopencookie seeker using off64_t check.
set(COOKIE_SEEKER_USES_OFF64_T_EXITCODE 0)

# Set the exit code for the check of reentrant time-related functions being HP-UX
# style.
set(PHP_HPUX_TIME_R_EXITCODE 1)

# Set the exit code for the check of reentrant time-related functions being IRIX
# style.
set(PHP_IRIX_TIME_R_EXITCODE 1)

# Set the exit code for the check whether the external gd library has support
# for the given format.
set(HAVE_GD_PNG_EXITCODE 1)
set(HAVE_GD_AVIF_EXITCODE 1)
set(HAVE_GD_WEBP_EXITCODE 1)
set(HAVE_GD_JPG_EXITCODE 1)
set(HAVE_GD_XPM_EXITCODE 1)
set(HAVE_GD_BMP_EXITCODE 1)
set(HAVE_GD_TGA_EXITCODE 1)

# Set the exit code for the check if syscall to create shadow stack exists.
set(SHADOW_STACK_SYSCALL_EXITCODE 1)

# Set the exit code for the getaddrinfo() check.
set(HAVE_GETADDRINFO_EXITCODE 0)

# Set the exit code for the writing to stdout check.
set(PHP_WRITE_STDOUT_EXITCODE 0)

# Set the exit code of the stack limit check.
set(ZEND_CHECK_STACK_LIMIT_EXITCODE 1)

# Set the exit code of the ttyname_r check.
set(HAVE_TTYNAME_R_EXITCODE 0)

# Set the exit code of the pread check.
set(HAVE_PREAD_EXITCODE 0)
set(PHP_PREAD_64_EXITCODE 0)

# Set the exit code of the pwrite check.
set(HAVE_PWRITE_EXITCODE 0)
set(PHP_PWRITE_64_EXITCODE 0)

# Set the exit code of the iconv //IGNORE check.
set(ICONV_BROKEN_IGNORE_EXITCODE 1)

# Set the exit code of the iconv errno check.
set(PHP_ICONV_ERRNO_WORKS_EXITCODE 0)

# Set the exit code of the ptrace check for PHP FPM.
set(HAVE_PTRACE_EXITCODE 0)

# Set the exit code of SysV IPC shared memory check in opcache extension.
set(HAVE_SHM_IPC_EXITCODE 0)

# Set the exit code of the mmap() using MAP_ANON shared memory check in opcache
# extension.
set(HAVE_SHM_MMAP_ANON_EXITCODE 0)

# Set the exit code of the shm_open() shared memory check in opcache extension.
set(HAVE_SHM_MMAP_POSIX_EXITCODE 0)

# TODO: Fix this better.
set(ZEND_MM_OUTPUT "(size_t)8 (size_t)3 0")

# Set the exit code of the sched_getcpu check.
set(HAVE_SCHED_GETCPU_EXITCODE 0)
