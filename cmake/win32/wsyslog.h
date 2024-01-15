//
//  Values are 32 bit values laid out as follows:
//
//   3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
//   1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
//  +---+-+-+-----------------------+-------------------------------+
//  |Sev|C|R|     Facility          |               Code            |
//  +---+-+-+-----------------------+-------------------------------+
//
//  where
//
//      Sev - is the severity code
//
//          00 - Success
//          01 - Informational
//          10 - Warning
//          11 - Error
//
//      C - is the Customer code flag
//
//      R - is a reserved bit
//
//      Facility - is the facility code
//
//      Code - is the facility's status code
//
//
// Define the facility codes
//


//
// Define the severity codes
//


//
// MessageId: PHP_SYSLOG_SUCCESS_TYPE
//
// MessageText:
//
// %1 %2
//
#define PHP_SYSLOG_SUCCESS_TYPE          0x00000001L

//
// MessageId: PHP_SYSLOG_INFO_TYPE
//
// MessageText:
//
// %1 %2
//
#define PHP_SYSLOG_INFO_TYPE             0x40000002L

//
// MessageId: PHP_SYSLOG_WARNING_TYPE
//
// MessageText:
//
// %1 %2
//
#define PHP_SYSLOG_WARNING_TYPE          0x80000003L

//
// MessageId: PHP_SYSLOG_ERROR_TYPE
//
// MessageText:
//
// %1 %2
//
#define PHP_SYSLOG_ERROR_TYPE            0xC0000004L
