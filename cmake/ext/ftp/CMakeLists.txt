include(CMakeDependentOption)

option(EXT_FTP "Whether to enable the FTP extension" OFF)

cmake_dependent_option(EXT_FTP_SHARED "Whether to build the FTP extension as shared object" OFF "EXT_FTP;NOT BUILD_SHARED_LIBS" OFF)

# TODO: Check if a single option should set ext/ftp and ext/mysqlnd. Sync this
# with Autoconf's --with-openssl-dir option.
cmake_dependent_option(EXT_FTP_SSL "Whether to explicitly enable FTP SSL support when not using ext/openssl" OFF "EXT_FTP" OFF)

if(NOT EXT_FTP)
  return()
endif()

if(EXT_FTP_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "ftp" ${_library_type})

add_library(ftp ${_library_type}
  php_ftp.c
  ftp.c
)

if(EXT_FTP_SSL OR EXT_OPENSSL)
  # TODO: Can OpenSSL be retrieved differently (from one place) here?
  find_package(OpenSSL 1.0.2 REQUIRED)

  if(TARGET OpenSSL::SSL)
    target_link_libraries(ftp PRIVATE OpenSSL::SSL)
  endif()

  set(HAVE_FTP_SSL 1 CACHE INTERNAL "Whether FTP over SSL is supported")
endif()
