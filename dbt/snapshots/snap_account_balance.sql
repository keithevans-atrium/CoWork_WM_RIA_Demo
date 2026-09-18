{% snapshot snap_account_balance %}

{{
    config(
        target_schema='SNAPSHOTS',
        unique_key='account_number',
        strategy='check',
        check_cols=['total_market_value', 'model_id', 'status']
    )
}}

select
    account_number,
    account_name,
    total_market_value,
    model_id,
    status,
    as_of_date,
    loaded_at
from {{ source('performance_system', 'account') }}

{% endsnapshot %}
