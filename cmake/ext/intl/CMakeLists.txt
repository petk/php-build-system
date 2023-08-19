option(intl "Whether to enable the intl extension" OFF)

if(NOT intl)
  return()
endif()

find_package(ICU 50.1 REQUIRED COMPONENTS io uc i18n)

string(TOLOWER ${intl} extension_lower)
set(extension_library_type "STATIC")
if(extension_lower STREQUAL "shared")
  set(extension_library_type "SHARED")
endif()

php_extension(NAME "intl" ${extension_library_type})

add_library(ext_intl ${extension_library_type}
  php_intl.c
  intl_error.c
  intl_convert.c
  collator/collator_class.c
  collator/collator_sort.c
  collator/collator_convert.c
  collator/collator_locale.c
  collator/collator_compare.c
  collator/collator_attr.c
  collator/collator_create.c
  collator/collator_is_numeric.c
  collator/collator_error.c
  common/common_error.c
  converter/converter.c
  formatter/formatter_main.c
  formatter/formatter_class.c
  formatter/formatter_attr.c
  formatter/formatter_data.c
  formatter/formatter_format.c
  formatter/formatter_parse.c
  normalizer/normalizer_class.c
  normalizer/normalizer_normalize.c
  locale/locale.c
  locale/locale_class.c
  locale/locale_methods.c
  dateformat/dateformat.c
  dateformat/dateformat_class.c
  dateformat/dateformat_attr.c
  dateformat/dateformat_data.c
  dateformat/dateformat_format.c
  dateformat/dateformat_parse.c
  msgformat/msgformat.c
  msgformat/msgformat_attr.c
  msgformat/msgformat_class.c
  msgformat/msgformat_data.c
  msgformat/msgformat_format.c
  msgformat/msgformat_parse.c
  grapheme/grapheme_string.c
  grapheme/grapheme_util.c
  resourcebundle/resourcebundle.c
  resourcebundle/resourcebundle_class.c
  resourcebundle/resourcebundle_iterator.c
  transliterator/transliterator_class.c
  transliterator/transliterator_methods.c
  uchar/uchar.c
  idn/idn.c
  spoofchecker/spoofchecker_class.c
  spoofchecker/spoofchecker_create.c
  spoofchecker/spoofchecker_main.c
)

target_link_libraries(ext_intl PRIVATE ${ICU_LIBRARIES})

target_compile_options(ext_intl PRIVATE -Wno-write-strings)

target_compile_definitions(ext_intl
  PRIVATE
    U_NO_DEFAULT_INCLUDE_UTF_HEADERS=1
    __STDC_LIMIT_MACROS
    __STDC_CONSTANT_MACROS
    __STDC_FORMAT_MACROS
    ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
)

if(ICU_VERSION VERSION_GREATER_EQUAL 60)
  target_compile_definitions(ext_intl PRIVATE U_HIDE_OBSOLETE_UTF_OLD_H=1)
endif()

target_include_directories(ext_intl PRIVATE ${CMAKE_CURRENT_SOURCE_DIR} ${ICU_INCLUDE_DIRS})

set(ext_intl_cxx_sources
  intl_convertcpp.cpp
  common/common_enum.cpp
  common/common_date.cpp
  dateformat/dateformat_format_object.cpp
  dateformat/dateformat_create.cpp
  dateformat/dateformat_attrcpp.cpp
  dateformat/dateformat_helpers.cpp
  dateformat/datepatterngenerator_class.cpp
  dateformat/datepatterngenerator_methods.cpp
  msgformat/msgformat_helpers.cpp
  timezone/timezone_class.cpp
  timezone/timezone_methods.cpp
  calendar/calendar_class.cpp
  calendar/calendar_methods.cpp
  calendar/gregoriancalendar_methods.cpp
  breakiterator/breakiterator_class.cpp
  breakiterator/breakiterator_iterators.cpp
  breakiterator/breakiterator_methods.cpp
  breakiterator/rulebasedbreakiterator_methods.cpp
  breakiterator/codepointiterator_internal.cpp
  breakiterator/codepointiterator_methods.cpp
)

add_library(ext_intl_cxx STATIC ${ext_intl_cxx_sources})

set_target_properties(ext_intl_cxx PROPERTIES LANGUAGE CXX CXX_STANDARD 11)

target_link_libraries(ext_intl_cxx PRIVATE ${ICU_LIBRARIES})

target_compile_definitions(ext_intl_cxx
  PRIVATE
    __STDC_LIMIT_MACROS
    __STDC_CONSTANT_MACROS
    __STDC_FORMAT_MACROS
    ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
    U_NO_DEFAULT_INCLUDE_UTF_HEADERS=1
    UNISTR_FROM_CHAR_EXPLICIT=explicit
    UNISTR_FROM_STRING_EXPLICIT=explicit
)

if(ICU_VERSION VERSION_GREATER_EQUAL 60)
  target_compile_definitions(ext_intl_cxx PRIVATE U_HIDE_OBSOLETE_UTF_OLD_H=1)
endif()

target_compile_options(ext_intl_cxx PRIVATE -Wno-write-strings)

target_include_directories(ext_intl_cxx PRIVATE ${CMAKE_CURRENT_SOURCE_DIR} ${ICU_INCLUDE_DIRS})

target_link_libraries(ext_intl PRIVATE ext_intl_cxx)

target_link_libraries(ext_intl PRIVATE Zend)
