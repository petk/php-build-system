include(CMakeDependentOption)

option(SAPI_FPM "Whether to use the PHP FPM SAPI module" OFF)

cmake_dependent_option(SAPI_FPM_USER "Set the user for php-fpm to run as. (default: nobody)" "nobody" "SAPI_FPM" "")
cmake_dependent_option(SAPI_FPM_GROUP "Set the group for php-fpm to run as. For a system user, this should
usually be set to match the fpm username (default: nobody)" "nobody" "SAPI_FPM" "")
cmake_dependent_option(SAPI_FPM_SYSTEMD "Whether to activate systemd integration" OFF "SAPI_FPM" OFF)
cmake_dependent_option(SAPI_FPM_ACL "Use POSIX Access Control Lists" OFF "SAPI_FPM" OFF)
cmake_dependent_option(SAPI_FPM_APPARMOR "Support AppArmor confinement through libapparmor" OFF "SAPI_FPM" OFF)
cmake_dependent_option(SAPI_FPM_SELINUX "Support SELinux policy library" OFF "SAPI_FPM" OFF)

if(NOT SAPI_FPM)
  return()
endif()

#install(TARGETS fpm DESTINATION ${CMAKE_INSTALL_BINDIR})

# Man documentation.
configure_file(php-fpm.8.in php-fpm.8 @ONLY)

install(
  FILES
    php-fpm.8
  DESTINATION ${CMAKE_INSTALL_MANDIR}/man8
)
