#[=============================================================================[
# PHP/ThreadSafety

Check for thread safety, a.k.a. ZTS (Zend thread safety) build.

## Result variables

* `ZTS`

  Whether PHP thread safety is enabled.

## Custom CMake properties

* `PHP_THREAD_SAFETY`

  When thread safety is enabled (either by the configuration variable
  `PHP_THREAD_SAFETY` or automatically by the `apache2handler` PHP SAPI module),
  also a custom target property `PHP_THREAD_SAFETY` is added to the
  `PHP::configuration` target, which can be then used in generator expressions
  during the generation phase to determine thread safety enabled from the
  configuration phase. For example, the `PHP_EXTENSION_DIR` configuration
  variable needs to be set depending on the thread safety.
#]=============================================================================]

include_guard(GLOBAL)

include(FeatureSummary)

define_property(
  TARGET
  PROPERTY PHP_THREAD_SAFETY
  BRIEF_DOCS "Whether the PHP has thread safety enabled"
)

function(_php_thread_safety)
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
  set(THREADS_ENABLE_SYSTEM_EXTENSIONS TRUE)
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

  target_link_libraries(php_configuration INTERFACE Threads::Threads)

  set(ZTS TRUE PARENT_SCOPE)

  # Add ZTS compile definition. Some PHP headers might not have php_config.h
  # directly available. For example, some Zend headers.
  target_compile_definitions(php_configuration INTERFACE ZTS)

  # Set custom target property on the PHP configuration target.
  set_target_properties(php_configuration PROPERTIES PHP_THREAD_SAFETY ON)

  # Add compile definitions for POSIX threads conformance.
  # TODO: Recheck these definitions since many of them are deprecated or
  # obsolete in favor of the compiler automatic definitions when using threading
  # flag on such system.
  target_compile_definitions(
    php_configuration
    INTERFACE
      $<$<AND:$<PLATFORM_ID:SunOS>,$<COMPILE_LANGUAGE:ASM,C,CXX>>:_POSIX_PTHREAD_SEMANTICS;_REENTRANT>
      $<$<AND:$<PLATFORM_ID:FreeBSD>,$<COMPILE_LANGUAGE:ASM,C,CXX>>:_REENTRANT;_THREAD_SAFE>
      $<$<AND:$<PLATFORM_ID:AIX>,$<COMPILE_LANGUAGE:ASM,C,CXX>>:_THREAD_SAFE>
      $<$<AND:$<PLATFORM_ID:Linux,HP-UX,SCO_SV,UNIX_SV,UnixWare>,$<COMPILE_LANGUAGE:ASM,C,CXX>>:_REENTRANT>
  )
endfunction()

# Run at the end of the configuration so that apache2handler SAPI can
# automatically enable thread safety by setting PHP_THREAD_SAFETY to 'ON'
# during the configuration. Elsewhere, thread safety should be opt-in and
# automatic enabling in the configuration phase shouldn't be encouraged.
cmake_language(
  DEFER
  DIRECTORY ${PHP_SOURCE_DIR}
  ID 1 # Run before other calls so ZTS variable is added in main/php_config.h.
  CALL _php_thread_safety
)
