#[=============================================================================[
The PEAR installation script.

It downloads the PEAR installer and installs it using the built PHP CLI
executable to system directory structure. Some variables need to be set before
running it via the install(CODE) as done in the PEAR's CMakeLists.txt.
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.2)

set(phpPearInstallerUrl "https://pear.php.net/install-pear-nozlib.phar")

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

php_pear_path_with_destdir(${phpPearInstallDir} phpPearInstallStageDir)
message(STATUS "Installing PEAR to ${phpPearInstallStageDir}")

# If PEAR installer is packaged in the PHP release archive.
if(
  EXISTS ${phpPearCurrentSourceDir}/install-pear-nozlib.phar
  AND NOT "${phpPearCurrentSourceDir}" STREQUAL "${phpPearCurrentBinaryDir}"
)
  file(
    COPY_FILE
    "${phpPearCurrentSourceDir}/install-pear-nozlib.phar"
    "${phpPearCurrentBinaryDir}/install-pear-nozlib.phar"
  )
endif()

# Download PEAR installer.
if(NOT EXISTS ${phpPearCurrentBinaryDir}/install-pear-nozlib.phar)
  file(
    DOWNLOAD
    ${phpPearInstallerUrl}
    ${phpPearCurrentBinaryDir}/install-pear-nozlib.phar
    SHOW_PROGRESS
    STATUS downloadStatus
  )

  if(phpPearPhpExecutable AND NOT downloadStatus)
    # Download using fetch.php.
    execute_process(
      COMMAND ${phpPearPhpExecutable}
        -n
        ${phpPearCurrentSourceDir}/fetch.php
        ${phpPearInstallerUrl}
        ${phpPearCurrentBinaryDir}/install-pear-nozlib.phar
      OUTPUT_VARIABLE output
      ERROR_VARIABLE output
    )
    if(output)
      message(STATUS "${output}")
    endif()
  endif()
endif()

if(NOT phpPearPhpExecutable)
  message(
    WARNING
    "The PEAR installation is not complete.\n"
    "To install PEAR, download ${phpPearInstallerUrl}\n"
    "and install it manually."
  )
  return()
endif()

if(NOT EXISTS ${phpPearCurrentBinaryDir}/install-pear-nozlib.phar)
  message(
    WARNING
    "The PEAR installation is not complete.\n"
    "To install PEAR, download ${phpPearInstallerUrl}\n"
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
set(ENV{PHP_PEAR_SYSCONF_DIR} ${phpPearInstallSysconfDir})

# Set the PHP extensions directory.
set(ENV{PHP_PEAR_EXTENSION_DIR} "${phpExtensionDir}")

if(IS_ABSOLUTE ${PHP_PEAR_TEMP_DIR})
  cmake_path(SET phpPearTempDir NORMALIZE "${PHP_PEAR_TEMP_DIR}")
else()
  if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    cmake_path(SET phpPearTempDir NORMALIZE "c:/${PHP_PEAR_TEMP_DIR}")
  else()
    cmake_path(SET phpPearTempDir NORMALIZE "/${PHP_PEAR_TEMP_DIR}")
  endif()
endif()

# Set PEAR temporary directory for the DESTDIR and system top level directory.
php_pear_path_with_destdir(${phpPearTempDir} phpPearStageTempDir)

file(
  MAKE_DIRECTORY
    ${phpPearInstallStageDir}
    ${phpPearStageTempDir}/cache
    ${phpPearStageTempDir}/download
    ${phpPearStageTempDir}/temp
)

# Add PHP command-line options for shared dependent extensions.
set(phpPearOptions -d extension_dir=${PHP_BINARY_DIR}/modules/$<CONFIG>)

if(PHP_EXT_OPENSSL_SHARED)
  list(APPEND phpPearOptions -d extension=openssl)
endif()

if(PHP_EXT_XML_SHARED)
  list(APPEND phpPearOptions -d extension=xml)
endif()

# Run the PEAR installer.
execute_process(
  COMMAND ${phpPearPhpExecutable}
  -n
  -dshort_open_tag=0
  -dopen_basedir=
  -derror_reporting=1803
  -dmemory_limit=-1
  ${phpPearOptions}
  ${phpPearCurrentBinaryDir}/install-pear-nozlib.phar
    --dir "${phpPearInstallDir}"
    --bin "${phpPearInstallBinDir}"
    --metadata "${phpPearInstallDir}"
    --data "${phpPearInstallDir}"
    --temp "${phpPearStageTempDir}"
    --cache "${phpPearTempDir}/cache"
    --download "${phpPearTempDir}/download"
    --php ${phpPearInstalledPhpBin}
    -dp a${phpPearPhpProgramPrefix}
    -ds a${phpPearPhpProgramSuffix}
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

php_pear_path_with_destdir($ENV{PHP_PEAR_SYSCONF_DIR}/pear.conf pearConf)

if(NOT EXISTS "${pearConf}")
  return()
endif()

message(STATUS "Patching ${pearConf}")

file(READ "${pearConf}" content)
string(LENGTH "${phpPearTempDir}/temp" length)
string(
  REGEX REPLACE
  "s:8:\"temp_dir\";s:[0-9]+:\"${phpPearStageTempDir}\""
  "s:8:\"temp_dir\";s:${length}:\"${phpPearTempDir}/temp\""
  content
  "${content}"
)
file(WRITE ${pearConf} "${content}")
