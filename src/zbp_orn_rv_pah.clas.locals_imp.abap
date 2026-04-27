CLASS lhc_bh_header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR bh_header RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR bh_header RESULT result.

    METHODS setinitialdata FOR DETERMINE ON SAVE
      IMPORTING keys FOR bh_header~setinitialdata.

    METHODS validateentry FOR VALIDATE ON SAVE
      IMPORTING keys FOR bh_header~validateentry.

    METHODS fetchdatafromso FOR DETERMINE ON MODIFY
      IMPORTING keys FOR bh_header~fetchdatafromso.
    METHODS fetchdata FOR MODIFY
      IMPORTING keys FOR ACTION bh_header~fetchdata.

    METHODS calculate FOR DETERMINE ON MODIFY
      IMPORTING keys FOR bh_header~calculate.

    TYPES: BEGIN OF ty_bom,
             itemcode     TYPE string,
             rmname       TYPE string,
             l            TYPE decfloat34,
             w            TYPE decfloat34,
             h            TYPE decfloat34,
             dia          TYPE decfloat34,
             childuom     TYPE c LENGTH 3,
             quantity     TYPE decfloat34,
             materialtype TYPE string,
             plant        TYPE string,
           END OF ty_bom.

    TYPES: tt_bom TYPE STANDARD TABLE OF ty_bom WITH EMPTY KEY.


    METHODS get_rm_data_from_api
      IMPORTING
                iv_product    TYPE string
                iv_plant      TYPE string
      RETURNING VALUE(dt_bom) TYPE tt_bom.


ENDCLASS.

CLASS lhc_bh_header IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD setinitialdata.

    SELECT MAX( CAST( docid AS INT4 )  ) FROM zorn_dt_pah INTO @DATA(lv_max_id).

    IF lv_max_id IS INITIAL.
      lv_max_id = 1.
    ELSE.
      lv_max_id += 1.
    ENDIF.

    MODIFY ENTITIES OF zorn_rv_pah IN LOCAL MODE
    ENTITY bh_header
    UPDATE
    FIELDS (  docid )
    WITH VALUE #( FOR ls_keys IN keys (
                    %tky = ls_keys-%tky
                    docid = |{ lv_max_id }|
                  )
                )
    REPORTED DATA(lt_reported)
    FAILED DATA(lt_failed).

    " Handle reported records
    reported = CORRESPONDING #( DEEP lt_reported ).

    " Handle failed records (optional, depending on your use case)
    IF lt_failed IS NOT INITIAL.
      " Log or process the failed entries
    ENDIF.

  ENDMETHOD.

  METHOD validateentry.

    READ ENTITIES OF zorn_rv_pah IN LOCAL MODE
    ENTITY bh_header
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result)
    REPORTED DATA(lt_reported)
    FAILED DATA(lt_failed).

    LOOP AT lt_result INTO DATA(ls_result).

*         Plant Validation

      IF ls_result-internalorderno IS INITIAL.
        APPEND VALUE #( %tky = ls_result-%tky )
        TO failed-bh_header.
        "IS INITAL IS TO CHECK THE NULL OR BLANK VALUE
        reported-bh_header = VALUE #( BASE reported-bh_header
                                     (
                                         %tky = ls_result-%tky
                                         %state_area = 'Validate_IntOrd'
                                         %msg = new_message(
                                                  id       = 'SY'
                                                  number   = '002'
                                                  v1       = 'Internal Order No. is mandatory !!'
                                                  severity = if_abap_behv_message=>severity-error
                                                )
                                         %element-internalorderno = if_abap_behv=>mk-on
                                     )
        ).
      ENDIF.

      IF ls_result-skuno IS INITIAL.
        APPEND VALUE #( %tky = ls_result-%tky )
        TO failed-bh_header.
        "IS INITAL IS TO CHECK THE NULL OR BLANK VALUE
        reported-bh_header = VALUE #( BASE reported-bh_header
                                     (
                                         %tky = ls_result-%tky
                                         %state_area = 'Validate_sku'
                                         %msg = new_message(
                                                  id       = 'SY'
                                                  number   = '002'
                                                  v1       = 'SKU No. is mandatory !!'
                                                  severity = if_abap_behv_message=>severity-error
                                                )
                                         %element-skuno = if_abap_behv=>mk-on
                                     )
        ).
      ENDIF.


      DATA ls_ord TYPE string.
      DATA ls_ordsku TYPE string.
      DATA ls_dcid TYPE string.

      ls_ord = ls_result-internalorderno.
      ls_dcid = ls_result-Docid.

      ls_ordsku = ls_result-skuno.

      SELECT COUNT( * ) FROM zorn_iv_pah WHERE internalorderno = @ls_ord AND skuno = @ls_ordsku and Docid <> @ls_dcid
      INTO @DATA(ls_data_count).

      IF ls_data_count > 0.

        APPEND VALUE #( %tky = ls_result-%tky )
        TO failed-bh_header.
        reported-bh_header = VALUE #( BASE reported-bh_header
                                     (
                                         %tky = ls_result-%tky
                                         %state_area = 'Validate_Duplicate'
                                         %msg = new_message(
                                                  id       = 'SY'
                                                  number   = '002'
                                                  v1       = 'Duplicate entry for InternalOrderNo & SKU No. !!'
                                                  severity = if_abap_behv_message=>severity-error
                                                )
                                     )
        ).


      ENDIF.


    ENDLOOP.


  ENDMETHOD.

  METHOD fetchdatafromso.

    " Read current instances
    READ ENTITIES OF zorn_rv_pah IN LOCAL MODE
    ENTITY bh_header
    FIELDS ( internalorderno skuno )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_header).

    LOOP AT lt_header INTO DATA(ls_header).

      DATA(lv_so) = ls_header-internalorderno.
      DATA(lv_soitem) = ls_header-skuno.

      SELECT * FROM zorn_vh_so_line WHERE salesorder = @lv_so AND product = @lv_soitem
      INTO TABLE @DATA(lv_dt_line).


      LOOP AT lv_dt_line INTO DATA(ls_dt_line).

*        SELECT unitofmeasure_e FROM ZORN_VH_UNIT WHERE unitofmeasure = @ls_dt_line-orderquantityunit
*            INTO @DATA(lsuom).
*      ENDSELECT.


        " Update same entity
        MODIFY ENTITIES OF zorn_rv_pah IN LOCAL MODE
         ENTITY bh_header
         UPDATE FIELDS ( description buyerskuno orderquantity qtyunit hplant buyersono )
         WITH VALUE #(
           ( %tky = ls_header-%tky
             description   = ls_dt_line-productname
             orderquantity = ls_dt_line-orderquantity
*             qtyunit = ls_dt_line-orderquantityunit
             hplant = ls_dt_line-plant
             buyerskuno = ls_dt_line-buyersku
             buyersono = ls_dt_line-buyerso

           )
       ).

      ENDLOOP.

    ENDLOOP.


  ENDMETHOD.

  METHOD fetchdata.


    " Table For External BOM
    TYPES: BEGIN OF ty_bom,
             itemcode     TYPE string,
             rmname       TYPE string,
             l            TYPE decfloat34,
             w            TYPE decfloat34,
             h            TYPE decfloat34,
             dia          TYPE decfloat34,
             childuom     TYPE c LENGTH 3,
             quantity     TYPE decfloat34,
             materialtype TYPE string,
             plant        TYPE string,
           END OF ty_bom.

    TYPES: dt_bom TYPE STANDARD TABLE OF ty_bom WITH EMPTY KEY.


    READ ENTITIES OF zorn_rv_pah IN LOCAL MODE
    ENTITY bh_header  BY \_details
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_details).

    LOOP AT lt_details ASSIGNING FIELD-SYMBOL(<fs_inspectiondata>).

      MODIFY ENTITIES OF zorn_rv_pah IN LOCAL MODE
      ENTITY bh_detail
      DELETE FROM
      VALUE #( ( %key = <fs_inspectiondata>-%key
                              %is_draft = 01
               ) )
      MAPPED DATA(lt_mappeds)
      FAILED DATA(lt_faileds)
      REPORTED DATA(lt_reporteds).

    ENDLOOP.

    READ ENTITIES OF zorn_rv_pah IN LOCAL MODE
    ENTITY bh_header
    FIELDS ( internalorderno skuno hplant orderquantity )
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

          DATA(ls_h_qty) = ls_header-orderquantity.


          dt_bom =
              get_rm_data_from_api(
                 iv_product     = lv_soitem
                 iv_plant = lv_so_plant ).


*      LOOP AT lv_dt_line INTO DATA(ls_dt_line).
          LOOP AT dt_bom ASSIGNING FIELD-SYMBOL(<fs_parameterdata>).

            DATA(lv_paramertid) = <fs_parameterdata>-itemcode.
            DATA(lv_materialtype) = <fs_parameterdata>-materialtype.

            DATA(lv_uom) = <fs_parameterdata>-childuom.

            SELECT unitofmeasure FROM i_unitofmeasurestdvh WHERE unitofmeasure_e = @lv_uom
            INTO @DATA(lsuom).
            ENDSELECT.




            IF ( lv_materialtype <> 'HALB' AND lv_materialtype <> 'FERT' ).

              DATA: lv_error_message TYPE string.

              MODIFY ENTITIES OF zorn_rv_pah IN LOCAL MODE
               ENTITY bh_header
               CREATE BY \_details
                        FROM VALUE #( ( %key = keys[ 1 ]-%key
                                       %is_draft = 01
                        %target = VALUE #( ( %cid = <fs_parameterdata>-itemcode && <fs_parameterdata>-quantity && <fs_parameterdata>-materialtype
                                             %is_draft = 01
                                             productcode = <fs_parameterdata>-itemcode
                                             productname = <fs_parameterdata>-rmname
                                             materialtype = <fs_parameterdata>-materialtype
                                             length = <fs_parameterdata>-l
                                             width = <fs_parameterdata>-w
                                             height = <fs_parameterdata>-h
                                             plant = <fs_parameterdata>-plant
                                             quantityalloted = ( <fs_parameterdata>-quantity * ls_h_qty )
                                             singquantityalloted = <fs_parameterdata>-quantity
                                             qtyunit = lsuom
                                             %control-productcode = if_abap_behv=>mk-on
                                             %control-productname = if_abap_behv=>mk-on
                                             %control-materialtype = if_abap_behv=>mk-on
                                             %control-length = if_abap_behv=>mk-on
                                             %control-width = if_abap_behv=>mk-on
                                             %control-height = if_abap_behv=>mk-on
                                             %control-plant = if_abap_behv=>mk-on
                                             %control-quantityalloted = if_abap_behv=>mk-on
                                             %control-singquantityalloted = if_abap_behv=>mk-on
                                             %control-qtyunit = if_abap_behv=>mk-on
                                       ) ) ) )
               MAPPED DATA(lt_mapped2)
               FAILED DATA(lt_failed2)
               REPORTED DATA(lt_reported2).

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

  METHOD get_rm_data_from_api.

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

    lv_url = |https://my409722-api.s4hana.cloud.sap/sap/opu/odata4/sap/zune_sb_extbomapi/srvd_a2x/sap/zune_sd_extbomapi/0001/ZUNE_CDS_EXTBOMAPI_F2(EProduct='{ iv_product }',EPlant='{ iv_plant }')/Set|.

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

  METHOD calculate.

    " Read current instances
    READ ENTITIES OF zorn_rv_pah IN LOCAL MODE
    ENTITY bh_header
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_header).

    DATA t_orderqty TYPE p LENGTH 10 DECIMALS 6.


    LOOP AT lt_header INTO DATA(ls_header).

      DATA(lv_orderqty) = ls_header-orderquantity.

      t_orderqty = lv_orderqty.

    ENDLOOP.

    READ ENTITIES OF zorn_rv_pah IN LOCAL MODE
    ENTITY bh_header BY \_details
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_det_h).

    LOOP AT lt_det_h INTO DATA(ls_det_h).

      MODIFY ENTITIES OF zorn_rv_pah IN LOCAL MODE
         ENTITY bh_detail
         UPDATE FIELDS ( quantityalloted )
         WITH VALUE #(
           (
             %tky = ls_det_h-%tky
             quantityalloted   = t_orderqty * ls_det_h-singquantityalloted
           )
       ).
    ENDLOOP.


  ENDMETHOD.

ENDCLASS.
