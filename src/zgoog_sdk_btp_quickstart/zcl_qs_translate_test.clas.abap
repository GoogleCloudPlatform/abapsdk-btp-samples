" -----------------------------------------------------------------------------------------------------------------------
" Copyright 2024 Google LLC                                                                                            -
" ABAP SDK for Google Cloud is made available as "Software" under the agreement governing your use of                  -
" Google Cloud Platform including the Service Specific Terms available at                                              -
"                                                                                                                      -
" https://cloud.google.com/terms/service-terms                                                                         -
"                                                                                                                      -
" Without limiting the generality of the above terms, you may not modify or distribute ABAP SDK for Google Cloud       -
" without express written permission from Google.                                                                      -
" -----------------------------------------------------------------------------------------------------------------------
CLASS zcl_qs_translate_test DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_qs_translate_test IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA ls_input        TYPE /goog/cl_translation_v2=>ty_006.
    DATA lt_translations TYPE /goog/cl_translation_v2=>ty_translations.
    DATA ls_texts        TYPE /goog/cl_translation_v2=>ty_008.
    DATA lo_translate    TYPE REF TO /goog/cl_translation_v2.

    TRY.
        " Instantiate API client stub
        lo_translate = NEW #( iv_key_name = 'DEMO_TRANSLATE' ).

        " Pass the text to be translated to the required parameter
        ls_input = VALUE #( format = 'text'
                            source = 'en'
                            target = 'de'
                            q      = VALUE #( ( |The Earth is the third planet from the Sun| ) ) ).

        " Call the API method to translate text
        lo_translate->translate_translations( EXPORTING is_input    = ls_input
                                              IMPORTING es_output   = DATA(ls_output)
                                                        ev_ret_code = DATA(lv_ret_code)
                                                        ev_err_text = DATA(lv_err_text)
                                                        es_err_resp = DATA(ls_err_resp) ).
        IF lo_translate->is_success( lv_ret_code ) = abap_true.
          lt_translations = ls_output-data.
          TRY.
              ls_texts = lt_translations-translations[ 1 ].
              out->write( |Translation Successful| ).
              out->write( |Translated Text is:  { ls_texts-translated_text }| ).
            CATCH cx_sy_itab_line_not_found.
              out->write( |Translation not fetched| ).
          ENDTRY.
        ENDIF.

        " Close HTTP connection
        lo_translate->close( ).

      CATCH /goog/cx_sdk INTO DATA(lo_exception).
        " Handle exception here
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
