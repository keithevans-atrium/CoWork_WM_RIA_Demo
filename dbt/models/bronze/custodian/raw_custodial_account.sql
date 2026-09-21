select
    {{ generate_pk(['account_number']) }} as record_pk,
    custodial_account_id,
    account_number,
    account_title,
    registration_type,
    tax_id_last_four,
    custodian_code,
    rep_code,
    branch_code,
    status,
    date_opened,
    date_closed,
    margin_approved,
    options_level,
    loaded_at,
    'custodian' as _source_system,
    current_timestamp() as _loaded_at,
    'CUSTODIAL_ACCOUNT' as _record_source,
    {{ generate_change_key([
        'account_title', 'registration_type', 'custodian_code', 'rep_code', 'branch_code',
        'status', 'date_opened', 'date_closed', 'margin_approved', 'options_level'
    ]) }} as change_key
from {{ source('custodian', 'custodial_account') }}
