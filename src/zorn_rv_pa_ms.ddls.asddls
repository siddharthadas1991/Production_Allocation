@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root - Mapping Sheet'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZORN_RV_PA_MS
  as select from ZORN_IV_PA_MS
{
  key Sapid,
      docid,
      Process,
      AllotteeName,
      Processes,
      processes_name,
      Plant,
      @Semantics.user.createdBy: true
      CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      CreatedAt,
      @Semantics.user.lastChangedBy: true
      LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt
}
