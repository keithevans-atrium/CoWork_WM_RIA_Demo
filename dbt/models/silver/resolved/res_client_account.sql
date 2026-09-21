with fin_acct as (
    select financial_account_id, account_id, financial_account_number, registration_type, inception_date, status
    from {{ ref('stg_fsc_financial_account') }}
    where is_current = true
)

select
    {{ generate_pk(['account_id', 'financial_account_id']) }} as client_account_id,
    account_id as client_id,
    financial_account_id as account_id,
    financial_account_number as account_number,
    registration_type as ownership_type,
    100.00 as ownership_pct,
    inception_date as effective_from,
    case when status = 'Open' then null else current_date() end as effective_to,
    case when status = 'Open' then true else false end as is_current,
    current_timestamp() as resolved_at

from fin_acct
