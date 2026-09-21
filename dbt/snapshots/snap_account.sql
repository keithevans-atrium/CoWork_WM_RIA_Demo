select
    record_pk,
    account_id,
    account_name,
    account_type,
    record_type,
    advisor_id,
    financial_account_count,
    aum,
    billing_state,
    billing_city,
    client_segment,
    service_model,
    relationship_start_date,
    is_active,
    change_key
from {{ ref('brz_account') }}
