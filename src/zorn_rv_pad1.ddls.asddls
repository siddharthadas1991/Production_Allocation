@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root - Prod Allocation Detail 1'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZORN_RV_PAD1 as select from ZORN_IV_PAD1 
association to parent ZORN_RV_PAD as _Detailh on $projection.Linenum = _Detailh.Linenum 
and $projection.Sapid = _Detailh.Sapid
association to ZORN_RV_PAH as _Header
  on $projection.Sapid = _Header.Sapid
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
    _Detailh,
    _Header
}
