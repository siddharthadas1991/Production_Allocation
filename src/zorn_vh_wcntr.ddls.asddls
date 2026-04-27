@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value  Help - Work Center'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZORN_VH_WCNTR as select from I_WorkCenter
{
    key WorkCenterInternalID, 
    WorkCenter, 
    Plant
}
