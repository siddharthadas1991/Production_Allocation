@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection - Mapping Sheet'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZORN_PV_PA_MS
  provider contract transactional_query
  as projection on ZORN_RV_PA_MS
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
