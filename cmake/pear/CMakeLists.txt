#[=============================================================================[
# PEAR

Configure PEAR as part of the PHP installation.

> [!WARNING]
> PEAR installation as part of PHP is deprecated as of PHP 7.4 and will be
> removed in future PHP versions. PEAR can also be installed manually from the
> pear.php.net website.

## PHP_PEAR

:orange_circle: *Deprecated as of PHP 7.4.*

* Default: `OFF`
* Values: `ON|OFF`

Install PEAR, PHP Extension and Application Repository package manager.

## PHP_PEAR_DIR

:orange_circle: *Deprecated as of PHP 7.4.*

* Default: `DATADIR/pear`

The path where PEAR will be installed to. `CMAKE_INSTALL_PREFIX` is
automatically prepended when given as a relative path.

## PHP_PEAR_TEMP_DIR

:orange_circle: *Deprecated as of PHP 7.4.*

* Default: `tmp/pear` on \*nix and `temp/pear` on Windows

The PEAR temporary directory where PEAR writes temporary files, such as cache,
downloaded packages artifacts and similar. Pass it as a relative path inside the
top level system directory, which will be automatically prepended. If given as
an absolute path, top level directory is not prepended. Relative path is added
to the top root system directory (`/` on \*nix, or `C:/` on Windows).

For example, default PEAR temporary directory after the top level system
directory is prepended becomes `/tmp/pear` on \*nix and `C:/temp/pear` on
Windows.
#]=============================================================================]

include(FeatureSummary)
include(PHP/Set)

option(
  PHP_PEAR
  "Install PEAR, PHP Extension and Application Repository package manager"
)

add_feature_info(
  "PEAR"
  PHP_PEAR
  "PHP Extension and Application Repository"
)

php_set(
  PHP_PEAR_DIR
  TYPE PATH
  IF PHP_PEAR
  VALUE "${CMAKE_INSTALL_DATADIR}/pear"
  DOC "The PEAR installation directory"
)
mark_as_advanced(PHP_PEAR_DIR)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(tmp_dir "temp/pear")
else()
  set(tmp_dir "tmp/pear")
endif()
php_set(
  PHP_PEAR_TEMP_DIR
  TYPE PATH
  IF PHP_PEAR
  VALUE "${tmp_dir}"
  DOC "The PEAR temporary directory. Default: ${tmp_dir}"
)
mark_as_advanced(PHP_PEAR_TEMP_DIR)

message(CHECK_START "Checking whether to install PEAR")
if(NOT PHP_PEAR)
  message(CHECK_FAIL "no")
  return()
endif()
message(CHECK_PASS "yes")

message(
  DEPRECATION
  "The 'PHP_PEAR' option is deprecated as of PHP 7.4 and will be removed in "
  "future PHP versions. PEAR can also be installed manually from the "
  "pear.php.net website."
)

# Check PEAR dependencies.
block()
  if(NOT TARGET PHP::sapi::cli)
    message(
      FATAL_ERROR
      "The 'PHP_PEAR' option requires PHP CLI SAPI. Please, set 'PHP_SAPI_CLI' "
      "to 'ON'."
    )
  endif()

  foreach(
    extension
      openssl # For pecl command to download packages over https
      xml     # For installer, pear and pecl commands to work
  )
    string(TOUPPER ${extension} extension_upper)
    if(NOT PHP_EXT_${extension_upper})
      message(
        FATAL_ERROR
        "The 'PHP_PEAR' option requires PHP extension ${extension}. Please, "
        "set 'PHP_EXT_${extension_upper}' to 'ON'."
      )
    endif()
  endforeach()
endblock()

set(PHP_EXECUTABLE "")
if(NOT CMAKE_CROSSCOMPILING)
  set(PHP_EXECUTABLE "$<TARGET_FILE:PHP::sapi::cli>")
elseif(CMAKE_CROSSCOMPILING AND CMAKE_CROSSCOMPILING_EMULATOR)
  set(PHP_EXECUTABLE "${CMAKE_CROSSCOMPILING_EMULATOR};$<TARGET_FILE:PHP::sapi::cli>")
endif()

string(CONFIGURE [[
  set(php_pear_install_dir "$<PATH:ABSOLUTE_PATH,NORMALIZE,@PHP_PEAR_DIR@,${CMAKE_INSTALL_PREFIX}>")
  set(php_pear_install_bin_dir "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_BINDIR@,${CMAKE_INSTALL_PREFIX}>")
  set(php_pear_current_source_dir "@CMAKE_CURRENT_SOURCE_DIR@")
  set(php_pear_current_binary_dir "@CMAKE_CURRENT_BINARY_DIR@")
  set(php_pear_php_executable "@PHP_EXECUTABLE@")
  set(php_pear_extension_dir "$<PATH:ABSOLUTE_PATH,NORMALIZE,@PHP_EXTENSION_DIR@,${CMAKE_INSTALL_PREFIX}>")
  set(PHP_EXT_OPENSSL_SHARED "@PHP_EXT_OPENSSL_SHARED@")
  set(PHP_EXT_XML_SHARED "@PHP_EXT_XML_SHARED@")
  set(PHP_BINARY_DIR @PHP_BINARY_DIR@)
  set(CMAKE_SYSTEM_NAME "@CMAKE_SYSTEM_NAME@")
  set(PHP_PEAR_TEMP_DIR "@PHP_PEAR_TEMP_DIR@")
  set(php_pear_installed_php_bin "${php_pear_install_bin_dir}/$<TARGET_FILE_NAME:PHP::sapi::cli>")
  set(php_pear_php_program_prefix "@PHP_PROGRAM_PREFIX@")
  set(php_pear_php_program_suffix "@PHP_PROGRAM_SUFFIX@")
  set(php_pear_install_sysconf_dir "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_SYSCONFDIR@,${CMAKE_INSTALL_PREFIX}>")
]] code @ONLY)
install(CODE "${code}")
install(SCRIPT cmake/InstallPear.cmake)
