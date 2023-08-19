include(CheckLibraryExists)

option(zip "Whether to enable the zip extension" ON)

if(NOT zip)
  return()
endif()

find_package(ZIP 0.11 REQUIRED)

if(ZIP_VERSION VERSION_EQUAL 1.3.1)
  message(FATAL_ERROR "ext/zip: libzip ${ZIP_VERSION} is not supported. Try upgrading libzip")
endif()

if(ZIP_VERSION VERSION_EQUAL 1.7.0)
  message(FATAL_ERROR "ext/zip: libzip ${ZIP_VERSION} is not supported. Try upgrading libzip")
endif()

string(TOLOWER ${zip} extension_lower)
set(extension_library_type "STATIC")
if(extension_lower STREQUAL "shared")
  set(extension_library_type "SHARED")
endif()

php_extension(NAME "zip" ${extension_library_type})

add_library(ext_zip ${extension_library_type}
  php_zip.c
  zip_stream.c
)

target_link_libraries(ext_zip PRIVATE ${ZIP_LIBRARIES})

if(ZIP_INCLUDE_DIRS)
  target_include_directories(ext_zip PRIVATE ${ZIP_INCLUDE_DIRS})
endif()

check_library_exists(zip zip_file_set_mtime "" HAVE_SET_MTIME)

if(NOT HAVE_SET_MTIME)
  message(WARNING "Libzip >= 1.0.0 needed for setting mtime")
endif()

check_library_exists(zip zip_file_set_encryption "" HAVE_ENCRYPTION)

if(NOT HAVE_ENCRYPTION)
  message(WARNING "Libzip >= 1.2.0 needed for encryption support")
endif()

check_library_exists(zip zip_libzip_version "" HAVE_LIBZIP_VERSION)

check_library_exists(zip zip_register_progress_callback_with_state "" HAVE_PROGRESS_CALLBACK)

check_library_exists(zip zip_register_cancel_callback_with_state "" HAVE_CANCEL_CALLBACK)

check_library_exists(zip zip_compression_method_supported "" HAVE_METHOD_SUPPORTED)
