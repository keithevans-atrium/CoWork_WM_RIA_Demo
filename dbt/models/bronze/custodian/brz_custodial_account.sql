select
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
    loaded_at
from {{ source('custodian', 'custodial_account') }}
