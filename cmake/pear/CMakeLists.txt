include(FeatureSummary)
include(PHP/Install)

option(PHP_PEAR "Whether to install PEAR" OFF)

add_feature_info(
  "PEAR"
  PHP_PEAR
  "PHP Extension and Application Repository package manager"
)

if(PHP_PEAR)
  set(
    PHP_PEAR_DIR ""
    CACHE FILEPATH
    "Install PEAR in DIR (PREFIX/lib/php)"
  )
  # Change from INTERNAL type to show variable on consecutive configuration run.
  set_property(CACHE PHP_PEAR_DIR PROPERTY TYPE FILEPATH)
elseif(DEFINED PHP_PEAR_DIR)
  # Hide variable.
  set_property(CACHE PHP_PEAR_DIR PROPERTY TYPE INTERNAL)
endif()

message(CHECK_START "Checking for PEAR")

if(NOT PHP_PEAR)
  message(CHECK_FAIL "no")
  return()
else()
  message(CHECK_PASS "yes")
endif()

message(DEPRECATION "The PHP_PEAR option is deprecated.")

if(NOT SAPI_CLI)
  message(FATAL_ERROR "The PHP_PEAR option requires CLI SAPI. Set SAPI_CLI='ON'.")
endif()

# Check PEAR dependencies.
if(NOT EXT_XML)
  message(
    FATAL_ERROR
    "PEAR requires the xml extension to be enabled. Set EXT_XML to 'ON'.")
endif()

if(NOT PHP_PEAR_DIR)
  set(_php_pear_dir "\${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATADIR}/pear")
else()
  set(_php_pear_dir "${PHP_PEAR_DIR}")
endif()

# Defined for build-defs.h.
# TODO: INSTALL_PREFIX here cannot be evaluated during the install phase.
set(EXPANDED_PEAR_INSTALLDIR "${_php_pear_dir}" CACHE INTERNAL "PEAR dir")

if(NOT CMAKE_CROSSCOMPILING)
  set(PHP_EXECUTABLE "$<TARGET_FILE:php_cli>")
elseif(CMAKE_CROSSCOMPILING AND CMAKE_CROSSCOMPILING_EMULATOR)
  set(PHP_EXECUTABLE "${CMAKE_CROSSCOMPILING_EMULATOR};$<TARGET_FILE:php_cli>")
endif()

set(_phpPearInstallerUrl "https://pear.php.net/install-pear-nozlib.phar")

php_install(CODE "
  message(STATUS \"Installing PEAR: \$ENV{DESTDIR}${_php_pear_dir}\")

  if(EXISTS \"${CMAKE_CURRENT_SOURCE_DIR}/install-pear-nozlib.phar\"
    AND NOT \"${CMAKE_CURRENT_SOURCE_DIR}\" STREQUAL \"${CMAKE_CURRENT_BINARY_DIR}\"
  )
    file(
      COPY_FILE
      \"${CMAKE_CURRENT_SOURCE_DIR}/install-pear-nozlib.phar\"
      \"${CMAKE_CURRENT_BINARY_DIR}/install-pear-nozlib.phar\"
    )
  endif()

  if(NOT EXISTS \"${CMAKE_CURRENT_BINARY_DIR}/install-pear-nozlib.phar\")
    file(
      DOWNLOAD
      ${_phpPearInstallerUrl}
      \"${CMAKE_CURRENT_BINARY_DIR}/install-pear-nozlib.phar\"
      SHOW_PROGRESS
      STATUS downloadStatus
    )

    if(NOT downloadStatus)
      # Download using fetch.php.
      execute_process(
        COMMAND ${PHP_EXECUTABLE}
          -n
          ${CMAKE_CURRENT_BINARY_DIR}/fetch.php
            ${_phpPearInstallerUrl}
            ${CMAKE_CURRENT_BINARY_DIR}/install-pear-nozlib.phar
        OUTPUT_VARIABLE output
        ERROR_VARIABLE output
      )
      if(output)
        message(STATUS \"\${output}\")
      endif()
    endif()
  endif()

  if(EXISTS ${CMAKE_CURRENT_BINARY_DIR}/install-pear-nozlib.phar)
    # PEAR reads the staging INSTALL_ROOT environment variable if set. However,
    # there is a bug where .channels, .registry and temporary dot files are
    # duplicated outside of the INSTALL_ROOT into the install prefix. No known
    # workaround. See: https://pear.php.net/bugs/bug.php?id=20383
    if(DEFINED ENV{DESTDIR})
      set(ENV{INSTALL_ROOT} \"\$ENV{DESTDIR}\")
    endif()

    # The PEAR's --config option doesn't seem to install the pear.conf into the
    # specified directory, but the sysconf can be also bypassed with the
    # environment variable.
    set(ENV{PHP_PEAR_SYSCONF_DIR} \${CMAKE_INSTALL_FULL_SYSCONFDIR})

    file(
      MAKE_DIRECTORY
      \$ENV{DESTDIR}${_php_pear_dir}
      ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/pear
    )

    execute_process(
      COMMAND ${PHP_EXECUTABLE}
        -n
        -dshort_open_tag=0
        -dopen_basedir=
        -derror_reporting=1803
        -dmemory_limit=-1
        -ddetect_unicode=0
        ${CMAKE_CURRENT_BINARY_DIR}/install-pear-nozlib.phar
          --dir \"${_php_pear_dir}\"
          --bin \"\${CMAKE_INSTALL_FULL_BINDIR}\"
          --metadata \"${_php_pear_dir}\"
          --data \"${_php_pear_dir}\"
          --temp \"${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/pear\"
          #--php \${CMAKE_INSTALL_FULL_BINDIR}/$<TARGET_FILE_NAME:php_cli>
          -dp a${PHP_PROGRAM_PREFIX}
          -ds a${PHP_PROGRAM_SUFFIX}
      OUTPUT_VARIABLE output
      ERROR_VARIABLE output
    )
    if(output)
      message(STATUS \"\${output}\")
    endif()
  else()
    message(
      WARNING
      \"The installation process is not complete. The following resources \"
      \"were not installed:\\n\"
      \"  PEAR: PHP Extension and Application Repository\\n\"
      \"To install these components, download ${_phpPearInstallerUrl} to \"
      \"to php-src/pear/ and repeat the 'cmake --install' command.\"
    )
  endif()
")
