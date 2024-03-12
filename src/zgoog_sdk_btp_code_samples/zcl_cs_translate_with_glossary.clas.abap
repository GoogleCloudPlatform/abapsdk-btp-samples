" --------------------------------------------------------------------
"  Copyright 2024 Google LLC                                         -
"                                                                    -
"  Licensed under the Apache License, Version 2.0 (the "License");   -
"  you may not use this file except in compliance with the License.  -
"  You may obtain a copy of the License at                           -
"      https://www.apache.org/licenses/LICENSE-2.0                   -
"  Unless required by applicable law or agreed to in writing,        -
"  software distributed under the License is distributed on an       -
"  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,      -
"  either express or implied.                                        -
"  See the License for the specific language governing permissions   -
"  and limitations under the License.                                -
" --------------------------------------------------------------------
CLASS zcl_cs_translate_with_glossary DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_cs_translate_with_glossary IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " Data Declarations
    DATA lv_p_projects_id  TYPE string.
    DATA lv_p_locations_id TYPE string.
    DATA ls_input          TYPE /goog/cl_translation_v3=>ty_050.
    DATA lo_exception      TYPE REF TO /goog/cx_sdk.

    TRY.

        " Open HTTP Connection
        " Pass the configured client key
        DATA(lo_translate) = NEW /goog/cl_translation_v3( iv_key_name = 'TRANSLATE_DEMO' ).

        " Derive project id
        lv_p_projects_id   = lo_translate->gv_project_id.
        " Provide a location id, here 'us-central1' is uses as example
        lv_p_locations_id  = 'us-central1'.
        " Provide MIME type
        ls_input-mime_type            = 'text/plain'.
        " Target language code in BCP-47 format

        ls_input-target_language_code = 'esES'.

        " Provide glossary id
        ls_input-glossary_config-glossary = 'fi_glossary_en_to_es'.

        ls_input-contents = VALUE #( ( |Debit amount carry forwarded for fiscal year| ) ).

        " Call the API
        lo_translate->translate_text_locations( EXPORTING iv_p_projects_id  = lv_p_projects_id
                                                          iv_p_locations_id = lv_p_locations_id
                                                          is_input          = ls_input
                                                IMPORTING es_output         = DATA(ls_output)
                                                          ev_ret_code       = DATA(lv_ret_code)
                                                          ev_err_text       = DATA(lv_err_text)
                                                          es_err_resp       = DATA(ls_err_resp) ).
        IF /goog/cl_http_client=>is_success( lv_ret_code ).
          " On successful call - print glossary translated text along with regular translation
          READ TABLE ls_output-glossary_translations INTO DATA(ls_glss_translation) INDEX 1.
          IF sy-subrc = 0.
            out->write( | Glossary Translated Text is: {  ls_glss_translation-translated_text }| ).
          ENDIF.

          READ TABLE ls_output-translations INTO DATA(ls_translation) INDEX 1.
          IF sy-subrc = 0.
            out->write( | Translated Text is: { ls_translation-translated_text } | ).
          ENDIF.
        ELSE.
          out->write( | Error occurred: { lv_err_text }| ).
        ENDIF.

        " Close HTTP Connection
        lo_translate->close( ).

      " Handle exception
      CATCH /goog/cx_sdk INTO DATA(lo_sdk_excp).
        lv_err_text = lo_sdk_excp->get_text( ).
        out->write( |Exception occurred: { lv_err_text } | ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
