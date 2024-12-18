<!-- This is auto-generated file. -->
* Source code: [sapi/fpm/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/sapi/fpm/CMakeLists.txt)

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
