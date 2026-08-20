<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindWebP.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindWebP.cmake)

# FindWebP

Finds the libwebp library:

```cmake
find_package(WebP [<version>] [COMPONENTS <components>...] [...])
```

## Components

This module supports optional components which can be specified using the
`find_package()` command:

```cmake
find_package(
  WebP
  [COMPONENTS <components>...]
  [OPTIONAL_COMPONENTS <components>...]
  [...]
)
```

Supported components include:

* `webp` - Finds the main WebP library.
* `webpdecoder` - Finds the WebP decoder library.
* `webpdemux` - Finds the WebP Demux library.
* `libwebpmux` - Finds the WebP Mux library. Named after the upstream target
  name from CMake config files.

If no components are specified, by default, the `webp` is searched as required
component.

## Imported targets

This module provides the following imported targets:

* `WebP::webp` - Target encapsulating the Webp main webp library, if `webp`
  component was found.
* `WebP::webpdecoder` - Target encapsulating the webpdecoder library, if
  `webpdecoder` component was found.
* `WebP::webpdemux` - Target encapsulating the webpdemux library, if
  `webpdemux` component was found.
* `WebP::libwebpmux` - Target encapsulating the webpmux library, if `libwebpmux`
  component was found.

## Result variables

This module defines the following variables:

* `WebP_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `WebP_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `WebP_<component>_INCLUDE_DIR` - Directory containing package component
  library headers.
* `WebP_<component>_LIBRARY` - The path to the package component library.

## Examples

## Example: Basic usage

```cmake
# CMakeLists.txt
find_package(WebP)
target_link_libraries(example PRIVATE WebP::webp)
```

## Example: Finding WebP components

```cmake
# CMakeLists.txt
find_package(WebP COMPONENTS webp webpdemux libwebpmux)
target_link_libraries(
  example
  PRIVATE WebP::webp WebP::webpdemux WebP::libwebpmux
)
```

## Customizing search locations

To customize where to look for the WebP package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `WEBP_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/WebP;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DWEBP_ROOT=/opt/WebP \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
