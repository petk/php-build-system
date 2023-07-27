include(CheckIncludeFile)

option(sysvmsg "Whether to enable the sysvmsg extension" OFF)

if(sysvmsg)
  check_include_file(sys/msg.h HAVE_SYS_MSG_H)

  if(NOT HAVE_SYS_MSG_H)
    message(FATAL_ERROR "Cannot enable System V IPC support, sys/msg.h is missing")
  endif()

  string(TOLOWER ${sysvmsg} extension_lower)
  set(extension_library_type "STATIC")
  if(extension_lower STREQUAL "shared")
    set(extension_library_type "SHARED")
  endif()

  php_extension(NAME "sysvmsg" ${extension_library_type})

  add_library(ext_sysvmsg ${extension_library_type}
    sysvmsg.c
  )
endif()
