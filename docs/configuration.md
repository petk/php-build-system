# PHP build configuration

## PHP configuration

* `CMAKE_SKIP_RPATH=OFF|ON`

  Default: `OFF`

  Disable or enable runtime library search paths (rpath) in build and installed
  executables. Controls additional runtime library search paths (runpaths). In
  `configure` there is on/off, in CMake can be fine tuned for the build binaries
  and/or installed binaries. These are passed in form of
  `-Wl,-rpath,/additional/path/to/library` at build time.

  See the RUNPATH in the executable:

  ```sh
  objdump -x ./php-src/sapi/cli/php | grep 'R.*PATH'
  ```

* `CMAKE_SKIP_BUILD_RPATH=OFF|ON`

  Default: `OFF`

  Disable runtime library search paths (rpath) in build executables.

* `CMAKE_SKIP_INSTALL_RPATH=OFF|ON`

  Default: `OFF`

  Disable runtime library search paths (rpath) in installed executables.

## Configure and CMake configuration options

A list of configuration options and their CMake alternatives.

<table>
  <thead>
    <tr>
      <th>configure</th>
      <th>CMake</th>
      <th>Notes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td colspan=3><strong>PHP specific configuration</strong></td>
    </tr>
    <tr>
      <td>--enable-rpath</td>
      <td>CMAKE_SKIP_RPATH=OFF, CMAKE_SKIP_INSTALL_RPATH=OFF, CMAKE_SKIP_BUILD_RPATH=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-rpath</td>
      <td>CMAKE_SKIP_RPATH=ON or CMAKE_SKIP_INSTALL_RPATH=ON and/or CMAKE_SKIP_BUILD_RPATH=ON</td>
      <td></td>
    </tr>
  </tbody>
</table>
