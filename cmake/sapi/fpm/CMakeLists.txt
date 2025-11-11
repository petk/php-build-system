#[=============================================================================[
# The fpm SAPI

Configure the `fpm` PHP SAPI.

> [!NOTE]
> PHP FPM is not available when the target system is Windows.

## PHP_SAPI_FPM

* Default: `OFF`
* Values: `ON|OFF`

Enable the FastCGI Process Manager (FPM) SAPI module.

## PHP_SAPI_FPM_USER

* Default: `nobody`

Set the user for running PHP FPM.

## PHP_SAPI_FPM_GROUP

* Default: `nobody`

Set the group for running PHP FPM. For a system user, this should usually be set
in a way to match the FPM username.

## PHP_SAPI_FPM_ACL

* Default: `OFF`
* Values: `ON|OFF`

Use POSIX Access Control Lists.

Where to find ACL installation on the system, can be customized with the
`ACL_ROOT` variable.

> [!NOTE]
> This option is not available when the target system is Darwin (macOS) as this
> system doesn't have ACL.

## PHP_SAPI_FPM_APPARMOR

* Default: `OFF`
* Values: `ON|OFF`

Enable the AppArmor confinement through libapparmor.

Where to find AppArmor installation on the system, can be customized with the
`APPARMOR_ROOT` variable.

> [!NOTE]
> This option is not available when the target system is Darwin (macOS) as this
> system doesn't have AppArmor.

## PHP_SAPI_FPM_SELINUX

* Default: `OFF`
* Values: `ON|OFF`

Enable the SELinux policy library support.

Where to find SELinux installation on the system, can be customized with the
`SELINUX_ROOT` variable.

> [!NOTE]
> This option is not available when the target system is Darwin (macOS) as this
> system doesn't have SELinux.

## PHP_SAPI_FPM_SYSTEMD

* Default: `OFF`
* Values: `ON|OFF`

Enable the systemd integration.

Where to find systemd installation on the system, can be customized with the
`SYSTEMD_ROOT` variable.

> [!NOTE]
> This option is not available when the target system is Darwin (macOS) as this
> system doesn't have systemd.
#]=============================================================================]

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

include(CheckIncludeFiles)
include(CheckSymbolExists)
include(CMakePushCheckState)
include(FeatureSummary)
include(PHP/SearchLibraries)
include(PHP/Set)

################################################################################
# FPM configuration.
################################################################################

option(PHP_SAPI_FPM "Enable the FPM SAPI module")
add_feature_info(
  "sapi/fpm"
  PHP_SAPI_FPM
  "FastCGI Process Manager"
)

php_set(
  PHP_SAPI_FPM_USER
  TYPE STRING
  IF PHP_SAPI_FPM
  VALUE "nobody"
  DOC "Set the user for running PHP FPM (default: nobody)"
)

php_set(
  PHP_SAPI_FPM_GROUP
  TYPE STRING
  IF PHP_SAPI_FPM
  VALUE "nobody"
  DOC
    "Set the group for running PHP FPM. For a system user, this should usually "
    "be set to match the FPM username (default: nobody)"
)

php_set(
  PHP_SAPI_FPM_ACL
  TYPE BOOL
  IF [[PHP_SAPI_FPM AND NOT CMAKE_SYSTEM_NAME STREQUAL "Darwin"]]
  VALUE OFF
  DOC "Use POSIX Access Control Lists"
)
add_feature_info(
  "sapi/fpm ACL"
  PHP_SAPI_FPM_ACL
  "POSIX Access Control Lists integration"
)

php_set(
  PHP_SAPI_FPM_APPARMOR
  TYPE BOOL
  IF [[PHP_SAPI_FPM AND NOT CMAKE_SYSTEM_NAME STREQUAL "Darwin"]]
  VALUE OFF
  DOC "Enable the AppArmor confinement through libapparmor"
)
add_feature_info(
  "sapi/fpm AppArmor"
  PHP_SAPI_FPM_APPARMOR
  "application confinement integration"
)

php_set(
  PHP_SAPI_FPM_SELINUX
  TYPE BOOL
  IF [[PHP_SAPI_FPM AND NOT CMAKE_SYSTEM_NAME STREQUAL "Darwin"]]
  VALUE OFF
  DOC "Enable the SELinux policy library support"
)
add_feature_info(
  "sapi/fpm SELinux"
  PHP_SAPI_FPM_SELINUX
  "security policy integration"
)

php_set(
  PHP_SAPI_FPM_SYSTEMD
  TYPE BOOL
  IF [[PHP_SAPI_FPM AND NOT CMAKE_SYSTEM_NAME STREQUAL "Darwin"]]
  VALUE OFF
  DOC "Enable the systemd integration"
)
add_feature_info(
  "sapi/fpm systemd"
  PHP_SAPI_FPM_SYSTEMD
  "system and service manager integration"
)

if(NOT PHP_SAPI_FPM)
  return()
endif()

################################################################################
# Add executable.
################################################################################

add_executable(php_sapi_fpm)
add_executable(PHP::sapi::fpm ALIAS php_sapi_fpm)

target_sources(
  php_sapi_fpm
  PRIVATE
    fpm/events/epoll.c
    fpm/events/kqueue.c
    fpm/events/poll.c
    fpm/events/port.c
    fpm/events/select.c
    fpm/fpm_children.c
    fpm/fpm_cleanup.c
    fpm/fpm_clock.c
    fpm/fpm_conf.c
    fpm/fpm_env.c
    fpm/fpm_events.c
    fpm/fpm_log.c
    fpm/fpm_main.c
    fpm/fpm_main.stub.php
    fpm/fpm_php_trace.c
    fpm/fpm_php.c
    fpm/fpm_process_ctl.c
    fpm/fpm_request.c
    fpm/fpm_scoreboard.c
    fpm/fpm_shm.c
    fpm/fpm_signals.c
    fpm/fpm_sockets.c
    fpm/fpm_status.c
    fpm/fpm_stdio.c
    fpm/fpm_unix.c
    fpm/fpm_worker_pool.c
    fpm/fpm.c
    fpm/zlog.c
)

target_include_directories(
  php_sapi_fpm
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/fpm
)

target_compile_definitions(php_sapi_fpm PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

target_link_libraries(
  php_sapi_fpm
  PRIVATE
    $<BUILD_INTERFACE:PHP::sapi>
)

set_target_properties(
  php_sapi_fpm
  PROPERTIES
    OUTPUT_NAME ${PHP_PROGRAM_PREFIX}php-fpm${PHP_PROGRAM_SUFFIX}
    PHP_SAPI_FASTCGI TRUE
)

################################################################################
# Configuration checks.
################################################################################

check_symbol_exists(clearenv stdlib.h PHP_SAPI_FPM_HAVE_CLEARENV)
set(HAVE_CLEARENV ${PHP_SAPI_FPM_HAVE_CLEARENV})

check_symbol_exists(port_create port.h PHP_SAPI_FPM_HAVE_PORT_CREATE)
set(HAVE_PORT_CREATE ${PHP_SAPI_FPM_HAVE_PORT_CREATE})

check_symbol_exists(setpflags priv.h PHP_SAPI_FPM_HAVE_SETPFLAGS)
set(HAVE_SETPFLAGS ${PHP_SAPI_FPM_HAVE_SETPFLAGS})

check_symbol_exists(setproctitle "unistd.h;stdlib.h" PHP_SAPI_HAVE_SETPROCTITLE)
set(HAVE_SETPROCTITLE ${PHP_SAPI_HAVE_SETPROCTITLE})

check_symbol_exists(setproctitle_fast unistd.h PHP_SAPI_FPM_HAVE_SETPROCTITLE_FAST)
set(HAVE_SETPROCTITLE_FAST ${PHP_SAPI_FPM_HAVE_SETPROCTITLE_FAST})

check_symbol_exists(times sys/times.h PHP_SAPI_FPM_HAVE_TIMES)
set(HAVE_TIMES ${PHP_SAPI_FPM_HAVE_TIMES})

include(cmake/CheckClockGetTime.cmake)
include(cmake/CheckCompilerAtomicBuiltins.cmake)
include(cmake/CheckEpoll.cmake)
include(cmake/CheckKqueue.cmake)
include(cmake/CheckListeningQueue.cmake)
include(cmake/CheckSelect.cmake)

# Check FPM trace implementation.
include(cmake/CheckTrace.cmake)
if(HAVE_PTRACE OR HAVE_MACH_VM_READ OR PROC_MEM_FILE)
  target_sources(php_sapi_fpm PRIVATE fpm/fpm_trace.c)
  if(HAVE_PTRACE)
    target_sources(php_sapi_fpm PRIVATE fpm/fpm_trace_ptrace.c)
  elseif(HAVE_MACH_VM_READ)
    target_sources(php_sapi_fpm PRIVATE fpm/fpm_trace_mach.c)
  elseif(PROC_MEM_FILE)
    target_sources(php_sapi_fpm PRIVATE fpm/fpm_trace_pread.c)
  endif()
endif()

################################################################################
# Configure FPM from configuration options.
################################################################################

if(PHP_SAPI_FPM_SYSTEMD)
  find_package(Systemd 209)
  set_package_properties(
    Systemd
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable systemd integration in FPM SAPI."
  )

  target_link_libraries(php_sapi_fpm PRIVATE Systemd::Systemd)

  if(TARGET Systemd::Systemd)
    set(HAVE_SYSTEMD TRUE)

    target_sources(php_sapi_fpm PRIVATE fpm/fpm_systemd.c)
  endif()

  set(PHP_FPM_SYSTEMD "notify")
else()
  set(PHP_FPM_SYSTEMD "simple")
endif()

if(PHP_SAPI_FPM_ACL)
  set(ACL_USE_USER_GROUP TRUE)
  find_package(ACL)
  set_package_properties(
    ACL
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable FPM SAPI ACL user/group permissions support."
  )

  target_link_libraries(php_sapi_fpm PRIVATE ACL::ACL)

  if(TARGET ACL::ACL)
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LIBRARIES ACL::ACL)
      check_include_files(sys/acl.h PHP_SAPI_FPM_HAVE_SYS_ACL_H)
      set(HAVE_SYS_ACL_H ${PHP_SAPI_FPM_HAVE_SYS_ACL_H})
    cmake_pop_check_state()

    set(HAVE_FPM_ACL TRUE)
  endif()
endif()

if(PHP_SAPI_FPM_APPARMOR)
  find_package(AppArmor 2.7.0) # 2.7.0 for aa_getcon().
  set_package_properties(
    AppArmor
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable AppArmor support in the FPM SAPI."
  )

  target_link_libraries(php_sapi_fpm PRIVATE AppArmor::AppArmor)

  if(TARGET AppArmor::AppArmor)
    set(HAVE_APPARMOR TRUE)
  endif()
endif()

if(PHP_SAPI_FPM_SELINUX)
  find_package(SELinux 2.0.89) # ~2.0.89 version that contains pkg-config.
  set_package_properties(
    SELinux
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable SELinux support in the FPM SAPI."
  )

  target_link_libraries(php_sapi_fpm PRIVATE SELinux::SELinux)

  if(TARGET SELinux::SELinux)
    set(HAVE_SELINUX TRUE)
  endif()
endif()

################################################################################
# Configure man documentation.
################################################################################

block()
  # Replace the hardcoded runstatedir with a template placeholder.
  file(READ "${CMAKE_CURRENT_SOURCE_DIR}/php-fpm.8.in" content)
  string(
    REPLACE
    [[@php_fpm_localstatedir@/run/php-fpm.pid]]
    [[@php_fpm_runstatedir@/php-fpm.pid]]
    content
    "${content}"
  )
  file(
    WRITE
    "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/PHP/php-fpm.8.in"
    "${content}"
  )

  string(CONFIGURE [[
    set(php_fpm_localstatedir "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_LOCALSTATEDIR@,${CMAKE_INSTALL_PREFIX}>")
    # TODO: Fix the GNU standard adjustment issue with /etc, /var, and /var/run.
    set(php_fpm_runstatedir "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_RUNSTATEDIR@,${CMAKE_INSTALL_PREFIX}>")
    set(php_fpm_sysconfdir "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_SYSCONFDIR@,${CMAKE_INSTALL_PREFIX}>")
    set(php_fpm_prefix "${CMAKE_INSTALL_PREFIX}")
    set(PHP_VERSION "@PHP_VERSION@")
  ]] code @ONLY)
  cmake_language(EVAL CODE "${code}")
  string(CONFIGURE "${content}" content @ONLY)
  file(GENERATE OUTPUT php-fpm.8 CONTENT "${content}")

  # Regenerate file on the install step when using different installation prefix
  # at the 'cmake --install ... --prefix <install-prefix>' phase.
  string(CONFIGURE [[
    @code@
    configure_file(
      "@CMAKE_CURRENT_BINARY_DIR@/CMakeFiles/PHP/php-fpm.8.in"
      "@CMAKE_CURRENT_BINARY_DIR@/php-fpm.8"
      @ONLY
    )
  ]] code @ONLY)
  install(CODE "${code}" COMPONENT php-doc)

  install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/php-fpm.8
    RENAME ${PHP_PROGRAM_PREFIX}php-fpm${PHP_PROGRAM_SUFFIX}.8
    DESTINATION ${CMAKE_INSTALL_MANDIR}/man8
    COMPONENT php-doc
  )
endblock()

################################################################################
# Configure php-fpm.conf.
################################################################################

block()
  string(CONFIGURE [[
    set(prefix "${CMAKE_INSTALL_PREFIX}")
    set(EXPANDED_LOCALSTATEDIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_LOCALSTATEDIR@,${CMAKE_INSTALL_PREFIX}>")
    set(php_fpm_sysconfdir "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_SYSCONFDIR@,${CMAKE_INSTALL_PREFIX}>")
  ]] code @ONLY)
  cmake_language(EVAL CODE "${code}")

  file(READ "${CMAKE_CURRENT_SOURCE_DIR}/php-fpm.conf.in" content)
  string(CONFIGURE "${content}" content @ONLY)
  file(GENERATE OUTPUT php-fpm.conf CONTENT "${content}")

  # Regenerate file on the install step when using different installation prefix
  # at the 'cmake --install ... --prefix <install-prefix>' phase.
  string(CONFIGURE [[
    @code@
    configure_file(
      "@CMAKE_CURRENT_SOURCE_DIR@/php-fpm.conf.in"
      "@CMAKE_CURRENT_BINARY_DIR@/php-fpm.conf"
      @ONLY
    )
  ]] code @ONLY)
  install(CODE "${code}" COMPONENT php-sapi-fpm)
endblock()

################################################################################
# Configure www.conf.
################################################################################

block()
  string(CONFIGURE [[
    set(prefix "${CMAKE_INSTALL_PREFIX}")
    set(php_fpm_prefix "${CMAKE_INSTALL_PREFIX}")
    set(php_fpm_user "@PHP_SAPI_FPM_USER@")
    set(php_fpm_group "@PHP_SAPI_FPM_GROUP@")
    set(EXPANDED_DATADIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_DATADIR@,${CMAKE_INSTALL_PREFIX}>")
  ]] code @ONLY)
  cmake_language(EVAL CODE "${code}")

  file(READ "${CMAKE_CURRENT_SOURCE_DIR}/www.conf.in" content)
  string(CONFIGURE "${content}" content @ONLY)
  file(GENERATE OUTPUT www.conf CONTENT "${content}")

  # Regenerate file on the install step when using different installation prefix
  # at the 'cmake --install ... --prefix <install-prefix>' phase.
  string(CONFIGURE [[
    @code@
    configure_file(
      "@CMAKE_CURRENT_SOURCE_DIR@/www.conf.in"
      "@CMAKE_CURRENT_BINARY_DIR@/www.conf"
      @ONLY
    )
  ]] code @ONLY)
  install(CODE "${code}" COMPONENT php-sapi-fpm)
endblock()

################################################################################
# Configure init.d.php-fpm.
################################################################################

block()
  # Replace the hardcoded runstatedir with a template placeholder.
  file(READ "${CMAKE_CURRENT_SOURCE_DIR}/init.d.php-fpm.in" content)
  string(
    REPLACE
    [[php_fpm_PID=@localstatedir@/run/php-fpm.pid]]
    [[php_fpm_PID=@runstatedir@/php-fpm.pid]]
    content
    "${content}"
  )
  file(
    WRITE
    "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/PHP/init.d.php-fpm.in"
    "${content}"
  )

  string(CONFIGURE [[
    set(prefix "${CMAKE_INSTALL_PREFIX}")
    set(exec_prefix "${CMAKE_INSTALL_PREFIX}")
    set(sbindir "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_SBINDIR@,${CMAKE_INSTALL_PREFIX}>")
    set(sysconfdir "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_SYSCONFDIR@,${CMAKE_INSTALL_PREFIX}>")
    set(runstatedir "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_RUNSTATEDIR@,${CMAKE_INSTALL_PREFIX}>")
  ]] code @ONLY)
  cmake_language(EVAL CODE "${code}")
  string(CONFIGURE "${content}" content @ONLY)
  file(GENERATE OUTPUT init.d.php-fpm CONTENT "${content}")

  # Regenerate file on the install step when using different installation prefix
  # at the 'cmake --install ... --prefix <install-prefix>' phase.
  string(CONFIGURE [[
    @code@
    configure_file(
      "@CMAKE_CURRENT_BINARY_DIR@/CMakeFiles/PHP/init.d.php-fpm.in"
      "@CMAKE_CURRENT_BINARY_DIR@/init.d.php-fpm"
      @ONLY
    )
  ]] code @ONLY)
  install(CODE "${code}" COMPONENT php-sapi-fpm)
endblock()

################################################################################
# Configure php-fpm.service.
################################################################################

block()
  # Replace the hardcoded runstatedir with a template placeholder.
  file(READ "${CMAKE_CURRENT_SOURCE_DIR}/php-fpm.service.in" content)
  string(
    REPLACE
    [[PIDFile=@EXPANDED_LOCALSTATEDIR@/run/php-fpm.pid]]
    [[PIDFile=@EXPANDED_RUNSTATEDIR@/php-fpm.pid]]
    content
    "${content}"
  )
  file(
    WRITE
    "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/PHP/php-fpm.service.in"
    "${content}"
  )

  string(CONFIGURE [[
    set(php_fpm_systemd "@PHP_FPM_SYSTEMD@")
    set(EXPANDED_RUNSTATEDIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_RUNSTATEDIR@,${CMAKE_INSTALL_PREFIX}>")
    set(EXPANDED_SBINDIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_SBINDIR@,${CMAKE_INSTALL_PREFIX}>")
    set(EXPANDED_SYSCONFDIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_SYSCONFDIR@,${CMAKE_INSTALL_PREFIX}>")
  ]] code @ONLY)
  cmake_language(EVAL CODE "${code}")
  string(CONFIGURE "${content}" content @ONLY)
  file(GENERATE OUTPUT php-fpm.service CONTENT "${content}")

  # Regenerate file on the install step when using different installation prefix
  # at the 'cmake --install ... --prefix <install-prefix>' phase.
  string(CONFIGURE [[
    @code@
    configure_file(
      "@CMAKE_CURRENT_BINARY_DIR@/CMakeFiles/PHP/php-fpm.service.in"
      "@CMAKE_CURRENT_BINARY_DIR@/php-fpm.service"
      @ONLY
    )
  ]] code @ONLY)
  install(CODE "${code}" COMPONENT php-sapi-fpm)
endblock()

################################################################################
# Installation.
################################################################################

install(
  TARGETS php_sapi_fpm
  RUNTIME
    DESTINATION ${CMAKE_INSTALL_SBINDIR}
    COMPONENT php-sapi-fpm
)

# Create log and run directories on installation.
install(
  DIRECTORY
  DESTINATION ${CMAKE_INSTALL_LOCALSTATEDIR}/log
  COMPONENT php-sapi-fpm
)

install(
  DIRECTORY
  DESTINATION ${CMAKE_INSTALL_RUNSTATEDIR}
  COMPONENT php-sapi-fpm
)

install(
  CODE "
  if(NOT IS_ABSOLUTE \"${CMAKE_INSTALL_SYSCONFDIR}\")
    set(
      sysconf_dir
      \"\$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_SYSCONFDIR}\"
    )
  else()
    set(sysconf_dir \"\$ENV{DESTDIR}${CMAKE_INSTALL_SYSCONFDIR}\")
  endif()

  if(EXISTS \"\${sysconf_dir}/php-fpm.conf\")
    message(
      STATUS
      \"Skipping PHP FPM defconfig installation. Files already exist.\"
    )
  else()
    message(STATUS \"Installing PHP FPM defconfig to \${sysconf_dir}\")

    file(MAKE_DIRECTORY \"\${sysconf_dir}/php-fpm.d\")

    file(
      COPY_FILE
      \"${CMAKE_CURRENT_BINARY_DIR}/php-fpm.conf\"
      \"\${sysconf_dir}/php-fpm.conf.default\"
    )

    file(
      COPY_FILE
      \"${CMAKE_CURRENT_BINARY_DIR}/www.conf\"
      \"\${sysconf_dir}/php-fpm.d/www.conf.default\"
    )
  endif()"
  COMPONENT php-sapi-fpm
)

################################################################################
# FPM info status HTML page.
################################################################################

configure_file(status.html.in status.html @ONLY)

install(
  FILES
    ${CMAKE_CURRENT_BINARY_DIR}/status.html
  DESTINATION ${CMAKE_INSTALL_DATADIR}/fpm
  COMPONENT php-sapi-fpm
)

################################################################################
# Configuration header.
################################################################################

configure_file(cmake/config.h.in config.h)
