include(CMakeDependentOption)

option(fpm "Whether to use the PHP FPM SAPI module" OFF)

cmake_dependent_option(fpm_user "Set the user for php-fpm to run as. (default: nobody)" "nobody" "fpm" "")
cmake_dependent_option(fpm_group "Set the group for php-fpm to run as. For a system user, this should
usually be set to match the fpm username (default: nobody)" "nobody" "fpm" "")
cmake_dependent_option(fpm_systemd "Whether to activate systemd integration" OFF "fpm" OFF)
cmake_dependent_option(fpm_acl "Use POSIX Access Control Lists" OFF "fpm" OFF)
cmake_dependent_option(fpm_apparmor "Support AppArmor confinement through libapparmor" OFF "fpm" OFF)
cmake_dependent_option(fpm_selinux "Support SELinux policy library" OFF "fpm" OFF)

if(NOT fpm)
  return()
endif()
