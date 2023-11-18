include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_PEAR "Whether to install PEAR" OFF)

add_feature_info("PEAR" PHP_PEAR
  "PEAR (PHP Extension and Application Repository) package manager"
)

cmake_dependent_option(
  PHP_PEAR_DIR
  "Install PEAR in DIR (PREFIX/lib/php)"
  OFF
  "EXT_BCMATH;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT PHP_PEAR)
  return()
endif()

message(DEPRECATION "The PHP_PEAR option is deprecated.")

# Check PEAR dependencies.
if(NOT EXT_XML)
  message(
    FATAL_ERROR
    "PEAR requires the xml extension to be enabled. Set EXT_XML to 'ON'.")
endif()
