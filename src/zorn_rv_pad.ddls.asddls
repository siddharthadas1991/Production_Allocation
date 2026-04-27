@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root - Prod Allocation Detail'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZORN_RV_PAD
  as select from ZORN_IV_PAD
  association to parent ZORN_RV_PAH  as _Header on $projection.Sapid = _Header.Sapid
  composition [0..*] of ZORN_RV_PAD1 as _details1
{
  key Linenum,
  key Sapid,
      Lineid,
      Productname,
      Productcode,
      Materialtype,
      Assignmentlog,
      processid,
      Process,
      Allotteename,
      @Semantics.quantity.unitOfMeasure: 'qtyunit'
      Quantityalloted,
      Qtyunit,
      @Semantics.quantity.unitOfMeasure: 'qtyunit'
      singquantityalloted as singquantityalloted,
      Length,
      Width,
      Height,
      Plant,
      @Semantics.user.createdBy: true
      CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      CreatedAt,
      @Semantics.user.lastChangedBy: true
      LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,
      /* Associations */
      _Header,
      _details1
}
