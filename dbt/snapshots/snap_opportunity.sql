select
    record_pk,
    opportunity_id,
    account_id,
    opportunity_name,
    stage,
    opportunity_type,
    amount,
    expected_revenue,
    close_date,
    probability,
    lead_source,
    advisor_id,
    change_key
from {{ ref('raw_opportunity') }}
