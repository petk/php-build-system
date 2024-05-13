include(FeatureSummary)

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
  if(PHP_LAYOUT STREQUAL "GNU")
    set(_php_pear_dir "\${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATADIR}/pear")
  else()
    set(_php_pear_dir "\${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/php")
  endif()
else()
  set(_php_pear_dir "${PHP_PEAR_DIR}")
endif()

# Defined for build-defs.h.
# TODO: INSTALL_PREFIX here cannot be evaluated during the install phase.
set(EXPANDED_PEAR_INSTALLDIR "${_php_pear_dir}" CACHE INTERNAL "PEAR dir")

# TODO: Recheck if _php_pear_dir needs to be manually created here.
install(CODE "
  set(_php_pear_installer_url \"https://pear.php.net/install-pear-nozlib.phar\")

  # The generator expression $<INSTALL_PREFIX> inside CODE argument is evaluated
  # in CMake 3.27+.
  if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.27)
    set(prefix $<INSTALL_PREFIX>)
  else()
    set(prefix \${CMAKE_INSTALL_PREFIX})
  endif()

  message(STATUS \"Installing PEAR environment: ${_php_pear_dir}\")

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
      \${_php_pear_installer_url}
      \"${CMAKE_CURRENT_BINARY_DIR}/install-pear-nozlib.phar\"
      SHOW_PROGRESS
      STATUS _php_pear_download
    )

    if(NOT _php_pear_download)
      # Download using fetch.php.
      execute_process(
        COMMAND ${PHP_BINARY_DIR}/sapi/cli/php
            -n
            ${CMAKE_CURRENT_BINARY_DIR}/fetch.php
              \"\${_php_pear_installer_url}\"
              ${CMAKE_CURRENT_BINARY_DIR}/install-pear-nozlib.phar
      )
    endif()
  endif()

  if(EXISTS ${CMAKE_CURRENT_BINARY_DIR}/install-pear-nozlib.phar)
    # PEAR reads the INSTALL_ROOT environment variable to install pear.conf.
    # TODO: Adjust this further.
    #set(ENV{INSTALL_ROOT} \"\${prefix}\")

    execute_process(
      COMMAND ${PHP_BINARY_DIR}/sapi/cli/php
        -n
        -dshort_open_tag=0
        -dopen_basedir=
        -derror_reporting=1803
        -dmemory_limit=-1
        -ddetect_unicode=0
        ${CMAKE_CURRENT_BINARY_DIR}/install-pear-nozlib.phar
          --dir \"${_php_pear_dir}\"
          --bin \"\${prefix}/${CMAKE_INSTALL_BINDIR}\"
          --config \"\${prefix}/${CMAKE_INSTALL_SYSCONFDIR}\"
          --metadata \"\${prefix}/${CMAKE_INSTALL_DATADIR}\"
          -dp a${PHP_PROGRAM_PREFIX}
          -ds a$(PHP_PROGRAM_SUFFIX)
    )
  else()
    message(
      WARNING
      \"The installation process is not complete. The following resources \"
      \"were not installed:\\n\"
      \"  PEAR: PHP Extension and Application Repository\\n\"
      \"To install these components, download \${_php_pear_installer_url} to \"
      \"to php-src/pear/ and repeat the 'cmake --install' command.\"
    )
  endif()
")
