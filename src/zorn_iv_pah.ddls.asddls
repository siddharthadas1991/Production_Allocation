@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface - Prod Allocation Header'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZORN_IV_PAH
  as select from zorn_dt_pah
{
  key sapid           as Sapid,
      docid           as Docid,
      internalorderno as Internalorderno,
      skuno           as Skuno, 
      buyersono       as Buyersono,
      buyerskuno      as Buyerskuno,
      description     as Description,
      @Semantics.quantity.unitOfMeasure: 'qtyunit'
      orderquantity   as Orderquantity,
      qtyunit         as Qtyunit,
      hplant as hplant,
      @Semantics.user.createdBy: true
      created_by      as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at      as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      last_changed_by as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at as LastChangedAt
}
