option(pdo_oci "Whether to enable the pdo_oci extension" ON)

if(NOT pdo_oci)
  return()
endif()
