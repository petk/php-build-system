#[=============================================================================[
The PEAR installation script.

It downloads the PEAR installer and installs it using the built PHP CLI
executable to system directory structure. Some variables need to be set before
running it via the install(CODE) as done in the PEAR's CMakeLists.txt.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

set(php_pear_installer_url "https://pear.php.net/install-pear-nozlib.phar")

# Helper to normalize path with DESTDIR on Windows and *nix systems.
#
# php_pear_path_with_destdir(
#   <path-to-normalize-for-install>
#   <result-variable-name>
# )
function(php_pear_path_with_destdir)
  cmake_parse_arguments(
    PARSE_ARGV
    2
    parsed # prefix
    ""     # options
    ""     # one-value keywords
    ""     # multi-value keywords
  )

  if(
    CMAKE_SYSTEM_NAME STREQUAL "Windows"
    AND DEFINED ENV{DESTDIR}
    AND IS_ABSOLUTE "${ARGV0}"
  )
    string(REGEX REPLACE "^.:" "" path "${ARGV0}")
    set(path "$ENV{DESTDIR}/${path}")
  elseif(DEFINED ENV{DESTDIR} AND IS_ABSOLUTE "${ARGV0}")
    set(path "$ENV{DESTDIR}/${ARGV0}")
  else()
    set(path "${ARGV0}")
  endif()

  cmake_path(SET path NORMALIZE "${path}")
  set(${ARGV1} "${path}" PARENT_SCOPE)
endfunction()

# Add PHP command-line options for shared dependent extensions.
set(php_pear_options -d extension_dir=${PHP_BINARY_DIR}/modules/$<CONFIG>)

if(PHP_EXT_OPENSSL_SHARED)
  list(APPEND php_pear_options -d extension=openssl)
endif()

if(PHP_EXT_XML_SHARED)
  list(APPEND php_pear_options -d extension=xml)
endif()

php_pear_path_with_destdir(${php_pear_install_dir} php_pear_install_stage_dir)
message(STATUS "Installing PEAR to ${php_pear_install_stage_dir}")

# If PEAR installer is packaged in the PHP release archive.
if(
  EXISTS ${php_pear_current_source_dir}/install-pear-nozlib.phar
  AND NOT "${php_pear_current_source_dir}" STREQUAL "${php_pear_current_binary_dir}"
)
  file(
    COPY_FILE
    "${php_pear_current_source_dir}/install-pear-nozlib.phar"
    "${php_pear_current_binary_dir}/install-pear-nozlib.phar"
  )
endif()

# Download PEAR installer.
if(NOT EXISTS ${php_pear_current_binary_dir}/install-pear-nozlib.phar)
  file(
    DOWNLOAD
    ${php_pear_installer_url}
    ${php_pear_current_binary_dir}/install-pear-nozlib.phar
    SHOW_PROGRESS
    STATUS download_status
  )

  if(php_pear_php_executable AND NOT download_status)
    # Download using fetch.php.
    execute_process(
      COMMAND
        ${php_pear_php_executable}
        -n
        ${php_pear_options}
        ${php_pear_current_source_dir}/fetch.php
        ${php_pear_installer_url}
        ${php_pear_current_binary_dir}/install-pear-nozlib.phar
    )
  endif()
endif()

if(NOT php_pear_php_executable)
  message(
    WARNING
    "The PEAR installation is not complete.\n"
    "To install PEAR, download ${php_pear_installer_url}\n"
    "and install it manually."
  )
  return()
endif()

if(NOT EXISTS ${php_pear_current_binary_dir}/install-pear-nozlib.phar)
  message(
    WARNING
    "The PEAR installation is not complete.\n"
    "To install PEAR, download ${php_pear_installer_url}\n"
    "to php-src/pear/ and repeat the 'cmake --install' command."
  )
  return()
endif()

# PEAR reads the staging INSTALL_ROOT environment variable if set. However,
# there is a bug where .channels, .registry and temporary dot files are
# duplicated outside of the INSTALL_ROOT into the install prefix. No known
# workaround. See: https://pear.php.net/bugs/bug.php?id=20383
if(DEFINED ENV{DESTDIR})
  set(ENV{INSTALL_ROOT} "$ENV{DESTDIR}")
endif()

# The PEAR sysconf directory by default matches the PHP_SYSCONFDIR and it
# doesn't seem that any configuration option installs the pear.conf into the
# manually specified directory. But the sysconf can be also bypassed with
# the environment variable for the installation time.
set(ENV{PHP_PEAR_SYSCONF_DIR} ${php_pear_install_sysconf_dir})

# Set the PHP extensions directory.
set(ENV{PHP_PEAR_EXTENSION_DIR} "${php_pear_extension_dir}")

if(IS_ABSOLUTE ${PHP_PEAR_TEMP_DIR})
  cmake_path(SET php_pear_temp_dir NORMALIZE "${PHP_PEAR_TEMP_DIR}")
else()
  if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    cmake_path(SET php_pear_temp_dir NORMALIZE "c:/${PHP_PEAR_TEMP_DIR}")
  else()
    cmake_path(SET php_pear_temp_dir NORMALIZE "/${PHP_PEAR_TEMP_DIR}")
  endif()
endif()

# Set PEAR temporary directory for the DESTDIR and system top level directory.
php_pear_path_with_destdir(${php_pear_temp_dir} php_pear_stage_temp_dir)

file(
  MAKE_DIRECTORY
    ${php_pear_install_stage_dir}
    ${php_pear_stage_temp_dir}/cache
    ${php_pear_stage_temp_dir}/download
    ${php_pear_stage_temp_dir}/temp
)

# Run the PEAR installer.
execute_process(
  COMMAND
    ${php_pear_php_executable}
    -n
    -dshort_open_tag=0
    -dopen_basedir=
    -derror_reporting=1803
    -dmemory_limit=-1
    ${php_pear_options}
    ${php_pear_current_binary_dir}/install-pear-nozlib.phar
      --dir "${php_pear_install_dir}"
      --bin "${php_pear_install_bin_dir}"
      --metadata "${php_pear_install_dir}"
      --data "${php_pear_install_dir}"
      --temp "${php_pear_stage_temp_dir}"
      --cache "${php_pear_temp_dir}/cache"
      --download "${php_pear_temp_dir}/download"
      --php ${php_pear_installed_php_bin}
      -dp a${php_pear_php_program_prefix}
      -ds a${php_pear_php_program_suffix}
  OUTPUT_VARIABLE output
  ERROR_VARIABLE output
  RESULT_VARIABLE result
)

if(output)
  message(STATUS "${output}")
endif()

if(NOT result EQUAL 0)
  message(WARNING "Something went wrong with PEAR installation.")
  return()
endif()

# When installing with DESTDIR, patch the pear.conf file as it contains the
# temporary path with DESTDIR path.
if(NOT DEFINED ENV{DESTDIR})
  return()
endif()

php_pear_path_with_destdir($ENV{PHP_PEAR_SYSCONF_DIR}/pear.conf pear_conf)

if(NOT EXISTS "${pear_conf}")
  return()
endif()

message(STATUS "Patching ${pear_conf}")

file(READ "${pear_conf}" content)
string(LENGTH "${php_pear_temp_dir}/temp" length)
string(
  REGEX REPLACE
  "s:8:\"temp_dir\";s:[0-9]+:\"${php_pear_stage_temp_dir}\""
  "s:8:\"temp_dir\";s:${length}:\"${php_pear_temp_dir}/temp\""
  content
  "${content}"
)
file(WRITE ${pear_conf} "${content}")
