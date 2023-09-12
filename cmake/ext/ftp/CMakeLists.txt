include(CMakeDependentOption)

option(EXT_FTP "Whether to enable the FTP extension" OFF)

cmake_dependent_option(EXT_FTP_SHARED "Whether to build the FTP extension as shared object" OFF "EXT_FTP;NOT BUILD_SHARED_LIBS" OFF)

cmake_dependent_option(EXT_FTP_SSL "Whether to explicitly enable FTP SSL support when not using ext/openssl" OFF "EXT_FTP" OFF)

if(NOT EXT_FTP)
  return()
endif()

if(EXT_FTP_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME ftp ${_library_type})

add_library(ext_ftp ${_library_type}
  php_ftp.c
  ftp.c
)

if(EXT_FTP_SSL OR EXT_OPENSSL)
  find_package(OpenSSL 1.0.2)

  # TODO: Is OpenSSL package required in this case?
  if(OPENSSL_FOUND)
    set(HAVE_FTP_SSL 1 CACHE INTERNAL "Whether FTP over SSL is supported")

    if(OPENSSL_LIBRARIES)
      target_link_libraries(ext_ftp PRIVATE ${OPENSSL_LIBRARIES})
    endif()

    if(OPENSSL_INCLUDE_DIRS)
      target_include_directories(ext_ftp PRIVATE ${OPENSSL_INCLUDE_DIRS})
    endif()
  endif()
endif()
