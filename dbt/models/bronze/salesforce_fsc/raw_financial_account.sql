select
    {{ generate_pk(['financial_account_id']) }} as record_pk,
    financial_account_id,
    account_id,
    contact_id,
    financial_account_name,
    financial_account_number,
    account_type,
    registration_type,
    custodian_name,
    status,
    balance,
    inception_date,
    close_date,
    model_portfolio,
    management_fee_rate,
    is_discretionary,
    created_date,
    last_modified_date,
    'salesforce_fsc' as _source_system,
    current_timestamp() as _loaded_at,
    'FINANCIAL_ACCOUNT' as _record_source,
    {{ generate_change_key([
        'account_id', 'contact_id', 'financial_account_name', 'financial_account_number',
        'account_type', 'registration_type', 'custodian_name', 'status', 'balance',
        'inception_date', 'close_date', 'model_portfolio', 'management_fee_rate', 'is_discretionary'
    ]) }} as change_key
from {{ source('salesforce_fsc', 'financial_account') }}
