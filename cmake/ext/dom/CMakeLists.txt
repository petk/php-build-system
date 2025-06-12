#[=============================================================================[
# The dom extension

Configure the `dom` extension.

This extension provides support for operations on XML and HTML through Document
Object Model (DOM).

## PHP_EXT_DOM

* Default: `ON`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_DOM_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.27...4.0)

project(
  PhpExtensionDom
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_DOM "Enable the dom extension" ON)

add_feature_info(
  "ext/dom"
  PHP_EXT_DOM
  "XML and HTML operations through Document Object Model (DOM)"
)

cmake_dependent_option(
  PHP_EXT_DOM_SHARED
  "Build the dom extension as a shared library"
  OFF
  "PHP_EXT_DOM;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT PHP_EXT_DOM)
  return()
endif()

if(PHP_EXT_DOM_SHARED)
  add_library(php_ext_dom SHARED)
else()
  add_library(php_ext_dom)
endif()

target_sources(
  php_ext_dom
  PRIVATE
    attr.c
    cdatasection.c
    characterdata.c
    comment.c
    document.c
    documentfragment.c
    documenttype.c
    dom_iterators.c
    domexception.c
    domimplementation.c
    element.c
    entity.c
    entityreference.c
    html_collection.c
    html_document.c
    html5_parser.c
    html5_serializer.c
    infra.c
    inner_html_mixin.c
    lexbor/lexbor/core/array_obj.c
    lexbor/lexbor/core/array.c
    lexbor/lexbor/core/avl.c
    lexbor/lexbor/core/bst.c
    lexbor/lexbor/core/conv.c
    lexbor/lexbor/core/diyfp.c
    lexbor/lexbor/core/dobject.c
    lexbor/lexbor/core/dtoa.c
    lexbor/lexbor/core/hash.c
    lexbor/lexbor/core/mem.c
    lexbor/lexbor/core/mraw.c
    lexbor/lexbor/core/print.c
    lexbor/lexbor/core/serialize.c
    lexbor/lexbor/core/shs.c
    lexbor/lexbor/core/str.c
    lexbor/lexbor/core/strtod.c
    lexbor/lexbor/css/css.c
    lexbor/lexbor/css/log.c
    lexbor/lexbor/css/parser.c
    lexbor/lexbor/css/selectors/pseudo_state.c
    lexbor/lexbor/css/selectors/pseudo.c
    lexbor/lexbor/css/selectors/selector.c
    lexbor/lexbor/css/selectors/selectors.c
    lexbor/lexbor/css/selectors/state.c
    lexbor/lexbor/css/state.c
    lexbor/lexbor/css/syntax/anb.c
    lexbor/lexbor/css/syntax/parser.c
    lexbor/lexbor/css/syntax/state.c
    lexbor/lexbor/css/syntax/syntax.c
    lexbor/lexbor/css/syntax/token.c
    lexbor/lexbor/css/syntax/tokenizer.c
    lexbor/lexbor/css/syntax/tokenizer/error.c
    lexbor/lexbor/dom/interface.c
    lexbor/lexbor/dom/interfaces/attr.c
    lexbor/lexbor/dom/interfaces/cdata_section.c
    lexbor/lexbor/dom/interfaces/character_data.c
    lexbor/lexbor/dom/interfaces/comment.c
    lexbor/lexbor/dom/interfaces/document_fragment.c
    lexbor/lexbor/dom/interfaces/document_type.c
    lexbor/lexbor/dom/interfaces/document.c
    lexbor/lexbor/dom/interfaces/element.c
    lexbor/lexbor/dom/interfaces/node.c
    lexbor/lexbor/dom/interfaces/processing_instruction.c
    lexbor/lexbor/dom/interfaces/shadow_root.c
    lexbor/lexbor/dom/interfaces/text.c
    lexbor/lexbor/encoding/big5.c
    lexbor/lexbor/encoding/decode.c
    lexbor/lexbor/encoding/encode.c
    lexbor/lexbor/encoding/encoding.c
    lexbor/lexbor/encoding/euc_kr.c
    lexbor/lexbor/encoding/gb18030.c
    lexbor/lexbor/encoding/iso_2022_jp_katakana.c
    lexbor/lexbor/encoding/jis0208.c
    lexbor/lexbor/encoding/jis0212.c
    lexbor/lexbor/encoding/range.c
    lexbor/lexbor/encoding/res.c
    lexbor/lexbor/encoding/single.c
    lexbor/lexbor/html/encoding.c
    lexbor/lexbor/html/interface.c
    lexbor/lexbor/html/interfaces/anchor_element.c
    lexbor/lexbor/html/interfaces/area_element.c
    lexbor/lexbor/html/interfaces/audio_element.c
    lexbor/lexbor/html/interfaces/base_element.c
    lexbor/lexbor/html/interfaces/body_element.c
    lexbor/lexbor/html/interfaces/br_element.c
    lexbor/lexbor/html/interfaces/button_element.c
    lexbor/lexbor/html/interfaces/canvas_element.c
    lexbor/lexbor/html/interfaces/d_list_element.c
    lexbor/lexbor/html/interfaces/data_element.c
    lexbor/lexbor/html/interfaces/data_list_element.c
    lexbor/lexbor/html/interfaces/details_element.c
    lexbor/lexbor/html/interfaces/dialog_element.c
    lexbor/lexbor/html/interfaces/directory_element.c
    lexbor/lexbor/html/interfaces/div_element.c
    lexbor/lexbor/html/interfaces/document.c
    lexbor/lexbor/html/interfaces/element.c
    lexbor/lexbor/html/interfaces/embed_element.c
    lexbor/lexbor/html/interfaces/field_set_element.c
    lexbor/lexbor/html/interfaces/font_element.c
    lexbor/lexbor/html/interfaces/form_element.c
    lexbor/lexbor/html/interfaces/frame_element.c
    lexbor/lexbor/html/interfaces/frame_set_element.c
    lexbor/lexbor/html/interfaces/head_element.c
    lexbor/lexbor/html/interfaces/heading_element.c
    lexbor/lexbor/html/interfaces/hr_element.c
    lexbor/lexbor/html/interfaces/html_element.c
    lexbor/lexbor/html/interfaces/iframe_element.c
    lexbor/lexbor/html/interfaces/image_element.c
    lexbor/lexbor/html/interfaces/input_element.c
    lexbor/lexbor/html/interfaces/label_element.c
    lexbor/lexbor/html/interfaces/legend_element.c
    lexbor/lexbor/html/interfaces/li_element.c
    lexbor/lexbor/html/interfaces/link_element.c
    lexbor/lexbor/html/interfaces/map_element.c
    lexbor/lexbor/html/interfaces/marquee_element.c
    lexbor/lexbor/html/interfaces/media_element.c
    lexbor/lexbor/html/interfaces/menu_element.c
    lexbor/lexbor/html/interfaces/meta_element.c
    lexbor/lexbor/html/interfaces/meter_element.c
    lexbor/lexbor/html/interfaces/mod_element.c
    lexbor/lexbor/html/interfaces/o_list_element.c
    lexbor/lexbor/html/interfaces/object_element.c
    lexbor/lexbor/html/interfaces/opt_group_element.c
    lexbor/lexbor/html/interfaces/option_element.c
    lexbor/lexbor/html/interfaces/output_element.c
    lexbor/lexbor/html/interfaces/paragraph_element.c
    lexbor/lexbor/html/interfaces/param_element.c
    lexbor/lexbor/html/interfaces/picture_element.c
    lexbor/lexbor/html/interfaces/pre_element.c
    lexbor/lexbor/html/interfaces/progress_element.c
    lexbor/lexbor/html/interfaces/quote_element.c
    lexbor/lexbor/html/interfaces/script_element.c
    lexbor/lexbor/html/interfaces/select_element.c
    lexbor/lexbor/html/interfaces/slot_element.c
    lexbor/lexbor/html/interfaces/source_element.c
    lexbor/lexbor/html/interfaces/span_element.c
    lexbor/lexbor/html/interfaces/style_element.c
    lexbor/lexbor/html/interfaces/table_caption_element.c
    lexbor/lexbor/html/interfaces/table_cell_element.c
    lexbor/lexbor/html/interfaces/table_col_element.c
    lexbor/lexbor/html/interfaces/table_element.c
    lexbor/lexbor/html/interfaces/table_row_element.c
    lexbor/lexbor/html/interfaces/table_section_element.c
    lexbor/lexbor/html/interfaces/template_element.c
    lexbor/lexbor/html/interfaces/text_area_element.c
    lexbor/lexbor/html/interfaces/time_element.c
    lexbor/lexbor/html/interfaces/title_element.c
    lexbor/lexbor/html/interfaces/track_element.c
    lexbor/lexbor/html/interfaces/u_list_element.c
    lexbor/lexbor/html/interfaces/unknown_element.c
    lexbor/lexbor/html/interfaces/video_element.c
    lexbor/lexbor/html/interfaces/window.c
    lexbor/lexbor/html/parser.c
    lexbor/lexbor/html/token_attr.c
    lexbor/lexbor/html/token.c
    lexbor/lexbor/html/tokenizer.c
    lexbor/lexbor/html/tokenizer/error.c
    lexbor/lexbor/html/tokenizer/state_comment.c
    lexbor/lexbor/html/tokenizer/state_doctype.c
    lexbor/lexbor/html/tokenizer/state_rawtext.c
    lexbor/lexbor/html/tokenizer/state_rcdata.c
    lexbor/lexbor/html/tokenizer/state_script.c
    lexbor/lexbor/html/tokenizer/state.c
    lexbor/lexbor/html/tree.c
    lexbor/lexbor/html/tree/active_formatting.c
    lexbor/lexbor/html/tree/error.c
    lexbor/lexbor/html/tree/insertion_mode/after_after_body.c
    lexbor/lexbor/html/tree/insertion_mode/after_after_frameset.c
    lexbor/lexbor/html/tree/insertion_mode/after_body.c
    lexbor/lexbor/html/tree/insertion_mode/after_frameset.c
    lexbor/lexbor/html/tree/insertion_mode/after_head.c
    lexbor/lexbor/html/tree/insertion_mode/before_head.c
    lexbor/lexbor/html/tree/insertion_mode/before_html.c
    lexbor/lexbor/html/tree/insertion_mode/foreign_content.c
    lexbor/lexbor/html/tree/insertion_mode/in_body.c
    lexbor/lexbor/html/tree/insertion_mode/in_caption.c
    lexbor/lexbor/html/tree/insertion_mode/in_cell.c
    lexbor/lexbor/html/tree/insertion_mode/in_column_group.c
    lexbor/lexbor/html/tree/insertion_mode/in_frameset.c
    lexbor/lexbor/html/tree/insertion_mode/in_head_noscript.c
    lexbor/lexbor/html/tree/insertion_mode/in_head.c
    lexbor/lexbor/html/tree/insertion_mode/in_row.c
    lexbor/lexbor/html/tree/insertion_mode/in_select_in_table.c
    lexbor/lexbor/html/tree/insertion_mode/in_select.c
    lexbor/lexbor/html/tree/insertion_mode/in_table_body.c
    lexbor/lexbor/html/tree/insertion_mode/in_table_text.c
    lexbor/lexbor/html/tree/insertion_mode/in_table.c
    lexbor/lexbor/html/tree/insertion_mode/in_template.c
    lexbor/lexbor/html/tree/insertion_mode/initial.c
    lexbor/lexbor/html/tree/insertion_mode/text.c
    lexbor/lexbor/html/tree/open_elements.c
    lexbor/lexbor/ns/ns.c
    lexbor/lexbor/ports/posix/lexbor/core/memory.c
    lexbor/lexbor/selectors-adapted/selectors.c
    lexbor/lexbor/tag/tag.c
    namednodemap.c
    namespace_compat.c
    node.c
    nodelist.c
    notation.c
    parentnode/css_selectors.c
    parentnode/tree.c
    php_dom.c
    php_dom.stub.php
    private_data.c
    processinginstruction.c
    text.c
    token_list.c
    xml_document.c
    xml_serializer.c
    xpath_callbacks.c
    xpath.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        dom_ce.h
        namespace_compat.h
        xml_common.h
        xpath_callbacks.h
)

target_include_directories(php_ext_dom PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/lexbor)

target_compile_definitions(
  php_ext_dom
  PRIVATE
    LEXBOR_STATIC
    $<$<AND:$<PLATFORM_ID:Windows>,$<NOT:$<IN_LIST:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>>>:LIBXML_STATIC>
)

include(Packages/LibXml2)

set_package_properties(
  LibXml2
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the dom extension."
)

target_link_libraries(php_ext_dom PRIVATE LibXml2::LibXml2)

add_dependencies(php_ext_dom php_ext_libxml php_ext_random)

set(HAVE_DOM TRUE)

configure_file(cmake/config.h.in config.h)
