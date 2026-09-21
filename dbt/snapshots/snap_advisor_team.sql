select
    record_pk,
    team_id,
    team_name,
    team_lead_advisor_id,
    branch_name,
    region,
    is_active,
    change_key
from {{ ref('brz_advisor_team') }}
