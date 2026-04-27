@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection - Prod Allocation Detail 1'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZORN_PV_PAD1
  as projection on ZORN_RV_PAD1
{
  key LinenumD,
  key Linenum,
  key Sapid,
      Lineid,
      Processessfgcode,
      processessid,
      Processessfg,
      Rowselect,
      Machinescode,
      Machinesname,
      Machineno,
      Contractor,
      @Semantics.user.createdBy: true
      CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      CreatedAt,
      @Semantics.user.lastChangedBy: true
      LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,
      /* Associations */
      _Detailh : redirected to parent ZORN_PV_PAD,
      /* Associations */
      _Header : redirected to ZORN_PV_PAH 
}
