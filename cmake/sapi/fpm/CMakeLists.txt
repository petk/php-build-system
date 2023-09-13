include(CheckCSourceCompiles)
include(CheckCSourceRuns)
include(CheckIncludeFile)
include(CheckLibraryExists)
include(CheckSymbolExists)
include(CMakeDependentOption)

option(SAPI_FPM "Whether to use the PHP FPM SAPI module" OFF)

if(SAPI_FPM)
  set(SAPI_FPM_USER "nobody" CACHE STRING "Set the user for php-fpm to run as. (default: nobody)")
else()
  unset(SAPI_FPM_USER CACHE)
endif()

if(SAPI_FPM)
  set(SAPI_FPM_GROUP "nobody" CACHE STRING "Set the group for php-fpm to run as. For a system user, this should
  usually be set to match the fpm username (default: nobody)")
else()
  unset(SAPI_FPM_GROUP CACHE)
endif()

cmake_dependent_option(SAPI_FPM_SYSTEMD "Whether to activate systemd integration" OFF "SAPI_FPM" OFF)
cmake_dependent_option(SAPI_FPM_ACL "Use POSIX Access Control Lists" OFF "SAPI_FPM" OFF)
cmake_dependent_option(SAPI_FPM_APPARMOR "Support AppArmor confinement through libapparmor" OFF "SAPI_FPM" OFF)
cmake_dependent_option(SAPI_FPM_SELINUX "Support SELinux policy library" OFF "SAPI_FPM" OFF)

if(NOT SAPI_FPM)
  return()
endif()

add_executable(php-fpm
  fpm/fpm.c
  fpm/fpm_children.c
  fpm/fpm_cleanup.c
  fpm/fpm_clock.c
  fpm/fpm_conf.c
  fpm/fpm_env.c
  fpm/fpm_events.c
  fpm/fpm_log.c
  fpm/fpm_main.c
  fpm/fpm_php.c
  fpm/fpm_php_trace.c
  fpm/fpm_process_ctl.c
  fpm/fpm_request.c
  fpm/fpm_shm.c
  fpm/fpm_scoreboard.c
  fpm/fpm_signals.c
  fpm/fpm_sockets.c
  fpm/fpm_status.c
  fpm/fpm_stdio.c
  fpm/fpm_unix.c
  fpm/fpm_worker_pool.c
  fpm/zlog.c
  fpm/events/select.c
  fpm/events/poll.c
  fpm/events/epoll.c
  fpm/events/kqueue.c
  fpm/events/devpoll.c
  fpm/events/port.c
)

target_include_directories(
  php-fpm
  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}
          ${CMAKE_CURRENT_SOURCE_DIR}/fpm
)

target_compile_definitions(php-fpm PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

target_link_libraries(php-fpm PRIVATE main)

if(EXTRA_LIBS)
  target_link_libraries(php-fpm PRIVATE ${EXTRA_LIBS})
endif()

if(EXTRA_DEFINITIONS)
  target_compile_definitions(php-fpm PRIVATE ${EXTRA_DEFINITIONS})
endif()

# TODO: Check if there's a better solution here.
set_target_properties(php-fpm PROPERTIES ENABLE_EXPORTS TRUE)

check_symbol_exists(clearenv "stdlib.h" HAVE_CLEARENV)
check_symbol_exists(setproctitle "unistd.h;stdlib.h" HAVE_SETPROCTITLE)
check_symbol_exists(setproctitle_fast "unistd.h" HAVE_SETPROCTITLE_FAST)

# TODO: Check this differently - only link libraries if actually needed.
check_library_exists(socket socket "" _have_socket)

if(_have_socket)
  target_link_libraries(php-fpm PRIVATE socket)
endif()
unset(_have_socket CACHE)

# TODO: Check this differently - only link libraries if actually needed.
check_library_exists(nsl inet_addr "" _have_inet_addr)

if(_have_inet_addr)
  target_link_libraries(php-fpm PRIVATE nsl)
endif()
unset(_have_inet_addr CACHE)

check_c_source_compiles("
  #include <priv.h>

  int main(void) {
    setpflags(0, 0);
    return 0;
  }
" HAVE_SETPFLAGS)

include(PHPCheckFpmClock)

if(FPM_CLOCK_LIBRARIES)
  target_link_libraries(php-fpm PRIVATE ${FPM_CLOCK_LIBRARIES})
endif()

include(PHPCheckFpmPtrace)

if(
  FPM_TRACE_TYPE
  AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/fpm/fpm_trace_${FPM_TRACE_TYPE}.c"
)
  target_sources(
    php-fpm
    PRIVATE
      fpm/fpm_trace.c
      fpm/fpm_trace_${FPM_TRACE_TYPE}.c
  )
endif()

check_c_source_compiles("
  int main(void) {
    int variable = 1;
    return (__sync_bool_compare_and_swap(&variable, 1, 2)
           && __sync_add_and_fetch(&variable, 1)) ? 1 : 0;
  }
" HAVE_BUILTIN_ATOMIC)

include(PHPCheckFpmLq)

check_c_source_compiles("
  #include <unistd.h>

  int main(void) {
    sysconf(_SC_CLK_TCK);
    return 0;
  }
" HAVE_SYSCONF)

check_c_source_compiles("
  #include <sys/times.h>

  int main(void) {
    struct tms t;
    times(&t);
    return 0;
  }
" HAVE_TIMES)

check_c_source_compiles("
  #include <sys/types.h>
  #include <sys/event.h>
  #include <sys/time.h>

  int main(void) {
    int kfd;
    struct kevent k;
    kfd = kqueue();
    /* 0 -> STDIN_FILENO */
    EV_SET(&k, 0, EVFILT_READ , EV_ADD | EV_CLEAR, 0, 0, NULL);

    return 0;
  }
" HAVE_KQUEUE)

check_c_source_compiles("
  #include <port.h>

  int main(void) {
    int port;

    port = port_create();
    if (port < 0) {
      return 1;
    }

    return 0;
  }
" HAVE_PORT)

check_c_source_compiles("
  #include <stdio.h>
  #include <sys/devpoll.h>

  int main(void) {
    int n, dp;
    struct dvpoll dvp;
    dp = 0;
    dvp.dp_fds = NULL;
    dvp.dp_nfds = 0;
    dvp.dp_timeout = 0;
    n = ioctl(dp, DP_POLL, &dvp)

    return 0;
  }
" HAVE_DEVPOLL)

check_c_source_compiles("
  #include <sys/epoll.h>

  int main(void) {
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
" HAVE_EPOLL)

check_c_source_compiles("
  /* According to POSIX.1-2001 */
  #include <sys/select.h>

  /* According to earlier standards */
  #include <sys/time.h>
  #include <sys/types.h>
  #include <unistd.h>

  int main(void) {
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
" HAVE_SELECT)

if(SAPI_FPM_SYSTEMD)
  find_package(SYSTEMD 209 REQUIRED)

  check_include_file(systemd/sd-daemon.h HAVE_SYSTEMD)

  if(NOT HAVE_SYSTEMD)
    message(FATAL_ERROR "Your system does not support systemd.")
  endif()

  target_sources(php-fpm PRIVATE fpm/fpm_systemd.c)

  if(SYSTEMD_LIBRARIES)
    target_link_libraries(php-fpm PRIVATE ${SYSTEMD_LIBRARIES})
  endif()

  if(SYSTEMD_INCLUDE_DIRS)
    target_include_directories(php-fpm PRIVATE ${SYSTEMD_INCLUDE_DIRS})
  endif()

  set(PHP_FPM_SYSTEMD "notify" CACHE INTERNAL "FPM systemd service type")
else()
  set(PHP_FPM_SYSTEMD "simple" CACHE INTERNAL "FPM systemd service type")
endif()

if(SAPI_FPM_ACL)
  check_include_file(sys/acl.h HAVE_SYS_ACL_H)

  check_c_source_compiles("
    #include <sys/acl.h>

    int main(void) {
      acl_t acl;
      acl_entry_t user, group;
      acl = acl_init(1);
      acl_create_entry(&acl, &user);
      acl_set_tag_type(user, ACL_USER);
      acl_create_entry(&acl, &group);
      acl_set_tag_type(user, ACL_GROUP);
      acl_free(acl);
      return 0;
    }
  " _acl_successful)

  if(_acl_successful)
    check_library_exists(acl acl_free "" HAVE_FPM_ACL)
  endif()

  unset(_acl_successful CACHE)

  if(NOT HAVE_FPM_ACL)
    if(NOT CMAKE_CROSSCOMPILING)
      check_c_source_runs("
        #include <sys/acl.h>
            int main(void)
            {
              acl_t acl;
              acl_entry_t user, group;
              acl = acl_init(1);
              acl_create_entry(&acl, &user);
              acl_set_tag_type(user, ACL_USER);
              acl_create_entry(&acl, &group);
              acl_set_tag_type(user, ACL_GROUP);
              acl_free(acl);
              return 0;
            }
      " HAVE_FPM_ACL)
    endif()
  endif()
endif()

if(SAPI_FPM_APPARMOR)
  check_include_file(sys/apparmor.h HAVE_SYS_APPARMOR_H)

  check_library_exists(apparmor aa_change_profile "" HAVE_APPARMOR)

  if(HAVE_APPARMOR)
    target_link_libraries(php-fpm PRIVATE apparmor)
  endif()
endif()

if(SAPI_FPM_SELINUX)
  check_include_file(selinux/selinux.h HAVE_SELINUX_SELINUX_H)

  check_library_exists(selinux security_setenforce "" HAVE_SELINUX)

  if(HAVE_SELINUX)
    target_link_libraries(php-fpm PRIVATE selinux)
  endif()
endif()

function(php_fpm_configure_files)
  # Man documentation.
  configure_file(php-fpm.8.in php-fpm.8 @ONLY)

  # TODO: Add substitution variables.
  # @EXPANDED_LOCALSTATEDIR@
  # @php_fpm_sysconfdir@
  set(prefix ${CMAKE_INSTALL_PREFIX})
  configure_file(php-fpm.conf.in php-fpm.conf @ONLY)

  # TODO: Add substitution variables.
  # @php_fpm_prefix@
  # @EXPANDED_DATADIR@
  set(php_fpm_user ${SAPI_FPM_USER})
  set(php_fpm_group ${SAPI_FPM_GROUP})
  configure_file(www.conf.in www.conf @ONLY)

  # TODO: Add substitution variables.
  # @exec_prefix@
  # @sbindir@
  # @sysconfdir@
  # @localstatedir@
  configure_file(init.d.php-fpm.in init.d.php-fpm @ONLY)

  # TODO: Add substitution variables.
  set(php_fpm_systemd ${PHP_FPM_SYSTEMD})
  # @EXPANDED_LOCALSTATEDIR@
  # @EXPANDED_SBINDIR@
  # @EXPANDED_SYSCONFDIR@
  configure_file(php-fpm.service.in php-fpm.service @ONLY)

  # FPM info status HTML page.
  configure_file(status.html.in status.html @ONLY)
endfunction()

php_fpm_configure_files()

install(TARGETS php-fpm DESTINATION ${CMAKE_INSTALL_SBINDIR})

install(
  FILES
    php-fpm.8
  DESTINATION ${CMAKE_INSTALL_MANDIR}/man8
)

# TODO: Install the rest of the configured files to their appropriate final
# locations
# install(...)
