option(cgi "Whether to use the PHP CGI SAPI module" ON)

if(NOT cgi)
  return()
endif()
