CLASS lhc_bh_detail1 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS setdefaultlineid FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Bh_Detail1~SetDefaultlineid.

    METHODS fetchdatafrommappingsheet FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Bh_Detail1~fetchdatafrommappingsheet.
    METHODS fetchdataformachine FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Bh_Detail1~fetchdataformachine.


ENDCLASS.

CLASS lhc_bh_detail1 IMPLEMENTATION.

  METHOD setdefaultlineid.

    READ ENTITIES OF zorn_rv_pah IN LOCAL MODE
      ENTITY Bh_Detail BY \_details1
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

        MODIFY ENTITIES OF zorn_rv_pah IN LOCAL MODE ENTITY Bh_Detail1
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
        MODIFY ENTITIES OF zorn_rv_pah IN LOCAL MODE ENTITY Bh_Detail1
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
    ENTITY Bh_Detail1
    FIELDS ( processessid )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_header).

    LOOP AT lt_header INTO DATA(ls_header).

      DATA(lv_processid) = ls_header-processessid.

      SELECT * FROM ZUNE_CDS_MainProcess_VH WHERE value_low = @lv_processid
      INTO TABLE @DATA(lv_dt_line).

      LOOP AT lv_dt_line INTO DATA(ls_dt_line).

        " Update same entity
        MODIFY ENTITIES OF zorn_rv_pah IN LOCAL MODE
         ENTITY Bh_Detail1
         UPDATE FIELDS ( Processessfg )
         WITH VALUE #(
           ( %tky = ls_header-%tky
             Processessfg   = ls_dt_line-text
           )
       ).

      ENDLOOP.

    ENDLOOP.


  ENDMETHOD.

  METHOD fetchdataformachine.

        " Read current instances
        READ ENTITIES OF zorn_rv_pah IN LOCAL MODE
        ENTITY Bh_Detail1
        FIELDS ( Machinescode )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_header).

        LOOP AT lt_header INTO DATA(ls_header).

          DATA(lv_processid) = ls_header-Machinescode.

          SELECT * FROM i_workcenter WHERE WorkCenterInternalID = @lv_processid
          INTO TABLE @DATA(lv_dt_line).

          LOOP AT lv_dt_line INTO DATA(ls_dt_line).

            " Update same entity
            MODIFY ENTITIES OF zorn_rv_pah IN LOCAL MODE
             ENTITY Bh_Detail1
             UPDATE FIELDS ( Machinesname )
             WITH VALUE #(
               ( %tky = ls_header-%tky
                 Machinesname   = ls_dt_line-WorkCenter
               )
           ).

          ENDLOOP.

        ENDLOOP.


  ENDMETHOD.

ENDCLASS.
