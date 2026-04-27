@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value  Help - Sales Order Line'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZORN_VH_SO_LINE
  as select from I_SalesOrderItem as A
    inner join   I_SalesOrder    as C on C.SalesOrder = A.SalesOrder
    inner join   I_ProductText    as B on A.Product = B.Product
{
  key A.Product,
  key B.ProductName,
  key A.SalesOrder,
  key A.SalesOrderItem,
  @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
  A.OrderQuantity,
  A.OrderQuantityUnit,
  A.Plant,
  A.YY1_BuyerSKUNumber_SDI as BuyerSKU,
  C.PurchaseOrderByCustomer as BuyerSO
}
