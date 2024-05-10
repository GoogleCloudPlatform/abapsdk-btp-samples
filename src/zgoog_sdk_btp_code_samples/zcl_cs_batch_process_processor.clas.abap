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
CLASS zcl_cs_batch_process_processor DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_cs_batch_process_processor IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " Data Declarations
    DATA lv_p_projects_id   TYPE string.
    DATA lv_p_locations_id  TYPE string.
    DATA lv_p_processors_id TYPE string.
    DATA ls_input           TYPE /goog/cl_documentai_v1=>ty_017.

    TRY.
        " Open HTTP Connection
        DATA(lo_client) = NEW /goog/cl_documentai_v1( iv_key_name = 'DEMO_DOCAI' ).

        " Populate relevant parameters
        lv_p_projects_id = lo_client->gv_project_id.
         " Location ID of the Processor
        lv_p_locations_id = 'LOCATION_ID'.
        " Processor ID of the Processor
        lv_p_processors_id = 'PROCESSOR_ID'.
        " Source GCS Bucket URI Prefix
        ls_input-input_documents-gcs_prefix-gcs_uri_prefix = 'SOURCE_GCS_BUCKET_URI_PREFIX'.
        " Target GCS Bucket URI
        ls_input-document_output_config-gcs_output_config-gcs_uri = 'TARGET_GCS_BUCKET_URI'.

        " Call API method
        lo_client->batch_process_processors( EXPORTING iv_p_projects_id   = lv_p_projects_id
                                                       iv_p_locations_id  = lv_p_locations_id
                                                       iv_p_processors_id = lv_p_processors_id
                                                       is_input           = ls_input
                                             IMPORTING es_output          = DATA(ls_output)
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
