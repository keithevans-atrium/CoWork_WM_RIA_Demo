select
    team_id,
    team_name,
    team_lead_advisor_id,
    branch_name,
    region,
    is_active,
    created_date,
    last_modified_date
from {{ source('salesforce_fsc', 'advisor_team') }}
