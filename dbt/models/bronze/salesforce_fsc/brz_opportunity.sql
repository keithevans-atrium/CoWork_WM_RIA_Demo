select
    opportunity_id,
    account_id,
    contact_id,
    opportunity_name,
    stage,
    opportunity_type,
    amount,
    expected_revenue,
    close_date,
    probability,
    lead_source,
    advisor_id,
    created_date,
    last_modified_date
from {{ source('salesforce_fsc', 'opportunity') }}
