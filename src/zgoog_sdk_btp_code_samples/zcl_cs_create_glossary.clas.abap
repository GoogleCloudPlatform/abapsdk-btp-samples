" -----------------------------------------------------------------------------------------------------------------------
" Copyright 2024 Google LLC                                                                                            -
" ABAP SDK for Google Cloud is made available as "Software" under the agreement governing your use of                  -
" Google Cloud Platform including the Service Specific Terms available at                                              -
"                                                                                                                      -
" https://cloud.google.com/terms/service-terms                                                                         -
"                                                                                                                      -
" Without limiting the generality of the above terms, you may not modify or distribute ABAP SDK for Google Cloud       -
" without express written permission from Google.                                                                      -
" -----------------------------------------------------------------------------------------------------------------------

CLASS zcl_cs_create_glossary DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_cs_create_glossary IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA lv_p_projects_id  TYPE string.
    DATA lv_p_locations_id TYPE string.
    DATA ls_input          TYPE /goog/cl_translation_v3=>ty_022.

    TRY.

        " Open HTTP Connection
        " Pass the configured client key
        DATA(lo_translate) = NEW /goog/cl_translation_v3( iv_key_name = 'TRANSLATE_DEMO' ).

        " Derive project id from the object
        lv_p_projects_id  = lo_translate->gv_project_id.
        " Set a location id, 'us-central1' is used as example
        lv_p_locations_id = 'us-central1'.

        " Pass a display name
        ls_input-display_name = 'Finance Term Glossary EN to ES'.

        " Source language in BCP-47 format
        ls_input-language_pair-source_language_code = 'en-US'.
        " Target language in BCP-47 format

        ls_input-language_pair-target_language_code = 'es-ES'.
        " Complete name of glossary has following format:
        " projects/<PROJECT_ID>/locations/<LOCATION_ID>/glossaries/<GLOSSARY_ID>
        CONCATENATE 'projects/'
                     lo_translate->gv_project_id
                     '/locations/us-central1/glossaries/'
                     'FI_GLOSSARY_EN_ES'
                    INTO ls_input-name.

        " Pass the complete path of glossary file which is stored in GCS bucket
        " Below example shows a file named: fi_glossary_data.tsv is stored in a GCS bucket named: glossary_repo
        ls_input-input_config-gcs_source-input_uri = 'gs://glossary_repo/fi_glossary_data.tsv'.

        " Call API method
        lo_translate->create_glossaries( EXPORTING iv_p_projects_id  = lv_p_projects_id
                                                   iv_p_locations_id = lv_p_locations_id
                                                   is_input          = ls_input
                                         IMPORTING es_output         = DATA(ls_output)
                                                   ev_ret_code       = DATA(lv_ret_code)
                                                   ev_err_text       = DATA(lv_err_text)
                                                   es_err_resp       = DATA(ls_err_resp) ).
        IF /goog/cl_http_client=>is_success( lv_ret_code ).
          " This returns a long running operation id as glossary creation is adhoc
          " You can use the LRO ID to poll to check the status of the operation (SUCCESS Or FAILURE)
          out->write( | LRO ID:{ ls_output-name }| ).
        ELSE.

          out->write( | Error occurred: { lv_err_text }| ).

        ENDIF.

        " Close HTTP Connection
        lo_translate->close( ).

      CATCH /goog/cx_sdk INTO DATA(lo_sdk_excp).
        lv_err_text = lo_sdk_excp->get_text( ).
        out->write( |Exception occurred: { lv_err_text } | ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
