select
    {{ generate_pk(['financial_account_id']) }} as account_key,
    financial_account_id,
    account_number,
    account_name,
    registration_type,
    account_type,
    status,
    custodian_code,
    inception_date,
    fee_rate,
    fee_schedule,
    model_id,
    is_discretionary,
    client_id,
    advisor_id,
    account_match_status,
    canonical_at as loaded_at
from {{ ref('can_account_value') }}
