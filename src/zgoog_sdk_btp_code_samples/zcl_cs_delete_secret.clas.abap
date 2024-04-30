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
CLASS zcl_cs_delete_secret DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_cs_delete_secret IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " Data Declarations
    DATA lv_p_secrets_id  TYPE string.
    DATA lv_p_projects_id TYPE string.

    TRY.
        " Open HTTP Connection
        " Pass the configured client key
        DATA(lo_secretmgr) = NEW /goog/cl_secretmgr_v1( iv_key_name = 'SECRETMGR_DEMO' ).

        " Derive project id from the object
        lv_p_projects_id = lo_secretmgr->gv_project_id.
        " Populate inputs to be passed to the API
        lv_p_secrets_id = 'Secret_001'.

        " Call API method
        lo_secretmgr->delete_secrets( EXPORTING iv_p_projects_id = lv_p_projects_id
                                                iv_p_secrets_id  = lv_p_secrets_id
                                      IMPORTING
*                                                es_raw           =
                                      " TODO: variable is assigned but never used (ABAP cleaner)
                                                es_output        = DATA(ls_output)
                                                ev_ret_code      = DATA(lv_ret_code)
                                                ev_err_text      = DATA(lv_err_text)
                                      " TODO: variable is assigned but never used (ABAP cleaner)
                                                es_err_resp      = DATA(ls_err_resp) ).
        IF /goog/cl_http_client=>is_success( lv_ret_code ).
          out->write( | Secret: { lv_p_secrets_id } deleted successfully | ).
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
