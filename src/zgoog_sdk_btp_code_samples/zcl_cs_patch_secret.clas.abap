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
CLASS zcl_cs_patch_secret DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

public section.

  interfaces IF_OO_ADT_CLASSRUN .
protected section.
private section.
ENDCLASS.



CLASS ZCL_CS_PATCH_SECRET IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    " Types Declarations
    TYPES: BEGIN OF lty_labels,
             foo1 TYPE string,
             foo2 TYPE string,
           END OF lty_labels.

    " Data Declarations
    DATA:ls_labels        TYPE lty_labels,
         lv_q_updatemask  TYPE string,
         lv_p_projects_id TYPE string,
         lv_p_secrets_id  TYPE string,
         ls_input         TYPE /goog/cl_secretmgr_v1=>ty_025.

    TRY.
        " Open HTTP Connection
        DATA(lo_secretmgr) = NEW /goog/cl_secretmgr_v1( iv_key_name = 'SECRETMGR_DEMO').

        " Populate the inputs to be passed to the API
        lv_q_updatemask = 'labels'. " Comma separated fields
        lv_p_projects_id = lo_secretmgr->gv_project_id.
        lv_p_secrets_id = 'Secret_001'.
        ls_labels-foo1 = 'SDK'.
        ls_labels-foo2 = 'Testing'.
        GET REFERENCE OF ls_labels INTO ls_input-labels.

        " Call API method
        lo_secretmgr->patch_secrets(
        EXPORTING
          iv_q_updatemask  = lv_q_updatemask
          iv_p_projects_id = lv_p_projects_id
          iv_p_secrets_id  = lv_p_secrets_id
          is_input         = ls_input
        IMPORTING
        es_output        = DATA(ls_output)
        ev_ret_code      = DATA(lv_ret_code)
        ev_err_text      = DATA(lv_err_text)
        es_err_resp      = DATA(ls_err_resp) ).

        IF /goog/cl_http_client=>is_success( lv_ret_code ).
          out->write( | Secret label patched successfully | ).
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
