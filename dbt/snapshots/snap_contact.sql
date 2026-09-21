select
    record_pk,
    contact_id,
    account_id,
    full_name,
    email,
    phone,
    mailing_state,
    date_of_birth,
    employment_status,
    employer_name,
    occupation,
    risk_tolerance,
    investment_experience,
    is_primary_contact,
    change_key
from {{ ref('brz_contact') }}
