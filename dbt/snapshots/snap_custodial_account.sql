select
    record_pk,
    account_number,
    account_title,
    registration_type,
    custodian_code,
    rep_code,
    branch_code,
    status,
    date_opened,
    date_closed,
    margin_approved,
    options_level,
    change_key
from {{ ref('raw_custodial_account') }}
