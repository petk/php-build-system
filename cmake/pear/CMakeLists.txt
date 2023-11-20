include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_PEAR "Whether to install PEAR" OFF)

add_feature_info("PEAR" PHP_PEAR
  "PEAR (PHP Extension and Application Repository) package manager"
)

if(PHP_PEAR)
  set(
    PHP_PEAR_DIR ""
    CACHE FILEPATH
    "Install PEAR in DIR (PREFIX/lib/php)"
  )
  # Change from INTERNAL type to show variable on consecutive configuration run.
  set_property(CACHE PHP_PEAR_DIR PROPERTY TYPE FILEPATH)
elseif(DEFINED PHP_PEAR_DIR)
  # Hide variable.
  set_property(CACHE PHP_PEAR_DIR PROPERTY TYPE INTERNAL)
endif()

# TODO: Should 'OR NOT SAPI_CLI' be added here also when not using CLI SAPI?
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
