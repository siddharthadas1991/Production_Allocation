@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root - Prod Allocation Header'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZORN_RV_PAH
  as select from ZORN_IV_PAH
  composition [0..*] of ZORN_RV_PAD as _details 
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
      _details
}
