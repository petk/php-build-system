<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/FeatureSummary.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/FeatureSummary.cmake)

# PHP/FeatureSummary

Print summary of enabled/disabled features.

This is built on top of the CMake's `FeatureSummary` module. It sorts feature
summary alphabetically and categorizes enabled features into SAPIs, extensions,
and other global PHP features. Common misconfiguration issues are summarized
together with missing required system packages.

https://cmake.org/cmake/help/latest/module/FeatureSummary.html

## Basic usage

```cmake
# CMakeLists.txt
include(PHP/FeatureSummary)
```
