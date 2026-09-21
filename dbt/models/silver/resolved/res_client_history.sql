select
    {{ generate_pk(['record_pk', 'dbt_valid_from']) }} as client_history_id,
    account_id as client_id,
    client_segment,
    service_model,
    risk_tolerance,
    billing_state as state,
    is_active,
    version_number,
    dbt_valid_from as valid_from,
    dbt_valid_to as valid_to,
    is_current,
    coalesce(dbt_is_deleted, false) as is_deleted,
    current_timestamp() as resolved_at

from {{ ref('stg_fsc_account') }}
