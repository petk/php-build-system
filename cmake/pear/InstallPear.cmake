#[=============================================================================[
The PEAR installation script.

It downloads the PEAR installer and installs it using the built PHP CLI
executable to system directory structure. Some variables need to be set before
running it via the install(CODE) as done in the PEAR's CMakeLists.txt.
#]=============================================================================]

set(phpPearInstallerUrl "https://pear.php.net/install-pear-nozlib.phar")

message(STATUS "Installing PEAR to $ENV{DESTDIR}${phpPearInstallDir}")

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

  if(IS_EXECUTABLE "${phpPearPhpExecutable}" AND NOT downloadStatus)
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

if(NOT IS_EXECUTABLE "${phpPearPhpExecutable}")
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

# Set temporary directory for the PEAR installation.
set(localPearTempDir ${phpPearCurrentBinaryDir}/CMakeFiles/pear)

# Set the PHP extensions directory.
set(ENV{PHP_PEAR_EXTENSION_DIR} "${phpExtensionDir}")

file(
  MAKE_DIRECTORY
    "$ENV{DESTDIR}${phpPearInstallDir}"
    ${localPearTempDir}
)

# Run the PEAR phar installer.
execute_process(
  COMMAND ${phpPearPhpExecutable}
  -n
  -dshort_open_tag=0
  -dopen_basedir=
  -derror_reporting=1803
  -dmemory_limit=-1
  -ddetect_unicode=0
  ${phpPearOptions}
  ${phpPearCurrentBinaryDir}/install-pear-nozlib.phar
    --dir "${phpPearInstallDir}"
    --bin "${phpPearInstallBinDir}"
    --metadata "${phpPearInstallDir}"
    --data "${phpPearInstallDir}"
    --temp "${localPearTempDir}"
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

# Patch the pear.conf file because it contains the temporary CMakeFiles path.
set(pearConf $ENV{DESTDIR}$ENV{PHP_PEAR_SYSCONF_DIR}/pear.conf)
if(NOT EXISTS "${pearConf}")
  return()
endif()

message(STATUS "Patching pear.conf")

file(READ "${pearConf}" content)
file(WRITE ${localPearTempDir}/pear.conf "${content}")
string(LENGTH "${phpPearTempDir}/temp" length)
string(
  REGEX REPLACE
  "s:[0-9]+:\"${localPearTempDir}"
  "s:${length}:\"${phpPearTempDir}/temp"
  content
  "${content}"
)
file(WRITE ${pearConf} "${content}")
