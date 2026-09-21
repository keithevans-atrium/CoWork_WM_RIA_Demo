select
    {{ generate_pk(['team_id']) }} as record_pk,
    team_id,
    team_name,
    team_lead_advisor_id,
    branch_name,
    region,
    is_active,
    created_date,
    last_modified_date,
    {{ generate_change_key([
        'team_name', 'team_lead_advisor_id', 'branch_name', 'region', 'is_active'
    ]) }} as change_key
from {{ source('salesforce_fsc', 'advisor_team') }}
