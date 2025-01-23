#[=============================================================================[
The PHP FPM SAPI installation script.
#]=============================================================================]

################################################################################
# FPM target.
################################################################################

install(TARGETS php_sapi_fpm RUNTIME DESTINATION ${CMAKE_INSTALL_SBINDIR})

################################################################################
# Create var/log, [var/]run, and etc/php-fpm.d directories on installation.
################################################################################

install(
  CODE
  [[
    file(
      INSTALL
      DESTINATION "${CMAKE_INSTALL_FULL_LOCALSTATEDIR}/log"
      TYPE DIRECTORY
      FILES ""
    )
    file(
      INSTALL
      DESTINATION "${CMAKE_INSTALL_FULL_RUNSTATEDIR}"
      TYPE DIRECTORY
      FILES ""
    )
    file(
      INSTALL
      DESTINATION "${CMAKE_INSTALL_FULL_SYSCONFDIR}/php-fpm.d"
      TYPE DIRECTORY
      FILES ""
    )
  ]]
)

################################################################################
# Man documentation.
################################################################################

# Replace the hardcoded runstatedir with a template placeholder.
file(READ "${CMAKE_CURRENT_SOURCE_DIR}/php-fpm.8.in" content)
string(
  REPLACE
  [[@php_fpm_localstatedir@/run/php-fpm.pid]]
  [[@php_fpm_runstatedir@/php-fpm.pid]]
  content
  "${content}"
)
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/PHP/php-fpm.8.in" "${content}")

string(CONFIGURE [[
  block()
    set(php_fpm_prefix "${CMAKE_INSTALL_PREFIX}")
    set(php_fpm_localstatedir "${CMAKE_INSTALL_FULL_LOCALSTATEDIR}")
    set(php_fpm_runstatedir "${CMAKE_INSTALL_FULL_RUNSTATEDIR}")
    set(php_fpm_sysconfdir "${CMAKE_INSTALL_FULL_SYSCONFDIR}")
    set(PHP_VERSION "@PHP_VERSION@")

    configure_file(
      "@CMAKE_CURRENT_BINARY_DIR@/CMakeFiles/PHP/php-fpm.8.in"
      "@CMAKE_CURRENT_BINARY_DIR@/php-fpm.8"
      @ONLY
    )

    file(
      INSTALL
      DESTINATION "${CMAKE_INSTALL_FULL_MANDIR}/man8"
      TYPE FILE
      RENAME "@PHP_PROGRAM_PREFIX@php-fpm@PHP_PROGRAM_SUFFIX@.8"
      FILES "@CMAKE_CURRENT_BINARY_DIR@/php-fpm.8"
    )
  endblock()
]] code @ONLY)
install(CODE "${code}")

################################################################################
# FPM configuration
################################################################################

# Install PHP FPM defconfig files without overwriting existing configuration.
string(CONFIGURE [[
  block()
    set(prefix "${CMAKE_INSTALL_PREFIX}")
    set(EXPANDED_LOCALSTATEDIR "${CMAKE_INSTALL_FULL_LOCALSTATEDIR}")
    set(php_fpm_sysconfdir "${CMAKE_INSTALL_FULL_SYSCONFDIR}")
    configure_file(
      "@CMAKE_CURRENT_SOURCE_DIR@/php-fpm.conf.in"
      "@CMAKE_CURRENT_BINARY_DIR@/php-fpm.conf"
      @ONLY
    )

    set(prefix "${CMAKE_INSTALL_PREFIX}")
    set(php_fpm_prefix "${CMAKE_INSTALL_PREFIX}")
    set(php_fpm_user "@PHP_SAPI_FPM_USER@")
    set(php_fpm_group "@PHP_SAPI_FPM_GROUP@")
    set(EXPANDED_DATADIR "${CMAKE_INSTALL_FULL_DATADIR}")
    configure_file(
      "@CMAKE_CURRENT_SOURCE_DIR@/www.conf.in"
      "@CMAKE_CURRENT_BINARY_DIR@/www.conf"
      @ONLY
    )

    if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_FULL_SYSCONFDIR}/php-fpm.conf")
      message(
        STATUS
        "Skipping PHP FPM configuration installation. The php-fpm.conf file "
        "already exists."
      )
    else()
      file(
        INSTALL
        DESTINATION "${CMAKE_INSTALL_FULL_SYSCONFDIR}"
        TYPE FILE
        RENAME "php-fpm.conf.default"
        FILES "@CMAKE_CURRENT_BINARY_DIR@/php-fpm.conf"
      )

      file(
        INSTALL
        DESTINATION "${CMAKE_INSTALL_FULL_SYSCONFDIR}/php-fpm.d"
        TYPE FILE
        RENAME "www.conf.default"
        FILES "@CMAKE_CURRENT_BINARY_DIR@/www.conf"
      )
    endif()
  endblock()
]] code @ONLY)
install(CODE "${code}")

################################################################################
# FPM info status HTML page.
################################################################################

configure_file(status.html.in status.html @ONLY)

install(
  FILES
    ${CMAKE_CURRENT_BINARY_DIR}/status.html
  DESTINATION ${CMAKE_INSTALL_DATADIR}/fpm
)

################################################################################
# FPM service files.
################################################################################

# Replace the hardcoded runstatedir with a template placeholder.
file(READ "${CMAKE_CURRENT_SOURCE_DIR}/init.d.php-fpm.in" content)
string(
  REPLACE
  [[php_fpm_PID=@localstatedir@/run/php-fpm.pid]]
  [[php_fpm_PID=@runstatedir@/php-fpm.pid]]
  content
  "${content}"
)
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/PHP/init.d.php-fpm.in" "${content}")

string(CONFIGURE [[
  block()
    set(prefix "${CMAKE_INSTALL_PREFIX}")
    set(exec_prefix "${CMAKE_INSTALL_PREFIX}")
    set(sbindir "${CMAKE_INSTALL_FULL_SBINDIR}")
    set(sysconfdir "${CMAKE_INSTALL_FULL_SYSCONFDIR}")
    set(runstatedir "${CMAKE_INSTALL_FULL_RUNSTATEDIR}")

    configure_file(
      "@CMAKE_CURRENT_BINARY_DIR@/CMakeFiles/PHP/init.d.php-fpm.in"
      "@CMAKE_CURRENT_BINARY_DIR@/init.d.php-fpm"
      @ONLY
    )

    # TODO: This is for now disabled as it depends on the target system and
    # system specific customizations might be needed.
    #file(
    #  INSTALL
    #  DESTINATION "${CMAKE_INSTALL_FULL_SYSCONFDIR}/init.d"
    #  TYPE FILE
    #  RENAME "@PHP_PROGRAM_PREFIX@php-fpm@PHP_PROGRAM_SUFFIX@"
    #  FILES "@CMAKE_CURRENT_BINARY_DIR@/init.d.php-fpm"
    #)
  endblock()
]] code @ONLY)
install(CODE "${code}")

# Replace the hardcoded runstatedir with a template placeholder.
file(READ "${CMAKE_CURRENT_SOURCE_DIR}/php-fpm.service.in" content)
string(
  REPLACE
  [[PIDFile=@EXPANDED_LOCALSTATEDIR@/run/php-fpm.pid]]
  [[PIDFile=@EXPANDED_RUNSTATEDIR@/php-fpm.pid]]
  content
  "${content}"
)
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/PHP/php-fpm.service.in" "${content}")

string(CONFIGURE [[
  block()
    set(php_fpm_systemd "@PHP_FPM_SYSTEMD@")
    set(EXPANDED_RUNSTATEDIR "${CMAKE_INSTALL_FULL_RUNSTATEDIR}")
    set(EXPANDED_SBINDIR "${CMAKE_INSTALL_FULL_SBINDIR}")
    set(EXPANDED_SYSCONFDIR "${CMAKE_INSTALL_FULL_SYSCONFDIR}")

    configure_file(
      "@CMAKE_CURRENT_BINARY_DIR@/CMakeFiles/PHP/php-fpm.service.in"
      "@CMAKE_CURRENT_BINARY_DIR@/php-fpm.service"
      @ONLY
    )

    # TODO: This is for now disabled as it depends on the target system and
    # system specific customizations might be needed.
    #file(
    #  INSTALL
    #  DESTINATION "${CMAKE_INSTALL_PREFIX}/TODO"
    #  TYPE FILE
    #  RENAME "@PHP_PROGRAM_PREFIX@php-fpm@PHP_PROGRAM_SUFFIX@.service"
    #  FILES "@CMAKE_CURRENT_BINARY_DIR@/php-fpm.service"
    #)
  endblock()
]] code @ONLY)
install(CODE "${code}")
