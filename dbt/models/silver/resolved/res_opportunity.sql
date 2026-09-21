with fsc as (
    select * from {{ ref('stg_fsc_opportunity') }} where is_current = true
)

select
    fsc.opportunity_id,
    fsc.account_id as client_id,
    fsc.advisor_id,

    fsc.opportunity_name                    as fsc_opportunity_name,
    coalesce(fsc.opportunity_name)          as resolved_opportunity_name,

    fsc.stage                               as fsc_stage,
    coalesce(fsc.stage)                     as resolved_stage,

    fsc.opportunity_type,
    fsc.amount,
    fsc.expected_revenue,
    fsc.close_date,
    fsc.probability,
    fsc.lead_source,

    'FSC_ONLY' as match_status,
    current_timestamp() as resolved_at

from fsc
