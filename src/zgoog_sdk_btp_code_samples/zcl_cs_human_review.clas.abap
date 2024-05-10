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
CLASS zcl_cs_human_review DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_cs_human_review IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " Data Declarations
    DATA lv_p_projects_id   TYPE string.
    DATA lv_p_locations_id  TYPE string.
    DATA lv_p_processors_id TYPE string.
    DATA ls_input_proc      TYPE /goog/cl_documentai_v1=>ty_084.
    DATA ls_input           TYPE /goog/cl_documentai_v1=>ty_092.
    DATA lo_exception       TYPE REF TO /goog/cx_sdk.

    TRY.
        DATA(lo_client) = NEW /goog/cl_documentai_v1( iv_key_name = 'DEMO_DOCAI' ).

        "  Developer to populate relevant parameters for the API call
        lv_p_projects_id = lo_client->gv_project_id.
        " Location ID of the Processor
        lv_p_locations_id = 'LOCATION_ID'.
        " Processor ID of the Processor
        lv_p_processors_id = 'PROCESSOR_ID'.

        " Developer to fetch the content and mime type of the file to be processed
        " Content of the file in base-64 format
        ls_input_proc-raw_document-content   = 'CONTENT'.
        " Mime type of the file
        ls_input_proc-raw_document-mime_type = 'MIME_TYPE'.

        " Call the API
        lo_client->process_processors( EXPORTING iv_p_projects_id   = lv_p_projects_id
                                                 iv_p_locations_id  = lv_p_locations_id
                                                 iv_p_processors_id = lv_p_processors_id
                                                 is_input           = ls_input_proc
                                       IMPORTING es_output          = DATA(ls_output_proc)
                                                 ev_ret_code        = DATA(ev_ret_code)
                                                 ev_err_text        = DATA(ev_err_text)
                                                 es_err_resp        = DATA(es_err_resp) ).
        IF /goog/cl_http_client=>is_success( ev_ret_code ).

          " Pass the processed document to importing parameters to send for 'Human Review'
          ls_input-inline_document = ls_output_proc-document.

          " Call API method to send processed document for 'Human Review'
          lo_client->review_document_human_revie( EXPORTING iv_p_projects_id   = lv_p_projects_id
                                                            iv_p_locations_id  = lv_p_locations_id
                                                            iv_p_processors_id = lv_p_processors_id
                                                            is_input           = ls_input
                                                  IMPORTING es_output          = DATA(ls_output)
                                                            ev_ret_code        = DATA(lv_ret_code)
                                                            ev_err_text        = DATA(lv_err_text)
                                                            es_err_resp        = DATA(ls_err_resp) ).
          IF /goog/cl_http_client=>is_success( lv_ret_code ).
            out->write( | Success | ).
          ELSE.
            out->write( | Error occurred: { ev_err_text }| ).
          ENDIF.
        ELSE.
          out->write( | Error occurred: { ev_err_text }| ).
        ENDIF.

        " Close HTTP Connection
        lo_client->close( ).

      CATCH /goog/cx_sdk INTO DATA(lo_exp).
        ev_err_text = lo_exp->get_text( ).
        out->write( | Error occurred: { ev_err_text }| ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
