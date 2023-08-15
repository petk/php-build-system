# Patch Zend/zend_language_parser.h.
message(STATUS "Patching Zend/zend_language_parser.h")
file(READ "${CMAKE_CURRENT_SOURCE_DIR}/zend_language_parser.h" file_contents)
string(REPLACE "int zendparse" "ZEND_API int zendparse" file_contents "${file_contents}")
file(WRITE "${CMAKE_CURRENT_SOURCE_DIR}/zend_language_parser.h" "${file_contents}")

# Patch Zend/zend_language_parser.c.
message(STATUS "Patching Zend/zend_language_parser.c")
file(READ "${CMAKE_CURRENT_SOURCE_DIR}/zend_language_parser.c" file_contents)
string(REPLACE "int zendparse" "ZEND_API int zendparse" file_contents "${file_contents}")
file(WRITE "${CMAKE_CURRENT_SOURCE_DIR}/zend_language_parser.c" "${file_contents}")
