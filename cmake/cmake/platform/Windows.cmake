#[=============================================================================[
Windows platform specific configuration.
]=============================================================================]#

# Common compilation definitions.
target_compile_definitions(
  php_configuration
  INTERFACE $<$<PLATFORM_ID:Windows>:PHP_WIN32;ZEND_WIN32>
)

# To speed up the Windows build experience with Visual Studio generators, these
# are always known on Windows systems.
# TODO: Update and fix this better.
set(HAVE_SYSLOG_H 1)
