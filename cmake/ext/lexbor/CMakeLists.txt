#[=============================================================================[
# The lexbor extension

Configure the `lexbor` extension.

This extension provides support for Lexbor library.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

project(
  PHP_EXT_LEXBOR
  LANGUAGES C
)

include(FeatureSummary)

add_feature_info(
  "ext/lexbor"
  TRUE
  "support for Lexbor library"
)

add_library(php_ext_lexbor OBJECT)

file(
  GLOB_RECURSE lexbor_headers
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}/lexbor/*.h
)

target_sources(
  php_ext_lexbor
  PRIVATE
  php_lexbor.c
    lexbor/core/array_obj.c
    lexbor/core/array.c
    lexbor/core/avl.c
    lexbor/core/bst.c
    lexbor/core/conv.c
    lexbor/core/diyfp.c
    lexbor/core/dobject.c
    lexbor/core/dtoa.c
    lexbor/core/hash.c
    lexbor/core/mem.c
    lexbor/core/mraw.c
    lexbor/core/plog.c
    lexbor/core/print.c
    lexbor/core/serialize.c
    lexbor/core/shs.c
    lexbor/core/str.c
    lexbor/core/strtod.c
    lexbor/css/css.c
    lexbor/css/log.c
    lexbor/css/parser.c
    lexbor/css/selectors/pseudo_state.c
    lexbor/css/selectors/pseudo.c
    lexbor/css/selectors/selector.c
    lexbor/css/selectors/selectors.c
    lexbor/css/selectors/state.c
    lexbor/css/state.c
    lexbor/css/syntax/anb.c
    lexbor/css/syntax/parser.c
    lexbor/css/syntax/state.c
    lexbor/css/syntax/syntax.c
    lexbor/css/syntax/token.c
    lexbor/css/syntax/tokenizer.c
    lexbor/css/syntax/tokenizer/error.c
    lexbor/dom/interface.c
    lexbor/dom/interfaces/attr.c
    lexbor/dom/interfaces/cdata_section.c
    lexbor/dom/interfaces/character_data.c
    lexbor/dom/interfaces/comment.c
    lexbor/dom/interfaces/document_fragment.c
    lexbor/dom/interfaces/document_type.c
    lexbor/dom/interfaces/document.c
    lexbor/dom/interfaces/element.c
    lexbor/dom/interfaces/node.c
    lexbor/dom/interfaces/processing_instruction.c
    lexbor/dom/interfaces/shadow_root.c
    lexbor/dom/interfaces/text.c
    lexbor/encoding/decode.c
    lexbor/encoding/encode.c
    lexbor/encoding/encoding.c
    lexbor/encoding/multi.c
    lexbor/encoding/range.c
    lexbor/encoding/res.c
    lexbor/encoding/single.c
    lexbor/html/encoding.c
    lexbor/html/interface.c
    lexbor/html/interfaces/anchor_element.c
    lexbor/html/interfaces/area_element.c
    lexbor/html/interfaces/audio_element.c
    lexbor/html/interfaces/base_element.c
    lexbor/html/interfaces/body_element.c
    lexbor/html/interfaces/br_element.c
    lexbor/html/interfaces/button_element.c
    lexbor/html/interfaces/canvas_element.c
    lexbor/html/interfaces/d_list_element.c
    lexbor/html/interfaces/data_element.c
    lexbor/html/interfaces/data_list_element.c
    lexbor/html/interfaces/details_element.c
    lexbor/html/interfaces/dialog_element.c
    lexbor/html/interfaces/directory_element.c
    lexbor/html/interfaces/div_element.c
    lexbor/html/interfaces/document.c
    lexbor/html/interfaces/element.c
    lexbor/html/interfaces/embed_element.c
    lexbor/html/interfaces/field_set_element.c
    lexbor/html/interfaces/font_element.c
    lexbor/html/interfaces/form_element.c
    lexbor/html/interfaces/frame_element.c
    lexbor/html/interfaces/frame_set_element.c
    lexbor/html/interfaces/head_element.c
    lexbor/html/interfaces/heading_element.c
    lexbor/html/interfaces/hr_element.c
    lexbor/html/interfaces/html_element.c
    lexbor/html/interfaces/iframe_element.c
    lexbor/html/interfaces/image_element.c
    lexbor/html/interfaces/input_element.c
    lexbor/html/interfaces/label_element.c
    lexbor/html/interfaces/legend_element.c
    lexbor/html/interfaces/li_element.c
    lexbor/html/interfaces/link_element.c
    lexbor/html/interfaces/map_element.c
    lexbor/html/interfaces/marquee_element.c
    lexbor/html/interfaces/media_element.c
    lexbor/html/interfaces/menu_element.c
    lexbor/html/interfaces/meta_element.c
    lexbor/html/interfaces/meter_element.c
    lexbor/html/interfaces/mod_element.c
    lexbor/html/interfaces/o_list_element.c
    lexbor/html/interfaces/object_element.c
    lexbor/html/interfaces/opt_group_element.c
    lexbor/html/interfaces/option_element.c
    lexbor/html/interfaces/output_element.c
    lexbor/html/interfaces/paragraph_element.c
    lexbor/html/interfaces/param_element.c
    lexbor/html/interfaces/picture_element.c
    lexbor/html/interfaces/pre_element.c
    lexbor/html/interfaces/progress_element.c
    lexbor/html/interfaces/quote_element.c
    lexbor/html/interfaces/script_element.c
    lexbor/html/interfaces/select_element.c
    lexbor/html/interfaces/slot_element.c
    lexbor/html/interfaces/source_element.c
    lexbor/html/interfaces/span_element.c
    lexbor/html/interfaces/style_element.c
    lexbor/html/interfaces/table_caption_element.c
    lexbor/html/interfaces/table_cell_element.c
    lexbor/html/interfaces/table_col_element.c
    lexbor/html/interfaces/table_element.c
    lexbor/html/interfaces/table_row_element.c
    lexbor/html/interfaces/table_section_element.c
    lexbor/html/interfaces/template_element.c
    lexbor/html/interfaces/text_area_element.c
    lexbor/html/interfaces/time_element.c
    lexbor/html/interfaces/title_element.c
    lexbor/html/interfaces/track_element.c
    lexbor/html/interfaces/u_list_element.c
    lexbor/html/interfaces/unknown_element.c
    lexbor/html/interfaces/video_element.c
    lexbor/html/interfaces/window.c
    lexbor/html/parser.c
    lexbor/html/token_attr.c
    lexbor/html/token.c
    lexbor/html/tokenizer.c
    lexbor/html/tokenizer/error.c
    lexbor/html/tokenizer/state_comment.c
    lexbor/html/tokenizer/state_doctype.c
    lexbor/html/tokenizer/state_rawtext.c
    lexbor/html/tokenizer/state_rcdata.c
    lexbor/html/tokenizer/state_script.c
    lexbor/html/tokenizer/state.c
    lexbor/html/tree.c
    lexbor/html/tree/active_formatting.c
    lexbor/html/tree/error.c
    lexbor/html/tree/insertion_mode/after_after_body.c
    lexbor/html/tree/insertion_mode/after_after_frameset.c
    lexbor/html/tree/insertion_mode/after_body.c
    lexbor/html/tree/insertion_mode/after_frameset.c
    lexbor/html/tree/insertion_mode/after_head.c
    lexbor/html/tree/insertion_mode/before_head.c
    lexbor/html/tree/insertion_mode/before_html.c
    lexbor/html/tree/insertion_mode/foreign_content.c
    lexbor/html/tree/insertion_mode/in_body.c
    lexbor/html/tree/insertion_mode/in_caption.c
    lexbor/html/tree/insertion_mode/in_cell.c
    lexbor/html/tree/insertion_mode/in_column_group.c
    lexbor/html/tree/insertion_mode/in_frameset.c
    lexbor/html/tree/insertion_mode/in_head_noscript.c
    lexbor/html/tree/insertion_mode/in_head.c
    lexbor/html/tree/insertion_mode/in_row.c
    lexbor/html/tree/insertion_mode/in_select_in_table.c
    lexbor/html/tree/insertion_mode/in_select.c
    lexbor/html/tree/insertion_mode/in_table_body.c
    lexbor/html/tree/insertion_mode/in_table_text.c
    lexbor/html/tree/insertion_mode/in_table.c
    lexbor/html/tree/insertion_mode/in_template.c
    lexbor/html/tree/insertion_mode/initial.c
    lexbor/html/tree/insertion_mode/text.c
    lexbor/html/tree/open_elements.c
    lexbor/ns/ns.c
    $<$<NOT:$<PLATFORM_ID:Windows>>:lexbor/ports/posix/lexbor/core/memory.c>
    $<$<PLATFORM_ID:Windows>:lexbor/ports/windows_nt/lexbor/core/memory.c>
    lexbor/punycode/punycode.c
    lexbor/tag/tag.c
    lexbor/unicode/idna.c
    lexbor/unicode/unicode.c
    lexbor/url/url.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        php_lexbor.h
        ${lexbor_headers}
)

target_compile_definitions(
  php_ext_lexbor
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE
    $<$<PLATFORM_ID:Windows>:LEXBOR_BUILDING>
)

target_compile_options(
  php_ext_lexbor
  PRIVATE $<$<COMPILE_LANG_AND_ID:C,MSVC>:/utf-8>
)

target_include_directories(
  php_ext_lexbor
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${PHP_INCLUDE_PREFIX}/ext/lexbor>
)

set(HAVE_LEXBOR TRUE)
set(LEXBOR_VERSION "2.5.0")

configure_file(cmake/config.h.in config.h)
