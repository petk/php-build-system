# An example toolchain template when cross-building PHP.

# These are always required to set:
set(CMAKE_C_COMPILER "")
set(CMAKE_CXX_COMPILER "")
set(CMAKE_SYSTEM_NAME "")
set(CMAKE_SYSTEM_PROCESSOR "")
set(CMAKE_FIND_ROOT_PATH "")

# This is a list of all exit codes or result variables required when
# cross-compiling to help identify the target system when the
# CMAKE_CROSSCOMPILING_EMULATOR is not available or other adjustments are needed
# for the target system.

################################################################################
# PHP
################################################################################

# Set the exit code if flush should be called explicitly after a buffered io.
set(PHP_HAVE_FLUSHIO_EXITCODE 1)

# Set the exit code whether the fnmatch() is available and POSIX-compatible.
set(PHP_HAVE_FNMATCH_EXITCODE 0)

# Set the exit code for the getaddrinfo() check.
set(PHP_HAVE_GETADDRINFO_EXITCODE 0)

# Set the exit code to 1 when using Clang 17 or later and -fno-sanitize=function
# needs to be added for the PHP_UNDEFINED_SANITIZER option, otherwise set to 0.
set(PHP_HAS_UBSAN_EXITCODE 0)

# Set the exit code for the writing to stdout check.
set(PHP_WRITE_STDOUT_EXITCODE 0)

################################################################################
# Zend Engine
################################################################################

# Set the exit code of the stack limit check.
set(PHP_ZEND_CHECK_STACK_LIMIT_EXITCODE 0)

# Set the exit code of the check if syscall to create shadow stack exists.
set(PHP_ZEND_SHADOW_STACK_SYSCALL_EXITCODE 1)

# Set the exit code and the output of the ZEND_MM check.
# See CheckMMAlignment.cmake.
set(ZEND_MM_EXITCODE 0)
set(ZEND_MM_EXITCODE__TRYRUN_OUTPUT "(size_t)8 (size_t)3 0")

################################################################################
# sapi/fpm
################################################################################

# Set the exit code of the ptrace() check.
set(PHP_SAPI_FPM_HAS_PTRACE_EXITCODE 0)

# Set the process memory access file - 'mem' on Linux-alike or 'as' on
# Solaris-alike target systems for the PHP FPM to use pread trace type
# (/proc/<pid>/<mem-or-as>), when neither 'ptrace' nor 'mach_vm_read' functions
# work.
set(PHP_SAPI_FPM_PROC_MEM_FILE mem)

################################################################################
# ext/gd
################################################################################

# Set the exit code for the check whether the external gd library has support
# for the given format.
set(PHP_EXT_GD_HAVE_GD_AVIF_EXITCODE 1)
set(PHP_EXT_GD_HAVE_GD_JPG_EXITCODE 1)
set(PHP_EXT_GD_HAVE_GD_PNG_EXITCODE 1)
set(PHP_EXT_GD_HAVE_GD_WEBP_EXITCODE 1)
set(PHP_EXT_GD_HAVE_GD_XPM_EXITCODE 1)

################################################################################
# ext/iconv
################################################################################

# Set the exit code of the iconv //IGNORE check.
set(PHP_EXT_ICONV_HAS_BROKEN_IGNORE_EXITCODE 0)

# Set the exit code of the iconv errno check.
set(PHP_EXT_ICONV_HAS_ERRNO_EXITCODE 0)

################################################################################
# ext/opcache
################################################################################

# Set the exit code of SysV IPC shared memory check.
set(PHP_EXT_OPCACHE_HAVE_SHM_IPC_EXITCODE 0)

# Set the exit code of the mmap() using MAP_ANON shared memory check.
set(PHP_EXT_OPCACHE_HAVE_SHM_MMAP_ANON_EXITCODE 0)

# Set the exit code of the shm_open() shared memory check.
set(PHP_EXT_OPCACHE_HAVE_SHM_MMAP_POSIX_EXITCODE 0)

################################################################################
# ext/pcntl
################################################################################

# Set the exit code of the sched_getcpu() check.
set(PHP_EXT_PCNTL_HAVE_SCHED_GETCPU_EXITCODE 0)

################################################################################
# ext/pcre
################################################################################

# Set the exit code of the check when using an external PCRE library whether JIT
# support is available for the target architecture.
set(PHP_EXT_PCRE_HAS_JIT_EXITCODE 0)

################################################################################
# ext/session
################################################################################

# Set the exit codes for the pread()/pwrite() checks.
set(PHP_EXT_SESSION_HAVE_PREAD_EXITCODE 0)
set(PHP_EXT_SESSION_HAVE_PWRITE_EXITCODE 0)

################################################################################
# ext/standard
################################################################################

# Set the exit codes for the algos checks when using external crypt library
# (PHP_EXT_STANDARD_CRYPT_EXTERNAL).
set(PHP_HAS_CRYPT_BLOWFISH_EXITCODE 0)
set(PHP_HAS_CRYPT_EXT_DES_EXITCODE 0)
set(PHP_HAS_CRYPT_MD5_EXITCODE 0)
set(PHP_HAS_CRYPT_SHA256_EXITCODE 0)
set(PHP_HAS_CRYPT_SHA512_EXITCODE 0)
