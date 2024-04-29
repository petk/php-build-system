include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_FTP "Enable the ftp extension" OFF)

add_feature_info(
  "ext/ftp"
  EXT_FTP
  "File Transfer Protocol (FTP) support."
)

cmake_dependent_option(
  EXT_FTP_SHARED
  "Build the ftp extension as a shared library"
  OFF
  "EXT_FTP;NOT BUILD_SHARED_LIBS"
  OFF
)

cmake_dependent_option(
  EXT_FTP_SSL
  "Explicitly enable SSL support in ext/ftp when not building with ext/openssl.\
  If ext/openssl is enabled at the configuration phase, SSL in ext/ftp will be\
  enabled implicitly and this option can be skipped."
  OFF
  "EXT_FTP"
  OFF
)

if(NOT EXT_FTP)
  return()
endif()

if(EXT_FTP_SHARED)
  add_library(php_ftp SHARED)
else()
  add_library(php_ftp)
endif()

target_sources(
  php_ftp
  PRIVATE
    ftp.c
    php_ftp.c
)

# A deferred configuration, so it is executed after the ext/openssl to have the
# EXT_OPENSSL variable available.
function(php_ftp_post_configuration)
  if(EXT_FTP_SSL OR EXT_OPENSSL)
    find_package(OpenSSL ${PHP_OPENSSL_MIN_VERSION})
    set_package_properties(
      OpenSSL
      PROPERTIES
        TYPE REQUIRED
        PURPOSE "Necessary to enable the ftp extension."
    )

    target_link_libraries(php_ftp PRIVATE OpenSSL::SSL)

    set(HAVE_FTP_SSL 1 CACHE INTERNAL "Whether FTP over SSL is enabled")
  endif()

  add_feature_info(
    "ext/ftp SSL"
    HAVE_FTP_SSL
    "FTP SSL support"
  )
endfunction()

# Run at the end of the configuration.
cmake_language(
  DEFER
    DIRECTORY ${PHP_SOURCE_DIR}
  CALL php_ftp_post_configuration
)
