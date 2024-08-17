#[=============================================================================[
CMake tokenizer.

]=============================================================================]#

function(tokenize filename out_namespace)
  set(tokens_count 0)
  set(line 1)
  set(column 1)

  macro(emit_token_and_advance type)
    #[[ For development
    if(NOT DEFINED text)
      message(FATAL_ERROR "(${line},${column}) Missing text variable.")
    endif()
    string(LENGTH "${text}" text_length)
    if(text_length LESS 0)
      message(FATAL_ERROR "No text?")
    endif()
    print_token("${type}" "${text}" "${line}" "${column}")
    #]]

    math(EXPR tokens_count "${tokens_count} + 1")

    set(${out_namespace}_${tokens_count}_text ${text} PARENT_SCOPE)
    set(${out_namespace}_${tokens_count}_type ${type} PARENT_SCOPE)

    set(${out_namespace}_${tokens_count}_line ${line} PARENT_SCOPE)
    set(${out_namespace}_${tokens_count}_column ${column} PARENT_SCOPE)
    string(LENGTH "${text}" length)

    string(FIND "${text}" "\n" last_newline_index REVERSE)
    if(last_newline_index EQUAL -1)
      math(EXPR column "${column} + ${length}")
    else()
      math(EXPR column "${length} - ${last_newline_index}")

      set(newline_count 0)
      set(text_remainder "${text}")
      while(NOT last_newline_index EQUAL -1)
        math(EXPR newline_count "${newline_count} + 1")
        string(SUBSTRING "${text_remainder}" 0 ${last_newline_index} text_remainder)
        string(FIND "${text_remainder}" "\n" last_newline_index REVERSE)
      endwhile()
      math(EXPR line "${line} + ${newline_count}")
    endif()

    string(SUBSTRING "${content}" ${length} -1 content)

    #[[ For development
    unset(text)
    #]]
  endmacro()

  macro(consume_space)
    set(text "${CMAKE_MATCH_0}")
    emit_token_and_advance(Token_Space)
  endmacro()

  macro(consume_identifier)
    # If "${CMAKE_MATCH_0}" expands to "PARENT_SCOPE", set(text "PARENT_SCOPE") would
    # unset "text" in the parent scope, instead of setting "text" in this scope.
    string(CONCAT text "${CMAKE_MATCH_0}")
    emit_token_and_advance(Token_Identifier)
  endmacro()

  macro(consume_lparen)
    set(text "(")
    emit_token_and_advance(Token_LeftParen)
  endmacro()

  macro(consume_rparen)
    if(NOT content MATCHES "^\\)")
      message(FATAL_ERROR "(${line},${column}) Expected ')'.")
    endif()
    set(text ")")
    emit_token_and_advance(Token_RightParen)
  endmacro()

  macro(consume_bracket)
    set(bracket_open "${CMAKE_MATCH_0}")
    string(LENGTH "${bracket_open}" bracket_open_len)
    string(SUBSTRING "${content}" ${bracket_open_len} -1 bracket_remainder)
    string(REGEX REPLACE "[^=]" "" equal_signs "${bracket_open}")
    set(bracket_close "]${equal_signs}]")
    string(FIND "${bracket_remainder}" "${bracket_close}" bracket_close_pos)
    if(bracket_close_pos EQUAL -1)
      message(FATAL_ERROR "(${line},${column}) Unterminated bracket.")
    endif()
    string(SUBSTRING "${bracket_remainder}" 0 ${bracket_close_pos} bracket_content)
    set(text "${bracket_open}${bracket_content}${bracket_close}")
    if(text MATCHES "^#")
      emit_token_and_advance(Token_BracketComment)
    else()
      emit_token_and_advance(Token_BracketArgument)
    endif()
  endmacro()

  macro(consume_quoted_argument)
    if(NOT content MATCHES "^\"([\\].|[^\"\\])*\"")
      message(FATAL_ERROR "(${line},${column}) Expected quoted argument.")
    endif()
    set(text "${CMAKE_MATCH_0}")
    emit_token_and_advance(Token_QuotedArgument)
  endmacro()

  macro(consume_unquoted_argument)
    # If "${CMAKE_MATCH_0}" expands to "PARENT_SCOPE", set(text "PARENT_SCOPE") would
    # unset "text" in the parent scope, instead of setting "text" in this scope.
    string(CONCAT text "${CMAKE_MATCH_0}")
    emit_token_and_advance(Token_UnquotedArgument)
  endmacro()

  macro(consume_line_comment)
    set(text "${CMAKE_MATCH_0}")
    emit_token_and_advance(Token_LineComment)
  endmacro()

  macro(consume_newline)
    set(text "\n")
    emit_token_and_advance(Token_Newline)
  endmacro()

  macro(consume_arguments)
    while(1)
      if(content MATCHES "^\\(")
        consume_lparen()
        consume_arguments()
        consume_rparen()
      elseif(content MATCHES "^[ \t]+")
        consume_space()
      elseif(content MATCHES "^\n")
        consume_newline()
      elseif(content MATCHES "^#")
        if(content MATCHES "^#\\[=*\\[")
          consume_bracket()
        else()
          if(NOT content MATCHES "^#[^\n]*")
            message(FATAL_ERROR "(${line},${column}) Expected line comment.")
          endif()
          consume_line_comment()
        endif()
      elseif(content MATCHES "^\\[=*\\[")
        consume_bracket()
      elseif(content MATCHES "^\"")
        consume_quoted_argument()
      elseif(content MATCHES "^(\\.|[^\n \t()#\"\\])+")
        consume_unquoted_argument()
      else()
        break()
      endif()
    endwhile()
  endmacro()

  file(READ "${filename}" content)

  while(NOT content STREQUAL "")
    if(content MATCHES "^[ \t]+")
      consume_space()
    endif()
    if(content MATCHES "^[A-Za-z_][A-Za-z0-9_]*")
      consume_identifier()
      if(content MATCHES "^[ \t]+")
        consume_space()
      endif()
      if(NOT content MATCHES "^\\(")
        message(FATAL_ERROR "(${line},${column}) Expected '('.")
      endif()
      consume_lparen()
      consume_arguments()
      consume_rparen()
    endif()
    while(1)
      if(content MATCHES "^#\\[=*\\[")
        consume_bracket()
      elseif(content MATCHES "^[ \t]+")
        consume_space()
      else()
        break()
      endif()
    endwhile()
    if(content MATCHES "^#[^\n]*")
      consume_line_comment()
    endif()
    if(NOT content STREQUAL "")
      if(NOT content MATCHES "^\n")
        message(FATAL_ERROR "(${line},${column}) Expected newline.")
      endif()
      consume_newline()
    endif()
  endwhile()

  set(${out_namespace}_tokens_count ${tokens_count} PARENT_SCOPE)
endfunction()

function(print_token type text line column)
  if(column LESS 10)
    set(column "0${column}")
  endif()

  string(REGEX REPLACE "\n" "\\\\n" text "${text}")

  string(LENGTH "${type}" type_len)
  set(padded_type "${type}")
  foreach(i RANGE ${type_len} 24)
    string(APPEND padded_type " ")
  endforeach()

  message(STATUS "${line},${column}:  ${padded_type}'${text}'")
endfunction()

function(print_tokens namespace)
  foreach(i RANGE 1 ${${namespace}_tokens_count})
    print_token(
      "${${namespace}_${i}_type}"
      "${${namespace}_${i}_text}"
      "${${namespace}_${i}_line}"
      "${${namespace}_${i}_column}"
    )
  endforeach()
endfunction()

function(main)
  if(NOT DEFINED CMAKE_ARGV3)
    message(FATAL_ERROR "usage: cmake -P tokenize.cmake filename")
  endif()
  set(filename "${CMAKE_ARGV3}")

  tokenize("${filename}" my_tokens)

  print_tokens(my_tokens)
endfunction()

if(CMAKE_SCRIPT_MODE_FILE STREQUAL CMAKE_CURRENT_LIST_FILE)
  main()
endif()
