# CMake defaults that are usually set before calling the project().

# Set the module path to include the directory containing custom modules.
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/modules/")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/")

# To enable shared extensions, always build with -fPIC.
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
