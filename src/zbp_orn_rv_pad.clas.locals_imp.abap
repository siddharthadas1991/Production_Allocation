CLASS lhc_bh_detail DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS setdefaultlineid FOR DETERMINE ON MODIFY
      IMPORTING keys FOR bh_detail~setdefaultlineid.
    METHODS fetchdatafrommappingsheet FOR DETERMINE ON MODIFY
      IMPORTING keys FOR bh_detail~fetchdatafrommappingsheet.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR bh_detail RESULT result.

    METHODS fetchdetaildata FOR MODIFY
      IMPORTING keys FOR ACTION bh_detail~fetchdetaildata.

    TYPES: BEGIN OF ty_bom,

             c_product           TYPE string,
             c_productname       TYPE string,
             c_product_plant     TYPE string,
             c_product_qty       TYPE decfloat34,

             p_product           TYPE string,
             p_productname       TYPE string,
             p_product_plant     TYPE string,
             p_product_qty       TYPE decfloat34,
             p_product_cost      TYPE decfloat34,

             processmaterialtype TYPE string,
             mainprocess         TYPE string,
             sfgoperation        TYPE string,

           END OF ty_bom.

    TYPES: tt_bom TYPE STANDARD TABLE OF ty_bom WITH EMPTY KEY.


    METHODS get_sfg_data_from_api
      IMPORTING
                iv_product    TYPE string
                iv_plant      TYPE string
      RETURNING VALUE(dt_bom) TYPE tt_bom.

ENDCLASS.

CLASS lhc_bh_detail IMPLEMENTATION.

  METHOD setdefaultlineid.

    READ ENTITIES OF zorn_rv_pah IN LOCAL MODE
      ENTITY bh_header BY \_details
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result)
      REPORTED DATA(lt_reported)
      FAILED DATA(lt_failed).

    " Initialize counter with total count of result entries
    DATA(counter) = lines( lt_result ).
    DATA(lineid) = 1.
    LOOP AT lt_result INTO DATA(ls_entity).

      " Update entity with default value using MODIFY ENTITIES
      IF   ls_entity-lineid IS INITIAL. " in case of create operation
        ls_entity-lineid = counter.
        DATA(lv_revgl_lineid) = CONV i( ls_entity-lineid ).
        DATA(lv_revgl_lineid_s) = CONV string( lv_revgl_lineid ).
        MODIFY ENTITIES OF zorn_rv_pah IN LOCAL MODE ENTITY bh_detail
          UPDATE FIELDS ( lineid )
          WITH VALUE #( ( %tky = ls_entity-%tky
                          lineid = lv_revgl_lineid_s ) ).
        EXIT.
      ELSEIF counter = lv_revgl_lineid_s.
        EXIT.

      ELSE. "in case of delete operation
        ls_entity-lineid = lineid.
        DATA(lv_revgl_lineid2) = CONV i( ls_entity-lineid ).
        DATA(lv_revgl_lineid2_s) = CONV string( lv_revgl_lineid2 ).
        MODIFY ENTITIES OF zorn_rv_pah IN LOCAL MODE ENTITY bh_detail
          UPDATE FIELDS ( lineid )
          WITH VALUE #( ( %tky = ls_entity-%tky
                          lineid = lv_revgl_lineid2_s ) ).

      ENDIF.
      " increment counter
      lineid = lineid + 1.

    ENDLOOP.

  ENDMETHOD.

  METHOD fetchdatafrommappingsheet.

    " Read current instances
    READ ENTITIES OF zorn_rv_pah IN LOCAL MODE
    ENTITY bh_detail
    FIELDS ( processid )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_header).

    LOOP AT lt_header INTO DATA(ls_header).

      DATA(lv_processid) = ls_header-processid.

      SELECT * FROM zorn_iv_pa_ms WHERE docid = @lv_processid
      INTO TABLE @DATA(lv_dt_line).

      LOOP AT lv_dt_line INTO DATA(ls_dt_line).

        " Update same entity
        MODIFY ENTITIES OF zorn_rv_pah IN LOCAL MODE
         ENTITY bh_detail
         UPDATE FIELDS ( process allotteename plant )
         WITH VALUE #(
           ( %tky = ls_header-%tky
             process   = ls_dt_line-process
             allotteename = ls_dt_line-allotteename
             plant = ls_dt_line-plant
           )
       ).

      ENDLOOP.

    ENDLOOP.


  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD fetchdetaildata.

    " Table For External BOM
    TYPES: BEGIN OF ty_bom,

             c_product           TYPE string,
             c_productname       TYPE string,
             c_product_plant     TYPE string,
             c_product_qty       TYPE decfloat34,

             p_product           TYPE string,
             p_productname       TYPE string,
             p_product_plant     TYPE string,
             p_product_qty       TYPE decfloat34,
             p_product_cost      TYPE decfloat34,

             processmaterialtype TYPE string,
             mainprocess         TYPE string,
             sfgoperation        TYPE string,

           END OF ty_bom.

    TYPES: dt_bom TYPE STANDARD TABLE OF ty_bom WITH EMPTY KEY.

    DATA lv_rm_productcode TYPE string.
    DATA lv_rm_allotee TYPE string.
    DATA lv_rm_plant TYPE string.
    DATA lv_rm_prcc TYPE string.


   READ ENTITIES OF zorn_rv_pah IN LOCAL MODE
     ENTITY Bh_Detail BY \_details1
     ALL FIELDS
     WITH CORRESPONDING #( keys )
     RESULT DATA(lt_detailsS).

    LOOP AT lt_detailsS ASSIGNING FIELD-SYMBOL(<fs_inspectiondata>).

        MODIFY ENTITIES OF zorn_rv_pah IN LOCAL MODE
        ENTITY Bh_Detail1
        DELETE FROM
        VALUE #( ( %key = <fs_inspectiondata>-%key
                                %is_draft = 01
                 ) )
        MAPPED DATA(lt_mappeds)
        FAILED DATA(lt_faileds)
        REPORTED DATA(lt_reporteds).

    ENDLOOP.


    READ ENTITIES OF zorn_rv_pah IN LOCAL MODE
    ENTITY bh_detail
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_details).

    LOOP AT lt_details INTO DATA(ls_detail).

      lv_rm_productcode = ls_detail-productcode.
      lv_rm_allotee = ls_detail-allotteename.
      lv_rm_plant = ls_detail-plant.
      lv_rm_prcc = ls_detail-process.

    ENDLOOP.

    READ ENTITIES OF zorn_rv_pah IN LOCAL MODE
    ENTITY bh_header
    FIELDS ( internalorderno skuno hplant )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_header).

    TRY.

        LOOP AT lt_header INTO DATA(ls_header).

          DATA lv_soitem TYPE string.
          DATA lv_so_plant TYPE string.
          DATA: dt_bom TYPE tt_bom.

          DATA(lv_so) = ls_header-internalorderno.
          lv_soitem = ls_header-skuno.
          lv_so_plant = ls_header-hplant.

          dt_bom =
              get_sfg_data_from_api(
                 iv_product     = lv_soitem
                 iv_plant = lv_so_plant ).


          LOOP AT dt_bom ASSIGNING FIELD-SYMBOL(<fs_parameterdata>).

            DATA(lv_paramertid) = <fs_parameterdata>-p_product.
            DATA(lv_cparamertid) = <fs_parameterdata>-c_product.
            DATA(lv_processcd) = <fs_parameterdata>-mainprocess.

            DATA ls_dt_prc TYPE string.
            DATA ls_dt_prcd TYPE string.

            SELECT * FROM ZUNE_CDS_MainProcess_VH
            WHERE value_low = @lv_processcd
            INTO TABLE @DATA(lv_dt_prcss).

            LOOP AT lv_dt_prcss INTO DATA(ls_dt_prcss).

              ls_dt_prc = ls_dt_prcss-text.
              ls_dt_prcd =  ls_dt_prcss-value_low.

            ENDLOOP.


            IF lv_soitem <> lv_paramertid.

              IF lv_rm_productcode = lv_cparamertid.

                DATA: lv_error_message TYPE string.

                MODIFY ENTITIES OF zorn_rv_pah IN LOCAL MODE
                ENTITY bh_detail
                CREATE BY \_details1
                         FROM VALUE #( ( %key = keys[ 1 ]-%key
                                         %is_draft = 01
                         %target = VALUE #( ( %cid = <fs_parameterdata>-c_product && <fs_parameterdata>-p_product && <fs_parameterdata>-p_product_qty
                                              %is_draft = 01
                                              processessfgcode = <fs_parameterdata>-p_product
                                              processessid = ls_dt_prcd
                                              Processessfg = ls_dt_prc
                                              %control-processessfgcode = if_abap_behv=>mk-on
                                              %control-Processessfg = if_abap_behv=>mk-on
                                              %control-processessid = if_abap_behv=>mk-on
                                        ) ) ) )
                MAPPED DATA(lt_mapped2)
                FAILED DATA(lt_failed2)
                REPORTED DATA(lt_reported2).

              ENDIF.

            ENDIF.

          ENDLOOP.



        ENDLOOP.

      CATCH cx_http_dest_provider_error INTO DATA(lx_http_error).
        " Handle HTTP destination provider error
        lv_error_message = lx_http_error->get_text( ).
      CATCH cx_web_http_client_error INTO DATA(lx_http_client_error).
        " Handle HTTP client error
        lv_error_message = lx_http_client_error->get_text( ).
      CATCH cx_web_message_error INTO DATA(lx_web_message_error).
        " Handle web message error
        lv_error_message = lx_web_message_error->get_text( ).
      CATCH cx_root INTO DATA(lx_root_error).
        " Handle any other unexpected error
        lv_error_message = lx_root_error->get_text( ).
    ENDTRY.




  ENDMETHOD.

  METHOD get_sfg_data_from_api.

    " Variable Define
    DATA : lv_json     TYPE string,
           rv_response TYPE string.

    DATA: lv_url      TYPE string,
          lv_user     TYPE string,
          lv_password TYPE string.

    " Declare variables for API URL and HTTP client objects
    DATA: lo_dest   TYPE REF TO if_http_destination,                " HTTP destination object
          lo_client TYPE REF TO if_web_http_client,                 " HTTP client object
          lo_req    TYPE REF TO if_web_http_request,                " HTTP request object
          lo_resp   TYPE REF TO if_web_http_response.               " HTTP response object

    DATA :lv_date TYPE d .

    TYPES: BEGIN OF ty_api_response,
             value TYPE tt_bom,
           END OF ty_api_response.

    DATA: ls_response TYPE ty_api_response.

    " Build complete API URL by combining base URL and_endpoint
    lv_url = |https://my409722-api.s4hana.cloud.sap/sap/opu/odata4/sap/zune_sb_bom_rm/srvd_a2x/sap/zune_sd_bom_rm/0001/ZUNE_CDS_BOM_RM(ItemNo='{ iv_product }',PlantC='{ iv_plant }')/Set|.
    lv_user = 'SAPBTP'.
    lv_password = 'xPFgdyoHtfyxomKqnKx#vZSeRL6LGWEgAzcJRGPN'.

    TRY.

        " Create HTTP destination from the URL
        lo_dest   = cl_http_destination_provider=>create_by_url( lv_url ).

        " Create HTTP client from the destination
        lo_client = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

        " Prepare HTTP request object
        lo_req = lo_client->get_http_request( ).

        " For Authorization
        lo_req->set_authorization_basic(
                i_username = lv_user
                i_password = lv_password
        ).

        " Set request content type as JSON
        lo_req->set_content_type( 'application/json' ).

        " Execute HTTP request with PUT method and capture response
        lo_resp     = lo_client->execute( if_web_http_client=>get ).

        " Get response text from HTTP response
        rv_response = lo_resp->get_text( ).

        /ui2/cl_json=>deserialize(
          EXPORTING
            json        = lo_resp->get_text( )
            pretty_name = /ui2/cl_json=>pretty_mode-camel_case
          CHANGING
            data        = ls_response
        ).

        dt_bom = ls_response-value.

        " Close HTTP client connection
        lo_client->close( ).



      CATCH cx_web_http_client_error INTO DATA(lx_web_error).

        DATA(lv_error_text) = lx_web_error->get_text( ).

      CATCH cx_http_dest_provider_error INTO DATA(lx_dest_error).
        DATA(lv_error_text2) = lx_dest_error->get_text( ).

    ENDTRY.

  ENDMETHOD.


ENDCLASS.
