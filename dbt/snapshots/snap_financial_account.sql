select
    record_pk,
    financial_account_id,
    account_id,
    financial_account_number,
    account_type,
    registration_type,
    custodian_name,
    status,
    balance,
    model_portfolio,
    management_fee_rate,
    is_discretionary,
    change_key
from {{ ref('brz_financial_account') }}
