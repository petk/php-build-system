# Conditionally set a variable to its name or undefined, for forwarding options.
macro(set_if target condition)
    if(${condition})
        set(${target} "${target}")
    else()
        set(${target})
    endif()
endmacro()

# Recursively traverse LINK_LIBRARIES to find all link dependencies.
# Options:
#   NO_STATIC - prune static libraries
#   NO_SYSTEM - skip SYSTEM targets (in >=3.25)
#       ^ REQUIRED if you want to install() the result, due to non-existent IMPORTED targets
# Caveats:
#   Non-targets in LINK_LIBRARIES like "m" (as in "libm") are ignored.
#   ALIAS target names are resolved.
function(get_all_dependencies target output_list)
    # Check if the NO_STATIC or NO_SYSTEM flag is provided
    set(options NO_STATIC NO_SYSTEM)
    set(oneValueArgs)
    set(multiValueArgs)
    cmake_parse_arguments(PARSE_ARGV 2 ARG "${options}" "${oneValueArgs}" "${multiValueArgs}")
    set_if(NO_STATIC ARG_NO_STATIC)
    set_if(NO_SYSTEM ARG_NO_SYSTEM)

    # Get dependencies of the target
    get_target_property(current_deps ${target} LINK_LIBRARIES)

    if(NOT current_deps)
        set(current_deps "") # if no dependencies, replace "current_deps-NOTFOUND" with empty list
    endif()

    # Remove entries between ::@(directory-id) and ::@
    # Such entries are added by target_link_libraries() calls outside the target's directory
    set(filtered_deps "")
    set(in_special_block FALSE)
    foreach(dep IN LISTS current_deps)
        if("${dep}" MATCHES "^::@\\(.*\\)$")
            set(in_special_block TRUE)  # Latch on
        elseif("${dep}" STREQUAL "::@")
            set(in_special_block FALSE)  # Latch off
        elseif(NOT in_special_block)
            if(TARGET ${dep})  # Exclude non-targets like m (= libm)
                # Exclude SYSTEM targets (prevents  "install TARGETS given target "Perl" which does not exist")
                get_target_property(_is_system ${dep} SYSTEM)
                if(NOT _is_system OR NOT NO_SYSTEM)
                    # Resolve ALIAS targets (CMake issue #20979)
                    get_target_property(_aliased_dep ${dep} ALIASED_TARGET)
                    if(_aliased_dep)
                        list(APPEND filtered_deps ${_aliased_dep})
                    else()
                        list(APPEND filtered_deps ${dep})
                    endif()
                else()
                    message(VERBOSE "get_all_dependencies ignoring ${target} -> ${dep} (system)")
                endif()
            else()
                message(VERBOSE "get_all_dependencies ignoring ${target} -> ${dep} (not a target)")
            endif()
        else()
            message(VERBOSE "get_all_dependencies ignoring ${target} -> ${dep} (added externally)")
        endif()
    endforeach()

    set(all_deps ${filtered_deps})

    foreach(dep IN LISTS filtered_deps)
        # Avoid infinite recursion if the target has a cyclic dependency
        if(NOT "${dep}" IN_LIST ${output_list})
            get_all_dependencies(${dep} dep_child_deps ${NO_STATIC} ${NO_SYSTEM})
            list(APPEND all_deps ${dep_child_deps})
        endif()
    endforeach()

    # Remove duplicates
    list(REMOVE_DUPLICATES all_deps)

    # Remove static libraries if the NO_STATIC flag is set
    if(ARG_NO_STATIC)
        foreach(dep IN LISTS all_deps)
            get_target_property(dep_type ${dep} TYPE)
            if(dep_type STREQUAL "STATIC_LIBRARY")
                message(VERBOSE "get_all_dependencies pruning ${target} -> ${dep} (static)")
                list(REMOVE_ITEM all_deps ${dep})
            endif()
        endforeach()
    endif()

    # Set the result in parent scope
    set(${output_list} "${all_deps}" PARENT_SCOPE)
endfunction()
