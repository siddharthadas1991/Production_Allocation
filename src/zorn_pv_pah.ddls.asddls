@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection - Prod Allocation Header'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZORN_PV_PAH
  provider contract transactional_query
  as projection on ZORN_RV_PAH
{
  key Sapid,
      Docid,
      Internalorderno,
      Skuno,
      Buyersono,
      Buyerskuno,
      Description,
      @Semantics.quantity.unitOfMeasure: 'qtyunit'
      Orderquantity, 
      @Semantics.unitOfMeasure: true
      Qtyunit,
      hplant as hplant,
      @Semantics.user.createdBy: true
      CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      CreatedAt,
      @Semantics.user.lastChangedBy: true
      LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,
      /* Associations */
      _details : redirected to composition child ZORN_PV_PAD
}
