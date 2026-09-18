select
    {{ generate_pk(['advisor_id']) }} as record_pk,
    advisor_id,
    first_name,
    last_name,
    first_name || ' ' || last_name as advisor_name,
    email,
    phone,
    role,
    crd_number,
    rep_code,
    branch_name,
    manager_id,
    is_active,
    hire_date,
    termination_date,
    created_date,
    last_modified_date,
    {{ generate_change_key([
        'first_name', 'last_name', 'email', 'phone', 'role', 'crd_number',
        'rep_code', 'branch_name', 'manager_id', 'is_active', 'hire_date', 'termination_date'
    ]) }} as change_key
from {{ source('salesforce_fsc', 'advisor') }}
