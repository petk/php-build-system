include(CheckLibraryExists)
include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_ZIP "Enable the zip extension" OFF)

add_feature_info(
  "ext/zip"
  EXT_ZIP
  "Support for reading and writing ZIP compressed archives"
)

cmake_dependent_option(
  EXT_ZIP_SHARED
  "Build the zip extension as a shared library"
  OFF
  "EXT_ZIP;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_ZIP)
  return()
endif()

if(EXT_ZIP_SHARED)
  add_library(php_zip SHARED)
else()
  add_library(php_zip)
endif()

target_sources(
  php_zip
  PRIVATE
    php_zip.c
    zip_stream.c
)

add_dependencies(php_zip php_pcre)

find_package(libzip 1.7.1)
set_package_properties(
  libzip
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the zip extension."
)

if(NOT libzip_FOUND)
  find_package(libzip 1.3.2...1.6.999)
endif()

if(NOT libzip_FOUND)
  find_package(libzip 0.11...1.3.0)
endif()

if(libzip_VERSION VERSION_EQUAL 1.3.1 OR libzip_VERSION VERSION_EQUAL 1.7.0)
  message(
    FATAL_ERROR
    "ext/zip: libzip ${libzip_VERSION} is not supported. Try upgrading libzip"
  )
endif()

target_link_libraries(php_zip PRIVATE libzip::libzip)

# TODO: Adjust this if the libzip is a static library.
if(TODO)
  set(ZIP_STATIC 1 CACHE INTERNAL "Whether the libzip is a static library.")
  #set(LZMA_API_STATIC 1)
endif()

# TODO: When downloading and building libzip from source additional deps are
# required.

if(TARGET libzip::libzip)
  check_library_exists(
    libzip::libzip
    zip_file_set_mtime
    ""
    HAVE_SET_MTIME
  )

  if(NOT HAVE_SET_MTIME)
    message(WARNING "Libzip >= 1.0.0 needed for setting mtime")
  endif()

  check_library_exists(
    libzip::libzip
    zip_file_set_encryption
    ""
    HAVE_ENCRYPTION
  )

  if(NOT HAVE_ENCRYPTION)
    message(WARNING "Libzip >= 1.2.0 needed for encryption support")
  endif()

  check_library_exists(
    libzip::libzip
    zip_libzip_version
    ""
    HAVE_LIBZIP_VERSION
  )

  check_library_exists(
    libzip::libzip
    zip_register_progress_callback_with_state
    ""
    HAVE_PROGRESS_CALLBACK
  )

  check_library_exists(
    libzip::libzip
    zip_register_cancel_callback_with_state
    ""
    HAVE_CANCEL_CALLBACK
  )

  check_library_exists(
    libzip::libzip
    zip_compression_method_supported
    ""
    HAVE_METHOD_SUPPORTED
  )
endif()
