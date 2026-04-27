@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface - Prod Allocation Detail 1'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZORN_IV_PAD1
  as select from zorn_dt_pad1
{
  key linenum_d        as LinenumD,
  key linenum          as Linenum,
  key sapid            as Sapid,
      lineid           as Lineid,
      processessfgcode as Processessfgcode,
      processessid as processessid,
      processessfg     as Processessfg,
      rowselect        as Rowselect,
      machinescode     as Machinescode,
      machinesname     as Machinesname,
      machineno        as Machineno,
      contractor       as Contractor,
      @Semantics.user.createdBy: true
      created_by       as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at       as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      last_changed_by  as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at  as LastChangedAt
}
