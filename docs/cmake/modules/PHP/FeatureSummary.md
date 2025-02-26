<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/FeatureSummary.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/FeatureSummary.cmake)

# PHP/FeatureSummary

Print summary of enabled/disabled features.

This is built on top of the CMake's `FeatureSummary` module. It sorts feature
summary alphabetically and categorizes enabled features into SAPIs, extensions,
and other global PHP features. Common misconfiguration issues are summarized
together with missing required system packages.

See also: https://cmake.org/cmake/help/latest/module/FeatureSummary.html

## Functions

Output PHP configuration summary:

```cmake
php_feature_summary()
```

## Usage

```cmake
# CMakeLists.txt

# Include module and output configuration summary
include(PHP/FeatureSummary)
php_feature_summary()
```
