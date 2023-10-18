include(CheckLibraryExists)
include(CMakeDependentOption)

option(EXT_ZIP "Whether to enable the zip extension" OFF)

cmake_dependent_option(
  EXT_ZIP_SHARED
  "Whether to build the zip extension as shared object"
  OFF
  "EXT_ZIP;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_ZIP)
  return()
endif()

if(EXT_ZIP_SHARED)
  set(_type "SHARED")
endif()

add_library(php_zip ${_type}
  php_zip.c
  zip_stream.c
)

find_package(libzip 0.11 REQUIRED)

if(libzip_VERSION VERSION_EQUAL 1.3.1)
  message(FATAL_ERROR "ext/zip: libzip ${libzip_VERSION} is not supported. Try upgrading libzip")
endif()

if(libzip_VERSION VERSION_EQUAL 1.7.0)
  message(FATAL_ERROR "ext/zip: libzip ${libzip_VERSION} is not supported. Try upgrading libzip")
endif()

target_link_libraries(php_zip PRIVATE libzip::libzip)

check_library_exists(libzip::libzip zip_file_set_mtime "" HAVE_SET_MTIME)

if(NOT HAVE_SET_MTIME)
  message(WARNING "Libzip >= 1.0.0 needed for setting mtime")
endif()

check_library_exists(libzip::libzip zip_file_set_encryption "" HAVE_ENCRYPTION)

if(NOT HAVE_ENCRYPTION)
  message(WARNING "Libzip >= 1.2.0 needed for encryption support")
endif()

check_library_exists(libzip::libzip zip_libzip_version "" HAVE_LIBZIP_VERSION)

check_library_exists(libzip::libzip zip_register_progress_callback_with_state "" HAVE_PROGRESS_CALLBACK)

check_library_exists(libzip::libzip zip_register_cancel_callback_with_state "" HAVE_CANCEL_CALLBACK)

check_library_exists(libzip::libzip zip_compression_method_supported "" HAVE_METHOD_SUPPORTED)
