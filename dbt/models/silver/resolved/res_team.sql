with fsc as (
    select * from {{ ref('stg_fsc_advisor_team') }} where is_current = true
)

select
    fsc.team_id,

    fsc.team_name                           as fsc_team_name,
    coalesce(fsc.team_name)                 as resolved_team_name,

    fsc.team_lead_advisor_id                as fsc_team_lead_advisor_id,
    coalesce(fsc.team_lead_advisor_id)      as resolved_team_lead_advisor_id,

    fsc.branch_name                         as fsc_branch_name,
    coalesce(fsc.branch_name)               as resolved_branch_name,

    fsc.region                              as fsc_region,
    coalesce(fsc.region)                    as resolved_region,

    fsc.is_active,

    'FSC_ONLY' as match_status,
    current_timestamp() as resolved_at

from fsc
