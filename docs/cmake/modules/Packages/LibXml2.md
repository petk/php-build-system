<!-- This is auto-generated file. -->
# Packages/LibXml2

* Module source code: [LibXml2.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/Packages/LibXml2.cmake)

Wrapper for finding the `libxml2` library.

Module first tries to find the `libxml2` library on the system. If not
successful it tries to download it from the upstream source with `FetchContent`
module and build it together with the PHP build.

See: https://cmake.org/cmake/help/latest/module/FindLibXml2.html

The `FetchContent` CMake module does things differently compared to the
`find_package()` flow:
* By default, it uses `QUIET` in its `find_package()` call when calling the
  `FetchContent_MakeAvailable()`;
* When using `FeatureSummary`, dependencies must be moved manually to
  `PACKAGES_FOUND` from the `PACKAGES_NOT_FOUND` global property;

TODO: Improve this. This is for now only initial `FetchContent` integration for
testing purposes and will be changed in the future.

## Basic usage

```cmake
# CMakeLists.txt
include(Packages/LibXml2)
```
