select
    {{ generate_pk(['record_pk', 'dbt_valid_from']) }} as advisor_history_id,
    advisor_id,
    role,
    rep_code,
    branch_name,
    is_active,
    version_number,
    dbt_valid_from as valid_from,
    dbt_valid_to as valid_to,
    is_current,
    coalesce(dbt_is_deleted, false) as is_deleted,
    current_timestamp() as resolved_at

from {{ ref('stg_fsc_advisor') }}
