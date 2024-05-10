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
CLASS zcl_cs_process_processors DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_cs_process_processors IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " Data Declarations
    DATA lv_p_projects_id   TYPE string.
    DATA lv_p_locations_id  TYPE string.
    DATA lv_p_processors_id TYPE string.
    DATA ls_input           TYPE /goog/cl_documentai_v1=>ty_084.
    DATA ls_output          TYPE /goog/cl_documentai_v1=>ty_085.
    DATA lo_exception       TYPE REF TO /goog/cx_sdk.

    TRY.
        DATA(lo_client) = NEW /goog/cl_documentai_v1( iv_key_name = 'DEMO_DOCAI' ).

        "  Developer to populate relevant parameters for the API call
        lv_p_projects_id = lo_client->gv_project_id.
        lv_p_locations_id = 'LOCATION_ID'. " Location ID of the Processor
        lv_p_processors_id = 'PROCESSOR_ID'. " "Processor ID of the Processor

        " Developer to fetch the content and mime type of the file to be processed
        ls_input-raw_document-content   = 'CONTENT'.  " Content of the file in base-64 format
        ls_input-raw_document-mime_type = 'MIME_TYPE'. " Mime type of the file

        " Call the API
        lo_client->process_processors( EXPORTING iv_p_projects_id   = lv_p_projects_id
                                                 iv_p_locations_id  = lv_p_locations_id
                                                 iv_p_processors_id = lv_p_processors_id
                                                 is_input           = ls_input
                                       IMPORTING es_output          = ls_output
                                                 ev_ret_code        = DATA(ev_ret_code)
                                                 ev_err_text        = DATA(ev_err_text)
                                                 es_err_resp        = DATA(es_err_resp) ).

        IF /goog/cl_http_client=>is_success( ev_ret_code ).
          out->write( | Success | ).
        ELSE.
          out->write( | Error occurred: { ev_err_text }| ).
        ENDIF.

        " Close HTTP Connection
        lo_client->close( ).

      CATCH /goog/cx_sdk INTO DATA(lo_sdk_excp).
        ev_err_text = lo_sdk_excp->get_text( ).
        out->write( |Exception occurred: { ev_err_text } | ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
