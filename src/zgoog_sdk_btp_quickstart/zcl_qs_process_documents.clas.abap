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
CLASS zcl_qs_process_documents DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_qs_process_documents IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA lv_p_projects_id   TYPE string.
    DATA lv_p_locations_id  TYPE string.
    DATA lv_p_processors_id TYPE string.
    DATA ls_input           TYPE /goog/cl_documentai_v1=>ty_017.
    DATA lo_docai           TYPE REF TO /goog/cl_documentai_v1.

    TRY.

        " Open HTTP connection
        lo_docai = NEW #( iv_key_name = 'DEMO_DOC_PROCESSING' ).

        " Populate relevant parameters to be passed to API
        lv_p_projects_id  = 'PROJECT_ID'.
        lv_p_locations_id = 'LOCATION_ID'.
        lv_p_processors_id = 'PROCESSOR_ID'.
        ls_input-input_documents-gcs_prefix-gcs_uri_prefix = 'SOURCE_BUCKET_URI'.
        ls_input-document_output_config-gcs_output_config-gcs_uri = 'TARGET_BUCKET_URI'.

        " Call API method
        lo_docai->batch_process_processors( EXPORTING iv_p_projects_id   = lv_p_projects_id
                                                      iv_p_locations_id  = lv_p_locations_id
                                                      iv_p_processors_id = lv_p_processors_id
                                                      is_input           = ls_input
                                            IMPORTING
                                                      es_output          = DATA(ls_output)
                                                      ev_ret_code        = DATA(lv_ret_code)
                                                      ev_err_text        = DATA(lv_err_text)
                                                      es_err_resp        = DATA(ls_err_resp) ).

        IF lo_docai->is_success( lv_ret_code ) = abap_true.
          out->write( |API call successful| ).
        ELSE.
          out->write( |Error occurred during API call| ).
          out->write( lv_err_text ).
        ENDIF.

        " Close HTTP connection
        lo_docai->close( ).

      CATCH /goog/cx_sdk INTO DATA(lo_exception). " TODO: variable is assigned but never used (ABAP cleaner)
        " Handle exception here
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
