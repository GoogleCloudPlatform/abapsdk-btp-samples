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
CLASS zcl_cs_list_buckets DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_cs_list_buckets IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " Data Declarations
    DATA lv_q_project    TYPE string.
    DATA lv_q_maxresults TYPE string.
    DATA lv_q_pagetoken  TYPE string.
    DATA lt_buckets      TYPE TABLE OF string.

    TRY.
        " Open HTTP Connection
        " Pass the configured client key
        DATA(lo_client) = NEW /goog/cl_storage_v1( iv_key_name = 'CLIENT_KEY' ).

        " Populate the data that needs to be passed to the API
        " Derive project id from the client object
        lv_q_project    = lo_client->gv_project_id.
        " Maximum number of buckets to be retrieved in 1 API calls
        lv_q_maxresults = '50'.

        WHILE sy-index = 1 OR lv_q_pagetoken IS NOT INITIAL.

          " Call API method
          lo_client->list_buckets( EXPORTING iv_q_maxresults = lv_q_maxresults
                                             iv_q_pagetoken  = lv_q_pagetoken
                                             iv_q_project    = lv_q_project
                                   IMPORTING es_output       = DATA(ls_output)
                                             ev_ret_code     = DATA(lv_ret_code)
                                             ev_err_text     = DATA(lv_err_text)
                                             es_err_resp     = DATA(ls_err_resp) ).

          IF lo_client->is_success( lv_ret_code ).
            lt_buckets = VALUE #( FOR wa IN ls_output-items
                                  ( wa-name ) ).
          ENDIF.
          lv_q_pagetoken = ls_output-next_page_token.
        ENDWHILE.

        IF lo_client->is_success( lv_ret_code ).
          out->write( 'Buckets in the project were retrieved!' ).
          out->write( lt_buckets ).
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
