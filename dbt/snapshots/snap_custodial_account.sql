{% snapshot snap_custodial_account %}

{{
    config(
        target_schema='SNAPSHOTS',
        unique_key='record_pk',
        strategy='check',
        check_cols=['change_key']
    )
}}

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
from {{ ref('brz_custodial_account') }}

{% endsnapshot %}
