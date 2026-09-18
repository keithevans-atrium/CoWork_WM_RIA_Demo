{% snapshot snap_client_segment %}

{{
    config(
        target_schema='SNAPSHOTS',
        unique_key='account_id',
        strategy='check',
        check_cols=['client_segment', 'service_model', 'aum', 'advisor_id', 'is_active']
    )
}}

select
    account_id,
    account_name,
    client_segment,
    service_model,
    aum,
    advisor_id,
    is_active,
    last_modified_date
from {{ source('salesforce_fsc', 'account') }}

{% endsnapshot %}
