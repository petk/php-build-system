# PHP/FeatureSummary

See: [FeatureSummary.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/PHP/FeatureSummary.cmake)

Print summary of enabled/disabled features.

This is built on top of the CMake's `FeatureSummary` module. It sorts feature
summary alphabetically and categorizes enabled features into SAPIs, extensions,
and other global PHP features. Common misconfiguration issues are summarized
together with missing required system packages.

https://cmake.org/cmake/help/latest/module/FeatureSummary.html
