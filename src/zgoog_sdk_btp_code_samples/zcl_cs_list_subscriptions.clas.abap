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
CLASS zcl_cs_list_subscriptions DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_cs_list_subscriptions IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " Data Declaration
    DATA lv_q_pagesize    TYPE string.
    " Token that can be used in the next call to API to get next page of subscriptions.
    DATA lv_q_pagetoken   TYPE string.
    DATA lv_p_projects_id TYPE string.
    DATA lv_p_topics_id   TYPE string.
    DATA lt_subscriptions TYPE /goog/cl_pubsub_v1=>ty_t_string.

    TRY.

        " Open HTTP Connection
        DATA(lo_pubsub) = NEW /goog/cl_pubsub_v1( iv_key_name = 'PUBSUB_DEMO' ).
        " Populate relevant parameters
        " Derive project id from the client object
        lv_p_projects_id = lo_pubsub->gv_project_id.
        " Name of the Topic whose subscriptions will be listed.
        lv_p_topics_id   = 'SAMPLE_TOPIC'.
        " Max number of subscriptions to be retrieved in 1 API Call.
        lv_q_pagesize    = 50.

        WHILE sy-index = 1 OR lv_q_pagetoken IS NOT INITIAL.
          " Call API method
          lo_pubsub->list_subscriptions1( EXPORTING iv_q_pagesize    = lv_q_pagesize
                                                    iv_q_pagetoken   = lv_q_pagetoken
                                                    iv_p_projects_id = lv_p_projects_id
                                                    iv_p_topics_id   = lv_p_topics_id
                                          IMPORTING es_output        = DATA(ls_output)
                                                    ev_ret_code      = DATA(lv_ret_code)
                                                    ev_err_text      = DATA(lv_err_text)
                                                    es_err_resp      = DATA(ls_err_resp) ).

          IF /goog/cl_http_client=>is_success( lv_ret_code ) = abap_true.
            LOOP AT ls_output-subscriptions ASSIGNING FIELD-SYMBOL(<ls_subscription>).
              APPEND <ls_subscription> TO lt_subscriptions.
            ENDLOOP.
          ENDIF.
          lv_q_pagetoken = ls_output-next_page_token.
        ENDWHILE.

        IF /goog/cl_http_client=>is_success( lv_ret_code ).

          out->write( | Subscriptions attached to Topic were received!| ).
        ELSE.
          out->write( | Error occurred: { lv_err_text }| ).
        ENDIF.

        " Close HTTP Connection
        lo_pubsub->close( ).

      CATCH /goog/cx_sdk INTO DATA(lo_exception).
        lv_err_text = lo_exception->get_text( ).
        out->write( |Exception occurred: { lv_err_text } | ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
