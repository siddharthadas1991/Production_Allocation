@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface - Prod Allocation Detail'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZORN_IV_PAD
  as select from zorn_dt_pad 
{
  key linenum         as Linenum,
  key sapid           as Sapid,
      lineid          as Lineid,
      productname     as Productname,
      productcode     as Productcode,
      materialtype    as Materialtype,
      assignmentlog   as Assignmentlog,
      processid as processid,
      process         as Process,
      allotteename    as Allotteename,
      @Semantics.quantity.unitOfMeasure: 'qtyunit'
      quantityalloted as Quantityalloted,
      qtyunit         as Qtyunit,
      @Semantics.quantity.unitOfMeasure: 'qtyunit'
      singquantityalloted as singquantityalloted,
      length          as Length,
      width           as Width,
      height          as Height,
      plant           as Plant,
      @Semantics.user.createdBy: true
      created_by      as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at      as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      last_changed_by as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at as LastChangedAt 
}
