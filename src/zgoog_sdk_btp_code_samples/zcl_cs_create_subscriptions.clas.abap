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
CLASS zcl_cs_create_subscriptions DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_cs_create_subscriptions IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " Data declarations
    DATA lv_p_projects_id      TYPE string.
    DATA lv_p_subscriptions_id TYPE string.
    DATA ls_input              TYPE /goog/cl_pubsub_v1=>ty_038.

    TRY.

        " Open HTTP Connection
        DATA(lo_pubsub) = NEW /goog/cl_pubsub_v1( iv_key_name = 'PUBSUB_DEMO' ).

        " Populate relevant parameters
        " Derive project id from the client object
        lv_p_projects_id = lo_pubsub->gv_project_id.
        " Name of the subscription to be created
        lv_p_subscriptions_id = 'SAMPLE_SUBSCRIPTION'.
        " LS_INPUT contains the attributes of the subscription.
        " Provide the topic to which the subscription will be attached
        ls_input-topic = 'projects/' && lo_pubsub->gv_project_id && '/topics/SAMPLE_TOPIC'.

        " Call API method
        lo_pubsub->create_subscriptions( EXPORTING iv_p_projects_id      = lv_p_projects_id
                                                   iv_p_subscriptions_id = lv_p_subscriptions_id
                                                   is_input              = ls_input
                                         IMPORTING es_output             = DATA(ls_output)
                                                   ev_ret_code           = DATA(lv_ret_code)
                                                   ev_err_text           = DATA(lv_err_text)
                                                   es_err_resp           = DATA(ls_err_resp) ).

        IF /goog/cl_http_client=>is_success( lv_ret_code ).
          out->write( | Subscription created successfully!| ).
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
