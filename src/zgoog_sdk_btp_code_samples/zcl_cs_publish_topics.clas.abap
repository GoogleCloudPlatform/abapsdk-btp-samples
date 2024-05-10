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
CLASS zcl_cs_publish_topics DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_cs_publish_topics IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " Data Declaration
    DATA lv_p_projects_id TYPE string.
    DATA lv_p_topics_id   TYPE string.
    DATA ls_input         TYPE /goog/cl_pubsub_v1=>ty_023.

    TRY.

        " Open HTTP Connection
        DATA(lo_pubsub) = NEW /goog/cl_pubsub_v1( iv_key_name = 'PUBSUB_DEMO' ).

        " Populate relevant parameters
        " Derive project id from the client object
        lv_p_projects_id = lo_pubsub->gv_project_id.
        " Name of the topic to which message will be sent.
        lv_p_topics_id   = 'SAMPLE_TOPIC'.

        " ls_input-messages contains a list of messages that will be published to the Topic.
        APPEND INITIAL LINE TO ls_input-messages ASSIGNING FIELD-SYMBOL(<ls_message>).
        IF <ls_message> IS ASSIGNED.
          " The message is sent as a base64 encoded string in the data field.
          <ls_message>-data = cl_http_utility=>encode_base64( unencoded = 'Hello World!' ).
        ENDIF.

        " Call API method
        lo_pubsub->publish_topics( EXPORTING iv_p_projects_id = lv_p_projects_id
                                             iv_p_topics_id   = lv_p_topics_id
                                             is_input         = ls_input
                                   IMPORTING es_output        = DATA(ls_output)
                                             ev_ret_code      = DATA(lv_ret_code)
                                             ev_err_text      = DATA(lv_err_text)
                                             es_err_resp      = DATA(ls_err_resp) ).

        IF /goog/cl_http_client=>is_success( lv_ret_code ).
          out->write( | Message was successfully published to Pub/Sub!| ).
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
