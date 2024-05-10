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
CLASS zcl_cs_get_operations1 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_cs_get_operations1 IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " Data Declaration
    DATA lv_p_projects_id   TYPE string.
    DATA lv_p_operations_id TYPE string.

    TRY.

        " Open HTTP Connection
        DATA(lo_client) = NEW /goog/cl_documentai_v1( iv_key_name = 'DEMO_DOCAI' ).

        " Populate relevant parameters
        lv_p_projects_id = lo_client->gv_project_id.
        lv_p_operations_id = 'OPERATION_ID'.  " Operation ID of a Long Running Operation

        " Call API method
        lo_client->get_operations1( EXPORTING iv_p_projects_id   = lv_p_projects_id
                                              iv_p_operations_id = lv_p_operations_id
                                    IMPORTING es_output          = DATA(ls_output)
                                              ev_ret_code        = DATA(lv_ret_code)
                                              ev_err_text        = DATA(lv_err_text)
                                              es_err_resp        = DATA(ls_err_resp) ).

        IF /goog/cl_http_client=>is_success( lv_ret_code ).
          out->write( | Success | ).
        ELSE.
          out->write( | Error occurred: { lv_err_text }| ).
        ENDIF.

        " Close HTTP Connection
        lo_client->close( ).

      CATCH /goog/cx_sdk INTO DATA(lo_sdk_excp).
        lv_err_text = lo_sdk_excp->get_text( ).
        out->write( |Exception occurred: { lv_err_text } | ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
