include(FetchContent)
#set(FETCHCONTENT_TRY_FIND_PACKAGE_MODE ALWAYS)
set(RE2C_BUILD_RE2GO OFF CACHE INTERNAL "")
set(RE2C_BUILD_RE2RUST OFF CACHE INTERNAL "")

FetchContent_Declare(
  RE2C
  GIT_REPOSITORY https://github.com/skvadrik/re2c
  GIT_TAG 3.1
  #OVERRIDE_FIND_PACKAGE
  #SYSTEM
  FIND_PACKAGE_ARGS
)

FetchContent_MakeAvailable(RE2C)

add_executable(PHP::re2c ALIAS re2c)

get_target_property(_re2c_executable_path re2c RUNTIME_OUTPUT_DIRECTORY)
get_target_property(_re2c_executable_name re2c RUNTIME_OUTPUT_NAME)
set(RE2C_EXECUTABLE re2c PARENT_SCOPE)
set(RE2C_VERSION 3.1 PARENT_SCOPE)

message(STATUS "RE2C_EXECUTABLE=${RE2C_EXECUTABLE}")
