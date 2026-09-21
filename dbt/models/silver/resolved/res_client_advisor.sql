with accounts as (
    select account_id, advisor_id, relationship_start_date, is_active
    from {{ ref('stg_fsc_account') }}
    where is_current = true
)

select
    {{ generate_pk(['account_id', 'advisor_id']) }} as client_advisor_id,
    account_id as client_id,
    advisor_id,
    'Primary' as relationship_type,
    true as is_primary,
    relationship_start_date as effective_from,
    case when is_active then null else current_date() end as effective_to,
    is_active as is_current,
    current_timestamp() as resolved_at

from accounts
where advisor_id is not null
