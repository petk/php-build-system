# Replace prefixes PHP_ with DTRACE_.
file(READ "${CMAKE_SOURCE_DIR}/Zend/zend_dtrace_gen.h" file_contents)
string(REPLACE "PHP_" "DTRACE_" file_contents ${file_contents})
file(WRITE "${CMAKE_SOURCE_DIR}/Zend/zend_dtrace_gen.h" "${file_contents}")
