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

include(CheckIncludeFile)
include(CheckSourceCompiles)
include(CheckSourceRuns)
include(CheckSymbolExists)
include(CMakePushCheckState)
include(FeatureSummary)
include(PHP/ConfigureFile)
include(PHP/Install)
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
    fpm/events/devpoll.c
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
    ${CMAKE_CURRENT_SOURCE_DIR}/fpm
)

target_compile_definitions(php_sapi_fpm PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

target_link_libraries(
  php_sapi_fpm
  PRIVATE
    PHP::sapi
)

set_target_properties(
  php_sapi_fpm
  PROPERTIES
    OUTPUT_NAME ${PHP_PROGRAM_PREFIX}php-fpm${PHP_PROGRAM_SUFFIX}
    # TODO: Check if there's a better solution here:
    ENABLE_EXPORTS TRUE
)

################################################################################
# Configuration checks.
################################################################################

check_symbol_exists(clearenv "stdlib.h" HAVE_CLEARENV)
check_symbol_exists(port_create "port.h" HAVE_PORT)
check_symbol_exists(setpflags "priv.h" HAVE_SETPFLAGS)
check_symbol_exists(setproctitle "unistd.h;stdlib.h" HAVE_SETPROCTITLE)
check_symbol_exists(setproctitle_fast "unistd.h" HAVE_SETPROCTITLE_FAST)
check_symbol_exists(sysconf "unistd.h" HAVE_SYSCONF)
check_symbol_exists(times "sys/times.h" HAVE_TIMES)

# Check FPM listening queue implementation.
include(cmake/CheckListeningQueue.cmake)

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

# Check for clock_get*time.
php_search_libraries(
  clock_gettime
  HEADERS time.h
  LIBRARIES
    rt # Solaris 10
  VARIABLE HAVE_CLOCK_GETTIME
  TARGET php_sapi_fpm PRIVATE
)
if(NOT HAVE_CLOCK_GETTIME)
  check_source_runs(C [[
    #include <mach/mach.h>
    #include <mach/clock.h>
    #include <mach/mach_error.h>

    int main(void)
    {
      kern_return_t ret;
      clock_serv_t aClock;
      mach_timespec_t aTime;

      ret = host_get_clock_service(mach_host_self(), REALTIME_CLOCK, &aClock);
      if (ret != KERN_SUCCESS) {
        return 1;
      }

      ret = clock_get_time(aClock, &aTime);
      if (ret != KERN_SUCCESS) {
        return 2;
      }

      return 0;
    }
  ]] HAVE_CLOCK_GET_TIME)
endif()

# Check for compiler atomic builtins.
message(CHECK_START "Checking if compiler has __sync_bool_compare_and_swap")
check_source_compiles(C [[
  int main(void)
  {
    int variable = 1;
    return (__sync_bool_compare_and_swap(&variable, 1, 2)
           && __sync_add_and_fetch(&variable, 1)) ? 1 : 0;
  }
]] HAVE_BUILTIN_ATOMIC)
if(HAVE_BUILTIN_ATOMIC)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

message(CHECK_START "Checking for kqueue")
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_source_compiles(C [[
    #include <sys/types.h>
    #include <sys/event.h>
    #include <sys/time.h>

    int main(void)
    {
      int kfd;
      struct kevent k;
      kfd = kqueue();
      /* 0 -> STDIN_FILENO */
      EV_SET(&k, 0, EVFILT_READ , EV_ADD | EV_CLEAR, 0, 0, NULL);
      (void)kfd;

      return 0;
    }
  ]] HAVE_KQUEUE)
cmake_pop_check_state()
if(HAVE_KQUEUE)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

# For Solaris < 10.
message(CHECK_START "Checking for /dev/poll")
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_source_compiles(C [[
    #include <stdio.h>
    #include <sys/devpoll.h>

    int main(void)
    {
      int n, dp;
      struct dvpoll dvp;
      dp = 0;
      dvp.dp_fds = NULL;
      dvp.dp_nfds = 0;
      dvp.dp_timeout = 0;
      n = ioctl(dp, DP_POLL, &dvp);
      (void)n;

      return 0;
    }
  ]] HAVE_DEVPOLL)
cmake_pop_check_state()
if(HAVE_DEVPOLL)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

message(CHECK_START "Checking for epoll")
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_source_compiles(C [[
    #include <sys/epoll.h>

    int main(void)
    {
      int epollfd;
      struct epoll_event e;

      epollfd = epoll_create(1);
      if (epollfd < 0) {
        return 1;
      }

      e.events = EPOLLIN | EPOLLET;
      e.data.fd = 0;

      if (epoll_ctl(epollfd, EPOLL_CTL_ADD, 0, &e) == -1) {
        return 1;
      }

      e.events = 0;
      if (epoll_wait(epollfd, &e, 1, 1) < 0) {
        return 1;
      }

      return 0;
    }
  ]] HAVE_EPOLL)
cmake_pop_check_state()
if(HAVE_EPOLL)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

message(CHECK_START "Checking for select")
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)

  check_source_compiles(C [[
    /* According to POSIX.1-2001 */
    #include <sys/select.h>

    /* According to earlier standards */
    #include <sys/time.h>
    #include <sys/types.h>
    #include <unistd.h>

    int main(void)
    {
      fd_set fds;
      struct timeval t;
      t.tv_sec = 0;
      t.tv_usec = 42;
      FD_ZERO(&fds);
      /* 0 -> STDIN_FILENO */
      FD_SET(0, &fds);
      select(FD_SETSIZE, &fds, NULL, NULL, &t);

      return 0;
    }
  ]] HAVE_SELECT)
cmake_pop_check_state()
if(HAVE_SELECT)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
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
      check_include_file(sys/acl.h HAVE_SYS_ACL_H)
    cmake_pop_check_state()

    set(HAVE_FPM_ACL TRUE)
  endif()
endif()

if(PHP_SAPI_FPM_APPARMOR)
  find_package(AppArmor)
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
  find_package(SELinux)
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
# Install files.
################################################################################

# Man documentation.

# Replace the hardcoded runstatedir with a template placeholder.
file(READ "${CMAKE_CURRENT_SOURCE_DIR}/php-fpm.8.in" content)
string(
  REPLACE
  [[@php_fpm_localstatedir@/run/php-fpm.pid]]
  [[@php_fpm_runstatedir@/php-fpm.pid]]
  content
  "${content}"
)
php_configure_file(
  CONTENT "${content}"
  OUTPUT php-fpm.8
  VARIABLES
    php_fpm_localstatedir "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_LOCALSTATEDIR},$<INSTALL_PREFIX>>"
    # TODO: Fix the GNU standard adjustment issue with /etc, /var, and /var/run.
    php_fpm_runstatedir "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_RUNSTATEDIR},$<INSTALL_PREFIX>>"
    php_fpm_sysconfdir "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_SYSCONFDIR},$<INSTALL_PREFIX>>"
    php_fpm_prefix "$<INSTALL_PREFIX>"
    PHP_VERSION "${PHP_VERSION}"
)
install(
  FILES ${CMAKE_CURRENT_BINARY_DIR}/php-fpm.8
  RENAME ${PHP_PROGRAM_PREFIX}php-fpm${PHP_PROGRAM_SUFFIX}.8
  DESTINATION ${CMAKE_INSTALL_MANDIR}/man8
)

php_configure_file(
  INPUT php-fpm.conf.in
  OUTPUT php-fpm.conf
  VARIABLES
    prefix "$<INSTALL_PREFIX>"
    EXPANDED_LOCALSTATEDIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_LOCALSTATEDIR},$<INSTALL_PREFIX>>"
    php_fpm_sysconfdir "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_SYSCONFDIR},$<INSTALL_PREFIX>>"
)

php_configure_file(
  INPUT www.conf.in
  OUTPUT www.conf
  VARIABLES
    prefix "$<INSTALL_PREFIX>"
    php_fpm_prefix "$<INSTALL_PREFIX>"
    php_fpm_user "${PHP_SAPI_FPM_USER}"
    php_fpm_group "${PHP_SAPI_FPM_GROUP}"
    EXPANDED_DATADIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_DATADIR},$<INSTALL_PREFIX>>"
)

# Replace the hardcoded runstatedir with a template placeholder.
file(READ "${CMAKE_CURRENT_SOURCE_DIR}/init.d.php-fpm.in" content)
string(
  REPLACE
  [[php_fpm_PID=@localstatedir@/run/php-fpm.pid]]
  [[php_fpm_PID=@runstatedir@/php-fpm.pid]]
  content
  "${content}"
)

php_configure_file(
  CONTENT "${content}"
  OUTPUT init.d.php-fpm
  VARIABLES
    prefix "$<INSTALL_PREFIX>"
    exec_prefix "$<INSTALL_PREFIX>"
    sbindir "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_SBINDIR},$<INSTALL_PREFIX>>"
    # TODO: Fix the GNU standard adjustment issue with /etc, /var, and /var/run.
    sysconfdir "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_SYSCONFDIR},$<INSTALL_PREFIX>>"
    runstatedir "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_RUNSTATEDIR},$<INSTALL_PREFIX>>"
)

# Replace the hardcoded runstatedir with a template placeholder.
file(READ "${CMAKE_CURRENT_SOURCE_DIR}/php-fpm.service.in" content)
string(
  REPLACE
  [[PIDFile=@EXPANDED_LOCALSTATEDIR@/run/php-fpm.pid]]
  [[PIDFile=@EXPANDED_RUNSTATEDIR@/php-fpm.pid]]
  content
  "${content}"
)

php_configure_file(
  CONTENT "${content}"
  OUTPUT php-fpm.service
  VARIABLES
    php_fpm_systemd "${PHP_FPM_SYSTEMD}"
    EXPANDED_RUNSTATEDIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_RUNSTATEDIR},$<INSTALL_PREFIX>>"
    EXPANDED_SBINDIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_SBINDIR},$<INSTALL_PREFIX>>"
    EXPANDED_SYSCONFDIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_SYSCONFDIR},$<INSTALL_PREFIX>>"
)

install(TARGETS php_sapi_fpm RUNTIME DESTINATION ${CMAKE_INSTALL_SBINDIR})

php_install(CODE "
  # Create log and run directories on installation.
  file(
    MAKE_DIRECTORY
    \"\$ENV{DESTDIR}\${CMAKE_INSTALL_FULL_LOCALSTATEDIR}/log\"
    \"\$ENV{DESTDIR}\${CMAKE_INSTALL_FULL_RUNSTATEDIR}\"
  )

  if(EXISTS \"\$ENV{DESTDIR}\${CMAKE_INSTALL_FULL_SYSCONFDIR}/php-fpm.conf\")
    message(
      STATUS
      \"Skipping PHP FPM defconfig installation. Files already exist.\"
    )
  else()
    message(
      STATUS
      \"Installing PHP FPM defconfig to \"
      \"\$ENV{DESTDIR}\${CMAKE_INSTALL_FULL_SYSCONFDIR}\"
    )

    file(
      MAKE_DIRECTORY
      \"\$ENV{DESTDIR}\${CMAKE_INSTALL_FULL_SYSCONFDIR}/php-fpm.d\"
    )

    file(
      COPY_FILE
      \"${CMAKE_CURRENT_BINARY_DIR}/php-fpm.conf\"
      \"\$ENV{DESTDIR}\${CMAKE_INSTALL_FULL_SYSCONFDIR}/php-fpm.conf.default\"
    )

    file(
      COPY_FILE
      \"${CMAKE_CURRENT_BINARY_DIR}/www.conf\"
      \"\$ENV{DESTDIR}\${CMAKE_INSTALL_FULL_SYSCONFDIR}/php-fpm.d/www.conf.default\"
    )
  endif()
")

# FPM info status HTML page.
configure_file(status.html.in status.html @ONLY)

install(
  FILES
    ${CMAKE_CURRENT_BINARY_DIR}/status.html
  DESTINATION ${CMAKE_INSTALL_DATADIR}/fpm
)

configure_file(cmake/config.h.in config.h)
