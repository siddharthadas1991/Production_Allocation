@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value  Help - UOM'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZORN_VH_UNIT as select from I_UnitOfMeasureStdVH
{ 
    key UnitOfMeasure_E,
    UnitOfMeasure,
    UnitOfMeasureLongName,
    UnitOfMeasureDimension,
    UnitOfMeasureDimensionName
}
