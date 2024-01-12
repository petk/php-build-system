#[=============================================================================[
Windows platform specific configuration.
]=============================================================================]#

include_guard(GLOBAL)

# Common compilation definitions.
target_compile_definitions(
  php_configuration
  INTERFACE
    PHP_WIN32  # For PHP code
    _WIN32     # Defined by all compilers
    WIN32      # Defined by GCC and Clang compilers
    ZEND_WIN32 # For Zend engine
)

# To speed up the Windows build experience with Visual Studio generators, these
# are always known on Windows systems.
# TODO: Update and fix this better.
set(HAVE_SYSLOG_H 1)