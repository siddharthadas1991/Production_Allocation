@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface - Mapping Sheet'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZORN_IV_PA_MS
  as select from zorn_dt_pa_ms
{
  key sapid           as Sapid,
      docid           as docid,
      process         as Process,
      allottee_name   as AllotteeName,
      processes       as Processes,
      processes_name  as processes_name,
      plant           as Plant,
      @Semantics.user.createdBy: true
      created_by      as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at      as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at as LastChangedAt
}
