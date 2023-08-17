option(ftp "Whether to enable the ftp extension" OFF)

option(ftp_ssl "Whether to explicitly enable FTP SSL support when not using ext/openssl" OFF)

if(NOT ftp)
  return()
endif()

string(TOLOWER ${ftp} extension_lower)
set(extension_library_type "STATIC")
if(extension_lower STREQUAL "shared")
  set(extension_library_type "SHARED")
endif()

php_extension(NAME ftp ${extension_library_type})

add_library(ext_ftp ${extension_library_type}
  php_ftp.c
  ftp.c
)

if(ftp_ssl OR openssl)
  find_package(OpenSSL 1.0.2)

  if(OPENSSL_FOUND)
    set(HAVE_FTP_SSL 1 CACHE INTERNAL "Whether FTP over SSL is supported")
    target_link_libraries(ext_ftp PRIVATE ${OPENSSL_LIBRARIES})
    target_include_directories(ext_ftp PRIVATE ${OPENSSL_INCLUDE_DIRS})
  endif()
endif()
