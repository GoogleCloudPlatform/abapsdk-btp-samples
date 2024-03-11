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
CLASS zcl_qs_publish_messages DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_qs_publish_messages IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    DATA ls_input         TYPE /goog/cl_pubsub_v1=>ty_023.
    DATA lo_pubsub        TYPE REF TO /goog/cl_pubsub_v1.
    DATA lv_p_projects_id TYPE string.
    DATA lv_p_topics_id   TYPE string.

    TRY.
        " Open HTTP connection
        lo_pubsub = NEW /goog/cl_pubsub_v1( iv_key_name = 'DEMO_PUBSUB' ).

        " Pass the relevant input parameters
        lv_p_topics_id = 'SAMPLE_TOPIC_01'.
        lv_p_projects_id = lo_pubsub->gv_project_id.
        APPEND VALUE #( data = cl_http_utility=>encode_base64( 'Hello World!' ) )
               TO ls_input-messages.

        " Call the API
        lo_pubsub->publish_topics( EXPORTING iv_p_projects_id = lv_p_projects_id
                                             iv_p_topics_id   = lv_p_topics_id
                                             is_input         = ls_input
                                   IMPORTING
                                             es_output        = DATA(ls_output)
                                             ev_ret_code      = DATA(lv_ret_code)
                                             ev_err_text      = DATA(lv_err_text)
                                             es_err_resp      = DATA(ls_err_resp) ).

        " Handle the output
        IF lo_pubsub->is_success( lv_ret_code ).
          out->write( 'Message was published!' ).
        ELSE.
          out->write( 'Message was not published!' ).
        ENDIF.

        " Close the HTTP Connection
        lo_pubsub->close( ).

      CATCH /goog/cx_sdk INTO DATA(lo_exception).
        MESSAGE lo_exception->get_text( ) TYPE 'E'.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
