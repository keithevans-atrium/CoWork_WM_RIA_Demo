with fsc as (
    select * from {{ source('salesforce_fsc', 'financial_goal') }}
)

select
    fsc.goal_id,
    fsc.account_id as client_id,
    fsc.contact_id,

    fsc.goal_name                           as fsc_goal_name,
    coalesce(fsc.goal_name)                 as resolved_goal_name,

    fsc.goal_type                           as fsc_goal_type,
    coalesce(fsc.goal_type)                 as resolved_goal_type,

    fsc.target_amount,
    fsc.current_amount,
    fsc.target_date,
    fsc.priority,
    fsc.status,

    case when fsc.target_amount > 0
        then round(fsc.current_amount / fsc.target_amount * 100, 2)
        else 0
    end as progress_pct,

    'FSC_ONLY' as match_status,
    current_timestamp() as resolved_at

from fsc
