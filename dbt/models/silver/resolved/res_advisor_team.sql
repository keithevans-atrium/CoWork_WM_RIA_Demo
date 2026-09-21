with members as (
    select *
    from {{ source('salesforce_fsc', 'advisor_team_member') }}
    where is_active = true
)

select
    {{ generate_pk(['advisor_id', 'team_id']) }} as advisor_team_id,
    members.advisor_id,
    members.team_id,
    members.role_in_team,
    members.start_date as effective_from,
    members.end_date as effective_to,
    members.is_active as is_current,
    current_timestamp() as resolved_at

from members
