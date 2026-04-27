@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection - Prod Allocation Detail'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@UI.createHidden: true
define view entity ZORN_PV_PAD
  as projection on ZORN_RV_PAD
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
      _Header   : redirected to parent ZORN_PV_PAH,
      /* Associations */
      _details1 : redirected to composition child ZORN_PV_PAD1
}
