@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value  Help - SFG Product'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZORN_VH_PRD as select from I_Product as A
inner join I_ProductText    as B on A.Product = B.Product
{
    key A.Product, 
    key B.ProductName,
    A.ProductType
}
where A.ProductType = 'HALB'
