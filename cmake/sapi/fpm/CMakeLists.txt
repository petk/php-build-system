# SAPI is only for *nix systems.
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

include(CheckIncludeFile)
include(CheckSourceCompiles)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

################################################################################
# FPM configuration.
################################################################################

option(SAPI_FPM "Enable the FPM SAPI module" OFF)

add_feature_info(
  "sapi/fpm"
  SAPI_FPM
  "FPM SAPI module"
)

if(SAPI_FPM)
  set(
    SAPI_FPM_USER "nobody"
    CACHE STRING "Set the user for running PHP FPM (default: nobody)"
  )

  set(
    SAPI_FPM_GROUP "nobody"
    CACHE STRING "Set the group for running PHP FPM. For a system user, this \
should usually be set to match the FPM username (default: nobody)"
  )

  set(PHP_FPM_USER "${SAPI_FPM_USER}" CACHE INTERNAL "FPM user")
  set(PHP_FPM_GROUP "${SAPI_FPM_GROUP}" CACHE INTERNAL "FPM group")
else()
  unset(SAPI_FPM_USER CACHE)
  unset(PHP_FPM_USER CACHE)
  unset(SAPI_FPM_GROUP CACHE)
  unset(PHP_FPM_GROUP CACHE)
endif()

cmake_dependent_option(
  SAPI_FPM_SYSTEMD
  "Enable the systemd integration"
  OFF
  "SAPI_FPM"
  OFF
)

add_feature_info(
  "sapi/fpm systemd"
  SAPI_FPM
  "FPM SAPI module with systemd integration"
)

cmake_dependent_option(
  SAPI_FPM_ACL
  "Use POSIX Access Control Lists"
  OFF
  "SAPI_FPM"
  OFF
)

add_feature_info(
  "sapi/fpm ACL"
  SAPI_FPM
  "FPM SAPI module with integrated POSIX Access Control Lists"
)

cmake_dependent_option(
  SAPI_FPM_APPARMOR
  "Enable the AppArmor confinement through libapparmor"
  OFF
  "SAPI_FPM"
  OFF
)

add_feature_info(
  "sapi/fpm AppArmor"
  SAPI_FPM
  "FPM SAPI module with AppArmor confinement enabled"
)

cmake_dependent_option(
  SAPI_FPM_SELINUX
  "Enable the SELinux policy library support"
  OFF
  "SAPI_FPM"
  OFF
)

add_feature_info(
  "sapi/fpm SELinux"
  SAPI_FPM
  "FPM SAPI module with SELinux policy library support"
)

message(CHECK_START "Checking whether to build fpm SAPI")
if(SAPI_FPM)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
  return()
endif()

################################################################################
# Add executable.
################################################################################

add_executable(
  php_fpm
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
  php_fpm
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/fpm
)

target_compile_definitions(php_fpm PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

target_link_libraries(php_fpm PRIVATE PHP::main)

set_target_properties(
  php_fpm
  PROPERTIES
    OUTPUT_NAME php-fpm
    # TODO: Check if there's a better solution here:
    ENABLE_EXPORTS TRUE
)

################################################################################
# Configuration checks.
################################################################################

check_symbol_exists(clearenv "stdlib.h" HAVE_CLEARENV)
check_symbol_exists(port_create "port.h" HAVE_PORT_CREATE)
check_symbol_exists(setpflags "priv.h" HAVE_SETPFLAGS)
check_symbol_exists(setproctitle "unistd.h;stdlib.h" HAVE_SETPROCTITLE)
check_symbol_exists(setproctitle_fast "unistd.h" HAVE_SETPROCTITLE_FAST)
check_symbol_exists(times "sys/times.h" HAVE_TIMES)

# Check for clock_get*time.
include(PHP/CheckClockGettime)
if(TARGET PHP::CheckClockGettimeLibrary)
  target_link_libraries(php_fpm PRIVATE PHP::CheckClockGettimeLibrary)
endif()

# Check for ptrace.
include(PHP/CheckPtrace)
if(
  PHP_TRACE_TYPE
  AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/fpm/fpm_trace_${PHP_TRACE_TYPE}.c
)
  target_sources(
    php_fpm
    PRIVATE
      fpm/fpm_trace.c
      fpm/fpm_trace_${PHP_TRACE_TYPE}.c
  )
endif()

message(CHECK_START "Checking if compiler supports __sync_bool_compare_and_swap")
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

include(PHP/CheckListeningQueue)

message(CHECK_START "Checking for kqueue")
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
if(HAVE_KQUEUE)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

message(CHECK_START "Checking for epoll")
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

if(SAPI_FPM_SYSTEMD)
  find_package(Systemd 209)
  set_package_properties(
    Systemd
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable systemd integration in FPM SAPI."
  )

  target_link_libraries(php_fpm PRIVATE Systemd::Systemd)

  if(TARGET Systemd::Systemd)
    set(HAVE_SYSTEMD 1 CACHE INTERNAL "Whether FPM is using systemd integration")

    target_sources(php_fpm PRIVATE fpm/fpm_systemd.c)
  endif()

  set(PHP_FPM_SYSTEMD "notify" CACHE INTERNAL "FPM systemd service type")
else()
  set(PHP_FPM_SYSTEMD "simple" CACHE INTERNAL "FPM systemd service type")
endif()

if(SAPI_FPM_ACL)
  set(ACL_USE_USER_GROUP TRUE)
  find_package(ACL)
  set_package_properties(
    ACL
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable FPM SAPI ACL user/group permissions support."
  )

  target_link_libraries(php_fpm PRIVATE ACL::ACL)

  if(TARGET ACL::ACL)
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LIBRARIES ACL::ACL)
      check_include_file(sys/acl.h HAVE_SYS_ACL_H)
    cmake_pop_check_state()

    set(HAVE_FPM_ACL 1 CACHE INTERNAL "Whether FPM has ACL support")
  endif()
endif()

if(SAPI_FPM_APPARMOR)
  find_package(AppArmor)
  set_package_properties(
    AppArmor
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable AppArmor support in the FPM SAPI."
  )

  target_link_libraries(php_fpm PRIVATE AppArmor::AppArmor)

  if(TARGET AppArmor::AppArmor)
    set(HAVE_APPARMOR 1 CACHE INTERNAL "Whether AppArmor is present")
  endif()
endif()

if(SAPI_FPM_SELINUX)
  find_package(SELinux)
  set_package_properties(
    SELinux
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable SELinux support in the FPM SAPI."
  )

  target_link_libraries(php_fpm PRIVATE SELinux::SELinux)

  if(TARGET SELinux::SELinux)
    set(HAVE_SELINUX 1 CACHE INTERNAL "Whether SELinux is present")
  endif()
endif()

################################################################################
# Install files.
################################################################################

block()
  # Man documentation.
  set(php_fpm_localstatedir "${CMAKE_INSTALL_FULL_LOCALSTATEDIR}")
  set(php_fpm_sysconfdir "${CMAKE_INSTALL_FULL_SYSCONFDIR}")
  set(php_fpm_prefix "${CMAKE_INSTALL_PREFIX}")
  configure_file(php-fpm.8.in php-fpm.8 @ONLY)

  set(EXPANDED_LOCALSTATEDIR "${CMAKE_INSTALL_FULL_LOCALSTATEDIR}")
  set(prefix "${CMAKE_INSTALL_PREFIX}")
  configure_file(php-fpm.conf.in php-fpm.conf @ONLY)

  set(EXPANDED_DATADIR "${CMAKE_INSTALL_FULL_DATADIR}")
  set(php_fpm_user "${SAPI_FPM_USER}")
  set(php_fpm_group "${SAPI_FPM_GROUP}")
  configure_file(www.conf.in www.conf @ONLY)

  set(exec_prefix "${CMAKE_INSTALL_PREFIX}")
  set(sbindir "${CMAKE_INSTALL_FULL_SBINDIR}")
  set(sysconfdir "${CMAKE_INSTALL_FULL_SYSCONFDIR}")
  set(localstatedir "${CMAKE_INSTALL_FULL_LOCALSTATEDIR}")
  configure_file(init.d.php-fpm.in init.d.php-fpm @ONLY)

  set(php_fpm_systemd "${PHP_FPM_SYSTEMD}")
  set(EXPANDED_SBINDIR "${CMAKE_INSTALL_FULL_SBINDIR}")
  set(EXPANDED_SYSCONFDIR "${CMAKE_INSTALL_FULL_SYSCONFDIR}")
  configure_file(php-fpm.service.in php-fpm.service @ONLY)

  # FPM info status HTML page.
  configure_file(status.html.in status.html @ONLY)
endblock()

# TODO: Add program file prefix and suffix.
install(TARGETS php_fpm DESTINATION ${CMAKE_INSTALL_SBINDIR})

# TODO: Add file suffix.
install(
  FILES
    ${CMAKE_CURRENT_BINARY_DIR}/php-fpm.8
  DESTINATION ${CMAKE_INSTALL_MANDIR}/man8
)

# Create log and run directories on installation.
install(DIRECTORY DESTINATION ${CMAKE_INSTALL_LOCALSTATEDIR}/log)
install(DIRECTORY DESTINATION ${CMAKE_INSTALL_LOCALSTATEDIR}/run)

install(CODE "
  if(EXISTS \"\${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_SYSCONFDIR}/php-fpm.conf\")
    message(
      STATUS
      \"Skipping PHP FPM defconfig installation. Files already exist.\"
    )
  else()
    message(
      STATUS
      \"Installing PHP FPM defconfig to \"
      \"\${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_SYSCONFDIR}\"
    )

    file(
      MAKE_DIRECTORY
      \"\${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_SYSCONFDIR}/php-fpm.d\"
    )

    file(
      COPY_FILE
      \"${CMAKE_CURRENT_BINARY_DIR}/php-fpm.conf\"
      \"\${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_SYSCONFDIR}/php-fpm.conf.default\"
    )

    file(
      COPY_FILE
      \"${CMAKE_CURRENT_BINARY_DIR}/www.conf\"
      \"\${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_SYSCONFDIR}/php-fpm.d/www.conf.default\"
    )
  endif()
")

install(
  FILES
    ${CMAKE_CURRENT_BINARY_DIR}/status.html
  DESTINATION ${CMAKE_INSTALL_DATADIR}/fpm
)
