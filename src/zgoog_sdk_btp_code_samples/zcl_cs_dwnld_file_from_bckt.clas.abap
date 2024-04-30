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
CLASS zcl_cs_dwnld_file_from_bckt DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_cs_dwnld_file_from_bckt IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " Data Declarations
    DATA lv_p_bucket TYPE string.
    DATA lv_p_object TYPE string.
    DATA ls_data     TYPE xstring.

    TRY.
        " Open HTTP Connection
        " Pass the configured client key
        DATA(lo_client) = NEW /goog/cl_storage_v1( iv_key_name = 'CLIENT_KEY' ).

        " Populate the data that needs to be passed to the API
        " Name of the bucket
        lv_p_bucket = 'sample-bucket'.
        " Name of the object
        lv_p_object = 'sample-object'.

        " Set the common query parameter 'alt' as 'media' to retrieve object data
        lo_client->add_common_qparam( iv_name  = 'alt'
                                      iv_value = 'media' ).

        " Call API method
        lo_client->get_objects( EXPORTING iv_p_bucket = lv_p_bucket
                                          iv_p_object = lv_p_object
                                IMPORTING es_output   = DATA(ls_output)
                                          ev_ret_code = DATA(lv_ret_code)
                                          ev_err_text = DATA(lv_err_text)
                                          es_err_resp = DATA(ls_err_resp)
                                          es_raw      = ls_data ).

        IF lo_client->is_success( lv_ret_code ).
          out->write( 'Object data downloaded successfully!' ).
        ELSE.
          out->write( | Error occurred: { lv_err_text }| ).
        ENDIF.

        " Close HTTP connection
        lo_client->close( ).

      CATCH /goog/cx_sdk INTO DATA(lo_sdk_excp).
        lv_err_text = lo_sdk_excp->get_text( ).
        out->write( |Exception occurred: { lv_err_text } | ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
