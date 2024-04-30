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
CLASS zcl_cs_destroy_secret_version DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

public section.

  interfaces IF_OO_ADT_CLASSRUN .
protected section.
private section.
ENDCLASS.



CLASS ZCL_CS_DESTROY_SECRET_VERSION IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    " Data declarations
    DATA:
      lv_p_projects_id TYPE string,
      lv_p_secrets_id  TYPE string,
      lv_p_versions_id TYPE string,
      ls_input         TYPE /goog/cl_secretmgr_v1=>ty_010.

    TRY.
        " Open HTTP Connection
        DATA(lo_secretmgr) = NEW /goog/cl_secretmgr_v1( iv_key_name = 'SECRETMGR_DEMO').

        " Populate relevant parameters
        lv_p_projects_id = lo_secretmgr->gv_project_id.
        lv_p_secrets_id = 'Secret_001'.
        lv_p_versions_id = '1'.

        " Call API Method
        lo_secretmgr->destroy_versions(
        EXPORTING
          iv_p_projects_id = lv_p_projects_id
          iv_p_secrets_id  = lv_p_secrets_id
          iv_p_versions_id = lv_p_versions_id
          is_input         = ls_input
        IMPORTING
        es_output        = DATA(ls_output)
        ev_ret_code      = DATA(lv_ret_code)
        ev_err_text      = DATA(lv_err_text)
        es_err_resp      = DATA(ls_err_resp) ).

        IF /goog/cl_http_client=>is_success( lv_ret_code ).
          out->write( | Secret version deleted successfully | ).
        ELSE.
          out->write( | Error occurred: { lv_err_text }| ).
        ENDIF.

        " Close HTTP Connection
        lo_secretmgr->close( ).

      CATCH /goog/cx_sdk INTO DATA(lo_sdk_excp).
        lv_err_text = lo_sdk_excp->get_text( ).
        out->write( |Exception occurred: { lv_err_text } | ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
