CLASS lhc_rt_mapping DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR rt_mapping RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR rt_mapping RESULT result.
    METHODS setinitialdata FOR DETERMINE ON SAVE
      IMPORTING keys FOR rt_mapping~setinitialdata.

    METHODS validateentry FOR VALIDATE ON SAVE
      IMPORTING keys FOR rt_mapping~validateentry.

ENDCLASS.

CLASS lhc_rt_mapping IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD setinitialdata.

    SELECT MAX( CAST( docid AS INT4 )  ) FROM zorn_dt_pa_ms INTO @DATA(lv_max_id).

    IF lv_max_id IS INITIAL.
      lv_max_id = 1.
    ELSE.
      lv_max_id += 1.
    ENDIF.

    MODIFY ENTITIES OF zorn_rv_pa_ms IN LOCAL MODE
    ENTITY rt_mapping
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

    READ ENTITIES OF zorn_rv_pa_ms IN LOCAL MODE
    ENTITY rt_mapping
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result)
    REPORTED DATA(lt_reported)
    FAILED DATA(lt_failed).

    LOOP AT lt_result INTO DATA(ls_result).

*     Plant Validation

      IF ls_result-plant IS INITIAL.
        APPEND VALUE #( %tky = ls_result-%tky )
        TO failed-rt_mapping.
        "IS INITAL IS TO CHECK THE NULL OR BLANK VALUE
        reported-rt_mapping = VALUE #( BASE reported-rt_mapping
                                     (
                                         %tky = ls_result-%tky
                                         %state_area = 'Validate_Plant'
                                         %msg = new_message(
                                                  id       = 'SY'
                                                  number   = '002'
                                                  v1       = 'Plant is mandatory !!'
                                                  severity = if_abap_behv_message=>severity-error
                                                )
                                         %element-plant = if_abap_behv=>mk-on
                                     )
        ).
      ENDIF.

*     Alotee name Validation

      IF ls_result-allotteename IS INITIAL.
        APPEND VALUE #( %tky = ls_result-%tky )
        TO failed-rt_mapping.
        "IS INITAL IS TO CHECK THE NULL OR BLANK VALUE
        reported-rt_mapping = VALUE #( BASE reported-rt_mapping
                                     (
                                         %tky = ls_result-%tky
                                         %state_area = 'Validate_Alotee'
                                         %msg = new_message(
                                                  id       = 'SY'
                                                  number   = '002'
                                                  v1       = 'Alotee name is mandatory !!'
                                                  severity = if_abap_behv_message=>severity-error
                                                )
                                         %element-allotteename = if_abap_behv=>mk-on
                                     )
        ).
      ENDIF.

*     Process Validation

      IF ls_result-process IS INITIAL.
        APPEND VALUE #( %tky = ls_result-%tky )
        TO failed-rt_mapping.
        "IS INITAL IS TO CHECK THE NULL OR BLANK VALUE
        reported-rt_mapping = VALUE #( BASE reported-rt_mapping
                                     (
                                         %tky = ls_result-%tky
                                         %state_area = 'Validate_Process'
                                         %msg = new_message(
                                                  id       = 'SY'
                                                  number   = '002'
                                                  v1       = 'Process is mandatory !!'
                                                  severity = if_abap_behv_message=>severity-error
                                                )
                                         %element-process = if_abap_behv=>mk-on
                                     )
        ).
      ENDIF.

*     Processes Validation

      IF ls_result-processes IS INITIAL.
        APPEND VALUE #( %tky = ls_result-%tky )
        TO failed-rt_mapping.
        "IS INITAL IS TO CHECK THE NULL OR BLANK VALUE
        reported-rt_mapping = VALUE #( BASE reported-rt_mapping
                                     (
                                         %tky = ls_result-%tky
                                         %state_area = 'Validate_Processes'
                                         %msg = new_message(
                                                  id       = 'SY'
                                                  number   = '002'
                                                  v1       = 'Processes is mandatory !!'
                                                  severity = if_abap_behv_message=>severity-error
                                                )
                                         %element-processes = if_abap_behv=>mk-on
                                     )
        ).
      ENDIF.


*     Duplicate Data Validation

      SELECT COUNT( * ) FROM zorn_iv_pa_ms WHERE plant = @ls_result-plant AND allotteename = @ls_result-allotteename
      AND process = @ls_result-process
      AND processes = @ls_result-processes
      INTO @DATA(ls_data_count).

      IF ls_data_count > 0.

        APPEND VALUE #( %tky = ls_result-%tky )
        TO failed-rt_mapping.
        reported-rt_mapping = VALUE #( BASE reported-rt_mapping
                                     (
                                         %tky = ls_result-%tky
                                         %state_area = 'Validate_Duplicate'
                                         %msg = new_message(
                                                  id       = 'SY'
                                                  number   = '002'
                                                  v1       = 'Duplicate data already in system !!'
                                                  severity = if_abap_behv_message=>severity-error
                                                )
                                     )
        ).


      ENDIF.



    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
