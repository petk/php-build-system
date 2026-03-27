#[=============================================================================[
This is an internal module and is intended for usage only within the php-src.
It checks whether the PHP thread safety, a.k.a. ZTS (Zend thread safety) should
be enabled.

Load this module in a CMake project with:

  include(PHP/Core/ThreadSafety)

Result variables:

* ZTS - Whether PHP thread safety is enabled.

Including this module will also add some compile definitions to achieve POSIX
threads conformance. These definitions are today obsolete on all modern systems.
POSIX threading can be achieved by simply using the compiler option '-pthread',
which is sufficient (it automatically defines the _REENTRANT and on some systems
also _THREAD_SAFE compile definition for backward compatibility). For example,
see the output of:
  gcc -dumpspecs | grep _REENTRANT
or:
  clang -pthread -dM -E - < /dev/null | grep _REENTRANT

System headers in most cases don't utilize these definitions anymore. However,
php-src code at the time of writing, still uses the _REENTRANT and _THREAD_SAFE
macros on few places. Therefore they are left here to not change the PHP's C
code behavior yet.

* _REENTRANT definition has been removed on Solaris 11.4:
  On Solaris <= 11.3 and illumos-based systems the _REENTRANT compile definition
  is needed when building thread safe apps. However, the FindThreads
  module used in this build system prefers to use the '-pthread' flag, which
  automatically adds '-D_REENTRANT' on all checked Solaris versions and
  supported compilers. See:
  https://blogs.oracle.com/solaris/post/goodbye-and-good-riddance-to-mt-and-d_reentrant

* On FreeBSD specifically, _REENTRANT and _THREAD_SAFE aren't used in system
  headers anymore for a very long time now:
  https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=36167
  Compilers on FreeBSD don't define these two definitions anymore when
  '-pthread' compiler option is used.

* On AIX, POSIX threading is also achieved by simply using the '-pthread'
  compile option, which automatically defines the _THREAD_SAFE for backwards
  compatibility.

* Similar can be concluded for other configured systems: Linux, SCO_SV, UNIX_SV,
  and UnixWare.
#]=============================================================================]

include_guard(GLOBAL)

include(FeatureSummary)

message(CHECK_START "Checking whether to enable thread safety (ZTS)")

add_feature_info(
  "Thread safety (ZTS)"
  PHP_THREAD_SAFETY
  "safe execution in multi-threaded environments"
)

if(NOT PHP_THREAD_SAFETY)
  message(CHECK_FAIL "no")
  return()
endif()

set(THREADS_PREFER_PTHREAD_FLAG TRUE)
find_package(Threads)
set_package_properties(
  Threads
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable PHP thread safety."
)

if(Threads_FOUND)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "failed")
endif()

target_link_libraries(php_config INTERFACE Threads::Threads)

set(ZTS TRUE)

# Add ZTS compile definition. Some PHP headers might not have php_config.h
# directly available. For example, some Zend headers.
target_compile_definitions(php_config INTERFACE ZTS)

# Add deprecated and obsolete compile definitions for POSIX threads conformance.
target_compile_definitions(
  php_config
  INTERFACE
    $<$<AND:$<PLATFORM_ID:FreeBSD>,$<COMPILE_LANGUAGE:ASM,C,CXX>>:_REENTRANT;_THREAD_SAFE>
)
