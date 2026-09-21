select
    record_pk,
    advisor_id,
    advisor_name,
    email,
    role,
    crd_number,
    rep_code,
    branch_name,
    manager_id,
    is_active,
    hire_date,
    termination_date,
    change_key
from {{ ref('raw_advisor') }}
