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
CLASS zcl_qs_validate_address DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_qs_validate_address IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    DATA ls_input             TYPE /goog/cl_addrvaldn_v1=>ty_012.
    DATA lo_address_validator TYPE REF TO /goog/cl_addrvaldn_v1.

    TRY.
        " Open HTTP connection
        lo_address_validator = NEW #( iv_key_name = 'DEMO_ADDR_VAL' ).

        " Pass the address to be validated
        ls_input-address-region_code = 'US'.
        ls_input-address-locality    = 'Mountain View'.
        APPEND '1600, Amphitheatre, Parkway' TO ls_input-address-address_lines.

        " Call the API Method to validate address
        lo_address_validator->validate_address( EXPORTING is_input    = ls_input
                                                IMPORTING es_output   = DATA(ls_output)
                                                          ev_ret_code = DATA(lv_ret_code)
                                                          ev_err_text = DATA(lv_err_text)
                                                          es_err_resp = DATA(ls_err_resp) ).

        IF     lo_address_validator->is_success( lv_ret_code ) = abap_true
           AND ls_output-result-verdict-address_complete       = abap_true.
          out->write( 'Address is complete' ).
        ENDIF.

      CATCH /goog/cx_sdk INTO DATA(lo_exception). " TODO: variable is assigned but never used (ABAP cleaner)
        " Handle exception here
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
