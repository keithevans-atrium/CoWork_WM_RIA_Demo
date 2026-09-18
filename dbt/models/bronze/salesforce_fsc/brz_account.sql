select
    {{ generate_pk(['account_id']) }} as record_pk,
    account_id,
    account_name,
    account_type,
    record_type,
    owner_id as advisor_id,
    parent_account_id,
    financial_account_count,
    aum,
    billing_state,
    billing_city,
    billing_zip,
    phone,
    email,
    client_segment,
    service_model,
    relationship_start_date,
    is_active,
    created_date,
    last_modified_date,
    {{ generate_change_key([
        'account_name', 'account_type', 'record_type', 'owner_id', 'parent_account_id',
        'financial_account_count', 'aum', 'billing_state', 'billing_city', 'billing_zip',
        'phone', 'email', 'client_segment', 'service_model', 'relationship_start_date',
        'is_active'
    ]) }} as change_key
from {{ source('salesforce_fsc', 'account') }}
